import numpy as np
from tvDatafeed import TvDatafeed, Interval
import ta
import logging
from config import Config

class BISTAnalyzer:
    """
    BIST Hisse Analiz Sınıfı.

    TradingView (tvDatafeed) üzerinden BIST hisseleri için fiyat verisi çeker,
    teknik indikatörleri hesaplar ve trading sinyalleri üretir.
    """
    
    def __init__(self):
        """Sınıf başlatma - config ve logger ayarları"""
        self.config = Config()
        self.logger = logging.getLogger(__name__)
        
        # TradingView tvDatafeed istemcisi
        try:
            if self.config.TV_USERNAME and self.config.TV_PASSWORD:
                self.tv = TvDatafeed(username=self.config.TV_USERNAME, password=self.config.TV_PASSWORD)
            else:
                self.tv = TvDatafeed()
            self.logger.info("tvDatafeed istemcisi hazır")
        except Exception as e:
            self.logger.error(f"tvDatafeed başlatma hatası: {e}")
            self.tv = None

        # Cache sistemi - aynı sembol ve gün sayısı için veriyi kısa süreli bellekte tutar
        self.data_cache = {}
        self.cache_duration = 300  # 5 dakika cache süresi
    
    def get_stock_data(self, symbol, days=30):
        """
        TradingView tvDatafeed ile BIST hisse verilerini al.

        Args:
            symbol (str): Hisse kodu (örn: THYAO)
            days (int): Kaç günlük veri alınacak
        Returns:
            DataFrame: Hisse verileri (OHLCV + price) veya None (hata durumunda)
        """
        try:
            # Cache kontrolü - aynı sembol ve gün sayısı için veriyi tekrar çekme
            import time
            current_time = time.time()
            cache_key = f"{symbol}_{days}"
            
            if cache_key in self.data_cache:
                cache_time, cached_data = self.data_cache[cache_key]
                if current_time - cache_time < self.cache_duration:
                    self.logger.info(f"Cache'den veri alındı: {symbol}")
                    return cached_data
            
            # Sembolü TradingView formatına normalize et ve veriyi çek
            symbol_norm = self._normalize_symbol(symbol)
            self.logger.info(f"Veri alınıyor (tvDatafeed): BIST:{symbol_norm}")
            if self.tv is None:
                self.logger.error("tvDatafeed istemcisi hazır değil")
                return None
            df = self.tv.get_hist(symbol=symbol_norm, exchange='BIST', interval=Interval.in_daily, n_bars=max(int(days), 60))
            
            # Veri kontrolü
            if df.empty:
                self.logger.error(f"Veri bulunamadı: BIST:{symbol_norm}")
                return None
            
            # Sütun isimlerini standardize et (tvDatafeed -> bizim kullandığımız isimler)
            df = df.rename(columns={
                'Open': 'open',
                'High': 'high', 
                'Low': 'low',
                'Close': 'close',
                'Volume': 'volume'
            })
            
            # Fiyat sütunu ekle (analiz için close fiyatını kullan)
            df['price'] = df['close']
            
            # NaN değerleri temizle
            df = df.dropna()
            
            # Cache'e kaydet
            self.data_cache[cache_key] = (current_time, df)
            
            self.logger.info(f"Veri başarıyla alındı: {symbol} - {len(df)} gün")
            return df
            
        except Exception as e:
            self.logger.error(f"Veri alma hatası {symbol}: {e}")
            return None
    
    def get_stock_info(self, symbol):
        """
        Hisse için özet fiyat bilgilerini al (son fiyat, günlük değişim, hacim vb.).
        Args:
            symbol (str): Hisse kodu
        Returns:
            dict: Hisse bilgileri veya None
        """
        try:
            # tvDatafeed hazır değilse varsayılan hisse bilgisi dön
            if self.tv is None:
                self.logger.error("tvDatafeed istemcisi hazır değil, varsayılan hisse bilgisi döndürülüyor")
                return self._get_default_stock_info(symbol)

            # TradingView verisinden temel fiyat bilgilerini türet
            symbol_norm = self._normalize_symbol(symbol)
            self.logger.info(f"Hisse bilgileri alınıyor (tvDatafeed): BIST:{symbol_norm}")
            df = self.tv.get_hist(symbol=symbol_norm, exchange='BIST', interval=Interval.in_daily, n_bars=60)
            if df is None or df.empty or len(df) < 2:
                self.logger.warning("Temel bilgi için yeterli veri yok")
                return self._get_default_stock_info(symbol)

            if 'Close' in df.columns:
                df = df.rename(columns={'Open': 'open','High': 'high','Low': 'low','Close': 'close','Volume': 'volume'})

            current_price = float(df['close'].iloc[-1])
            previous_close = float(df['close'].iloc[-2])
            volume_24h = float(df['volume'].iloc[-1]) if 'volume' in df.columns else 0
            avg_volume = float(df['volume'].tail(20).mean()) if 'volume' in df.columns else 0

            if previous_close > 0:
                price_change_24h = ((current_price - previous_close) / previous_close) * 100
            else:
                price_change_24h = 0

            stock_info = {
                'name': symbol_norm,
                'symbol': symbol_norm,
                'current_price': round(current_price, 4),
                'price_change_24h': round(price_change_24h, 2),
                'volume_24h': round(volume_24h, 2),
                # tvDatafeed ile temel metrikler olmadığı için burada 0 olarak tutulur.
                # Çıktı tarafında bu değerler "Veri yok" şeklinde gösterilir.
                'market_cap': 0,
                'pe_ratio': 0,
                'dividend_yield': 0,
                'high_52w': float(df['close'].tail(252).max()) if len(df) >= 252 else float(df['close'].max()),
                'low_52w': float(df['close'].tail(252).min()) if len(df) >= 252 else float(df['close'].min()),
                'avg_volume': round(avg_volume, 2)
            }

            self.logger.info(f"Hisse bilgileri alındı: {symbol_norm}")
            return stock_info

        except Exception as e:
            self.logger.error(f"Hisse bilgisi alma hatası {symbol}: {e}")
            
            return None
    
    def calculate_technical_indicators(self, df):
        """
        Teknik analiz göstergelerini hesapla.

        Hesaplanan başlıca göstergeler:
        - RSI
        - MACD (macd, macd_signal, macd_histogram)
        - Hareketli ortalamalar (MA20, MA50, MA100, MA200 *)
        - Bollinger Bantları (üst, orta, alt)
        - Gap oranı
        - ADX ve DI+ / DI-
        - Hacim ortalaması ve hacim oranı

        Args:
            df (DataFrame): Hisse verileri
        Returns:
            DataFrame: Teknik göstergeler eklenmiş veri
        """
        try:
            if df is None or df.empty:
                return None
            
            self.logger.info("Teknik göstergeler hesaplanıyor...")
            
            # RSI (Relative Strength Index) hesapla
            df['rsi'] = ta.momentum.RSIIndicator(
                df['price'], 
                window=self.config.RSI_PERIOD
            ).rsi()
            
            # MACD (Moving Average Convergence Divergence) hesapla
            macd = ta.trend.MACD(
                df['price'],
                window_fast=self.config.MACD_FAST,
                window_slow=self.config.MACD_SLOW,
                window_sign=self.config.MACD_SIGNAL
            )
            df['macd'] = macd.macd()
            df['macd_signal'] = macd.macd_signal()
            df['macd_histogram'] = macd.macd_diff()
            
            # Hareketli ortalamalar (Moving Averages) hesapla
            for period in self.config.MA_PERIODS:
                df[f'ma_{period}'] = ta.trend.SMAIndicator(
                    df['price'], 
                    window=period
                ).sma_indicator()
            
            # Bollinger Bantları hesapla
            bb = ta.volatility.BollingerBands(
                df['price'],
                window=self.config.BOLLINGER_PERIOD,
                window_dev=self.config.BOLLINGER_STD
            )
            df['bb_upper'] = bb.bollinger_hband()
            df['bb_middle'] = bb.bollinger_mavg()
            df['bb_lower'] = bb.bollinger_lband()
            
            # Gap oranı (açılış fiyatı vs önceki kapanış)
            try:
                prev_close = df['close'].shift(1)
                df['gap_pct'] = ((df['open'] - prev_close) / prev_close) * 100.0
            except Exception:
                df['gap_pct'] = 0.0

            # ADX (Average Directional Index) - Trend gücü
            try:
                import warnings
                adx_window = getattr(self.config, 'ADX_PERIOD', 14)
                with np.errstate(invalid='ignore', divide='ignore'):
                    with warnings.catch_warnings():
                        warnings.simplefilter("ignore", category=RuntimeWarning)
                        adx_ind = ta.trend.ADXIndicator(
                            high=df['high'],
                            low=df['low'],
                            close=df['close'],
                            window=adx_window
                        )
                        df['adx'] = adx_ind.adx()
                        df['di_plus'] = adx_ind.adx_pos()
                        df['di_minus'] = adx_ind.adx_neg()
                # Sonsuz/NaN değerleri güvenli şekilde sıfırla
                for col in ['adx', 'di_plus', 'di_minus']:
                    if col in df.columns:
                        df[col] = df[col].replace([np.inf, -np.inf], np.nan).fillna(0.0)
            except Exception as e:
                self.logger.warning(f"ADX hesaplanamadı: {e}")
                df['adx'] = 0.0
                df['di_plus'] = 0.0
                df['di_minus'] = 0.0
            
            # Hacim göstergeleri hesapla
            df['volume_sma'] = df['volume'].rolling(20).mean()
            df['volume_ratio'] = df['volume'] / df['volume_sma']
            
            # Tüm sayısal sütunlarda NaN değerleri doldur
            numeric_columns = df.select_dtypes(include=[np.number]).columns
            for col in numeric_columns:
                df[col] = df[col].fillna(0.0)
            
            self.logger.info("Teknik göstergeler hesaplandı")
            return df
            
        except Exception as e:
            self.logger.error(f"Teknik analiz hatası: {e}")
            return df if df is not None else None
    
    def generate_trading_signals(self, df):
        """
        Trading sinyalleri ve güven skorları hesapla.

        RSI, MACD, hareketli ortalamalar, Bollinger bantları, hacim ve ADX gibi
        göstergeleri birleştirerek:
        - Bireysel sinyaller (AL/SAT/BEKLE vb.)
        - Genel sinyal (overall_signal)
        - Güven skoru, sinyal gücü ve risk seviyesi üretir.
        Args:
            df (DataFrame): Teknik göstergeler eklenmiş veri
        Returns:
            dict: Trading sinyalleri ve skorlar
        """
        try:
            if df is None or df.empty or len(df) < 50:
                self.logger.warning("Yeterli veri yok, varsayılan sinyaller döndürülüyor")
                return self._get_default_signals()
            
            self.logger.info("Trading sinyalleri hesaplanıyor...")
            
            # Son veriyi al
            current = df.iloc[-1]
            prev = df.iloc[-2]
            
            # Sinyal sözlüğünü başlat (varsayılan tüm göstergeler NÖTR)
            signals = {
                'rsi_signal': 'NÖTR',
                'macd_signal': 'NÖTR', 
                'ma_signal': 'NÖTR',
                'bb_signal': 'NÖTR',
                'volume_signal': 'NÖTR',
                'trend_signal': 'NÖTR',
                'momentum_signal': 'NÖTR',
                'overall_signal': 'NÖTR',
                'confidence': 0,
                'risk_level': 'ORTA',
                'signal_strength': 'ZAYIF'
            }
            
            # RSI sinyali
            rsi = current['rsi']
            if rsi < self.config.RSI_OVERSOLD:
                signals['rsi_signal'] = 'AL'
            elif rsi > self.config.RSI_OVERBOUGHT:
                signals['rsi_signal'] = 'SAT'
            else:
                signals['rsi_signal'] = 'BEKLE'
            
            # MACD sinyali (sinyal çizgisi kesişimleri)
            macd = current['macd']
            macd_signal = current['macd_signal']
            if macd > macd_signal and prev['macd'] <= prev['macd_signal']:
                signals['macd_signal'] = 'AL'
            elif macd < macd_signal and prev['macd'] >= prev['macd_signal']:
                signals['macd_signal'] = 'SAT'
            else:
                signals['macd_signal'] = 'BEKLE'
            
            # Hareketli ortalamalar sinyali (MA20 ve MA50 hiyerarşisi)
            price = current['price']
            ma_20 = current['ma_20']
            ma_50 = current['ma_50']
            
            if price > ma_20 > ma_50:
                signals['ma_signal'] = 'AL'
            elif price < ma_20 < ma_50:
                signals['ma_signal'] = 'SAT'
            else:
                signals['ma_signal'] = 'BEKLE'
            
            # Bollinger Bantları sinyali (fiyat bantların dışına taştığında)
            bb_upper = current['bb_upper']
            bb_lower = current['bb_lower']
            
            if price < bb_lower:
                signals['bb_signal'] = 'AL'
            elif price > bb_upper:
                signals['bb_signal'] = 'SAT'
            else:
                signals['bb_signal'] = 'BEKLE'
            
            # Hacim sinyali (ortalama hacme göre)
            volume_ratio = current['volume_ratio']
            if volume_ratio > self.config.VOLUME_THRESHOLD:
                signals['volume_signal'] = 'YÜKSEK_HACİM'
            elif volume_ratio < 0.7:
                signals['volume_signal'] = 'DÜŞÜK_HACİM'
            else:
                signals['volume_signal'] = 'NORMAL_HACİM'
            
            # Trend sinyali (MA50 vs MA200 ilişkisi)
            ma_200 = current.get('ma_200', ma_50)
            if ma_50 > ma_200 and price > ma_50:
                signals['trend_signal'] = 'YÜKSELEN'
            elif ma_50 < ma_200 and price < ma_50:
                signals['trend_signal'] = 'DÜŞEN'
            else:
                signals['trend_signal'] = 'YATAY'
            
            # Trend yönü (+DI vs -DI)
            di_plus = float(current.get('di_plus', 0.0)) if 'di_plus' in current else 0.0
            di_minus = float(current.get('di_minus', 0.0)) if 'di_minus' in current else 0.0
            if di_plus > di_minus:
                signals['trend_direction'] = 'YUKARI'
            elif di_minus > di_plus:
                signals['trend_direction'] = 'AŞAĞI'
            else:
                signals['trend_direction'] = 'NÖTR'
            
            # Momentum sinyali (MACD histogram değişimi)
            hist_cur = current['macd_histogram']
            hist_prev = prev['macd_histogram']
            if hist_cur > hist_prev:
                signals['momentum_signal'] = 'GÜÇLENEN'
            elif hist_cur < hist_prev:
                signals['momentum_signal'] = 'ZAYIFLAYAN'
            else:
                signals['momentum_signal'] = 'NÖTR'
            
            # Genel sinyal ve güven skorunu hesapla (ADX rejim filtresi ile)
            adx_value = float(current.get('adx', 0.0)) if 'adx' in current else 0.0
            signals.update(self._calculate_overall_signal(signals, adx_value))
            
            self.logger.info(f"Trading sinyalleri hesaplandı: {signals['overall_signal']}")
            return signals
            
        except Exception as e:
            self.logger.error(f"Trading sinyali hesaplama hatası: {e}")
            return self._get_default_signals()
    
    def _calculate_overall_signal(self, signals, adx_value: float | None = None):
        """
        Genel sinyal ve güven skorunu hesapla
        Args:
            signals (dict): Bireysel sinyaller
            adx_value (float|None): Son ADX değeri (rejim filtresi için)
        Returns:
            dict: Genel sinyal ve skorlar
        """
        # Ağırlıklı skor hesaplama
        weights = {
            'rsi_signal': 1.2,
            'macd_signal': 1.2,
            'ma_signal': 1.0,
            'bb_signal': 0.8,
            'volume_signal': 0.6,
            'trend_signal': 0.8,
            'momentum_signal': 0.6
        }
        
        # Sinyal değerlerini sayıya çevir
        def signal_to_value(signal):
            if signal in ['AL', 'YÜKSELEN', 'GÜÇLENEN', 'YÜKSEK_HACİM']:
                return 1
            elif signal in ['SAT', 'DÜŞEN', 'ZAYIFLAYAN', 'DÜŞÜK_HACİM']:
                return -1
            else:
                return 0
        
        # Ağırlıklı skor hesapla
        total_score = 0
        max_score = sum(weights.values())
        
        for signal_name, weight in weights.items():
            signal_value = signal_to_value(signals[signal_name])
            total_score += signal_value * weight
        
        # Normalize edilmiş skor (-1 ile 1 arası)
        normalized_score = total_score / max_score
        
        # ADX rejim filtresi uygula
        regime = 'BİLİNMİYOR'
        regime_factor = 1.0
        adx_threshold = getattr(self.config, 'ADX_TREND_THRESHOLD', 25)
        if adx_value is not None:
            if adx_value < max(adx_threshold - 5, 10):
                regime = 'YATAY'
                regime_factor = 0.6
            elif adx_value < adx_threshold:
                regime = 'ZAYIF_TREND'
                regime_factor = 0.8
            elif adx_value < 40:
                regime = 'TREND'
                regime_factor = 1.0
            else:
                regime = 'GÜÇLÜ_TREND'
                regime_factor = 1.1
        
        normalized_score = max(min(normalized_score * regime_factor, 1.0), -1.0)
        
        # Genel sinyal belirle
        if normalized_score > 0.15:
            overall_signal = 'AL'
        elif normalized_score < -0.15:
            overall_signal = 'SAT'
        else:
            overall_signal = 'BEKLE'
        
        # Güven skoru hesapla (0-100 arası)
        confidence = 50 + (abs(normalized_score) * 40)
        confidence = min(confidence, 100)  # Maksimum 100
        
        # Sinyal gücü belirle
        if confidence >= 80:
            signal_strength = 'ÇOK GÜÇLÜ'
        elif confidence >= 65:
            signal_strength = 'GÜÇLÜ'
        elif confidence >= 50:
            signal_strength = 'ORTA'
        else:
            signal_strength = 'ZAYIF'
        
        # Risk seviyesi belirle
        if abs(normalized_score) > 0.5:
            risk_level = 'DÜŞÜK'
        elif abs(normalized_score) > 0.3:
            risk_level = 'ORTA'
        else:
            risk_level = 'YÜKSEK'
        
        # ADX düşükse riski artır
        if adx_value is not None and adx_value < adx_threshold:
            if risk_level == 'DÜŞÜK':
                risk_level = 'ORTA'
            elif risk_level == 'ORTA':
                risk_level = 'YÜKSEK'
        
        return {
            'overall_signal': overall_signal,
            'confidence': round(confidence, 1),
            'signal_strength': signal_strength,
            'risk_level': risk_level,
            'trend_regime': regime,
            'adx': round(float(adx_value), 2) if adx_value is not None else None
        }
    
    def _get_default_signals(self):
        """Varsayılan sinyal sözlüğü döndür"""
        return {
            'rsi_signal': 'NÖTR',
            'macd_signal': 'NÖTR',
            'ma_signal': 'NÖTR',
            'bb_signal': 'NÖTR',
            'volume_signal': 'NÖTR',
            'trend_signal': 'NÖTR',
            'momentum_signal': 'NÖTR',
            'overall_signal': 'BEKLE',
            'confidence': 50,
            'risk_level': 'ORTA',
            'signal_strength': 'ZAYIF'
        }
    
    def _get_default_stock_info(self, symbol):
        """
        Varsayılan hisse bilgileri (API çalışmadığında)
        Args:
            symbol (str): Hisse kodu
        Returns:
            dict: Varsayılan hisse bilgileri
        """
        # Hisse isimleri (desteklenen semboller için insan okunur adlar)
        stock_names = {
            'THYAO': 'Türk Hava Yolları',
            'GARAN': 'Garanti Bankası',
            'AKBNK': 'Akbank',
            'ASELS': 'Aselsan',
            'KRDMD': 'Kardemir',
            'TUPRS': 'Tüpraş',
            'DOFRB': 'Dofer',
            'ISCTR': 'İş Bankası',
            'YKBNK': 'Yapı Kredi Bankası',
            'HALKB': 'Halkbank',
            'VAKBN': 'Vakıfbank',
            'SISE': 'Şişecam',
            'BIMAS': 'BİM Mağazalar',
            'EREGL': 'Ereğli Demir Çelik',
            'HEKTS': 'Hektaş',
            'SASA': 'SASA Polyester',
            'FROTO': 'Ford Otosan',
            'TOASO': 'Tofaş',
            'KCHOL': 'Koç Holding',
            'SAHOL': 'Sabancı Holding',
            'BORLS': 'Borlease Otomotiv',
            'TUREX': 'Tureks Turizm Taşımacılık',
            'KSTUR': 'KSTUR Turizm Taşımacılık',
            'TKFEN': 'Tekfen Holding',
        }
        
        return {
            'name': stock_names.get(symbol, symbol),
            'symbol': symbol.upper(),
            'current_price': 0,
            'price_change_24h': 0,
            'volume_24h': 0,
            'market_cap': 0,
            'pe_ratio': 0,
            'dividend_yield': 0,
            'high_52w': 0,
            'low_52w': 0,
            'avg_volume': 0
        }

    def _normalize_symbol(self, symbol: str) -> str:
        """TradingView için sembolü normalize et (THYAO.IS -> THYAO)."""
        s = (symbol or "").strip().upper()
        if s.endswith('.IS'):
            s = s[:-3]
        return s
