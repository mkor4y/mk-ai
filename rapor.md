## 📌 BIST Analiz Telegram Botu - Teknik Rapor

Bu rapor, BIST Analiz Telegram Botu'nun **özelliklerini**, **mimarisini** ve **kullandığı teknolojileri** ayrıntılı şekilde özetler. Proje tamamen **Borsa İstanbul (BIST)** odaklıdır ve teknik analiz, haber analizi ile AI destekli yorumları birleştirir.

---

## 🧩 Genel Bakış

- **Amaç**: BIST hisseleri için yatırımcı dostu, özet ve detaylı analiz sunan bir Telegram botu geliştirmek.
- **Ana Yetkinlikler**:
  - **📊 Teknik Analiz** (RSI, MACD, MA, Bollinger, ADX, hacim, gap vb.)
  - **🎯 Trading Sinyalleri** (AL/SAT/BEKLE, güven skoru, risk seviyesi)
  - **📰 Haber Analizi** (RSS + NewsAPI + duyarlılık skoru)
  - **🤖 AI Destekli Analiz** (OpenRouter / DeepSeek Chat modeli)
  - **📚 Eğitim İçerikleri** (AI ile üretilen yatırım eğitimleri)
  - **💬 Telegram Entegrasyonu** (komutlar, menüler, butonlar, reply keyboard)

---

## 🧱 Mimari Bileşenler

### 1. `main.py` – BISTBot (Telegram Bot Orkestratörü)

- **Sınıf**: `BISTBot`
- **Görevleri**:
  - Telegram botunu başlatmak ve **komut / buton etkileşimlerini** yönetmek.
  - `BISTAnalyzer`, `NewsHelper`, `ChatGPTHelper` bileşenlerini orkestre etmek.
  - Kullanıcıya dönen **metin formatlarını** (uzun mesaj bölme, reply keyboard, inline keyboard) yönetmek.

- **Önemli Fonksiyonlar**:
  - `setup_logging()`  
    - Dosyaya (`bist_bot.log`) ve konsola log yazar.
    - Log seviyesi `Config.LOG_LEVEL` üzerinden yönetilir.
  - `setup_handlers()`  
    - `/start`, `/help`, `/menu`, `/analyze`, `/price`, `/education` komutlarını kaydeder.
    - Inline butonlar için `CallbackQueryHandler`, serbest metin menüsü için `MessageHandler` ekler.
  - `_split_message(text, limit)`  
    - Telegram 4096 karakter limitine takılmamak için uzun mesajları **paragraflara/satırlara göre** parçalar.
  - `_send_long_message(...)` ve `_edit_or_send_long(...)`  
    - Uzun analiz / yardım metinlerini birden fazla mesaj halinde güvenli şekilde yollar.
  - `start_command`, `menu_command`, `help_command`, `education_command`  
    - Kullanıcı ile ilk temas, menüler ve yardım akışını yönetir.
  - `analyze_stock_command`, `price_query_command`  
    - Belirli bir hisse için **kapsamlı analiz** veya **özet fiyat bilgisi** üretir.
  - `button_callback`  
    - Inline butonlar üzerinden **hisse seçimi**, **fiyat sorgulama**, **eğitim seçimi** gibi etkileşimleri yönetir.
  - `perform_stock_analysis(stock_symbol)`  
    - Analizin ana akışı:
      1. `BISTAnalyzer` ile fiyat, teknik veriler ve trading sinyallerini hazırla.
      2. `NewsHelper` ile haber özetini ve NewsAPI haberlerini hazırla.
      3. `ChatGPTHelper` ile AI analizi üret.
      4. `_build_analysis_message(...)` ile her şeyi tek bir raporda birleştir.

### 2. `bist_analyzer.py` – Teknik Analiz ve Sinyal Motoru

- **Sınıf**: `BISTAnalyzer`
- **Veri Kaynağı**:
  - `tvDatafeed` ile **TradingView** üzerinden BIST günlük `OHLCV` verisi (`Interval.in_daily`) çekilir.
  - Her sembol + gün sayısı için basit bir **in-memory cache** yapısı (`self.data_cache`) ile tekrar eden sorgular azaltılır.

- **Ana Fonksiyonlar**:
  - `get_stock_data(symbol, days=30)`  
    - `BIST:SYMBOL` formatında günlük veri çeker.
    - Sütunları (`Open/High/Low/Close/Volume`) projeye uygun hale (`open/high/low/close/volume`) dönüştürür.
    - `price` kolonu olarak `close` fiyatını ekler.
    - NaN verileri temizler ve cache’e yazar.
  - `get_stock_info(symbol)`  
    - Son 60 bar üzerinden:
      - Güncel fiyat
      - 24 saatlik yüzdesel değişim
      - Son bar hacmi ve 20 günlük ortalama hacim
      - 52 haftalık (veya veri yettiği kadar) **en yüksek / en düşük** kapanış
    - Temel metrikler (`market_cap`, `pe_ratio`, `dividend_yield`) tvDatafeed tarafında olmadığı için:
      - Şu an **0** veya türetilen değerlerle dolduruluyor (`dividend_yield` için ileride harici temettü kaynağı entegrasyonu planlanabilir).
    - tvDatafeed kullanılamazsa `_get_default_stock_info` ile sembol için **varsayılan** bir sözlük döner.
  - `calculate_technical_indicators(df)`  
    - `ta` kütüphanesi ile aşağıdaki indikatörleri hesaplar:
      - **RSI** (`Config.RSI_PERIOD`)
      - **MACD** (fast/slow/signal parametreleri `Config`’ten)
      - **MA20, MA50, MA100, MA200** (döngü ile `Config.MA_PERIODS`)
      - **Bollinger Bands** (`upper/middle/lower`)
      - **Gap oranı**: `(open - prev_close) / prev_close`
      - **ADX**, `+DI`, `-DI` (trend gücü ve yönü)
      - **Hacim ortalaması** (`volume_sma`) ve `volume_ratio`
    - Tüm sayısal sütunlardaki `NaN` ve `inf` değerleri güvenli şekilde **0.0**’a çeker.
  - `generate_trading_signals(df)`  
    - Son iki bar üzerinden:
      - **RSI sinyali**: Aşırı alım/satım eşiklerine göre (AL/SAT/BEKLE).
      - **MACD sinyali**: MACD – signal kesişimlerine göre.
      - **MA sinyali**: `price vs MA20 vs MA50` hiyerarşisine göre trend yönü (AL/SAT/BEKLE).
      - **Bollinger sinyali**: Fiyat üst/alt banda taşmış mı (AL/SAT/BEKLE).
      - **Hacim sinyali**: `volume_ratio` eşiğe göre (`YÜKSEK_HACİM`, `DÜŞÜK_HACİM`, `NORMAL_HACİM`).
      - **Trend sinyali**: `MA50 vs MA200` ilişkisine göre (`YÜKSELEN`, `DÜŞEN`, `YATAY`).
      - **Trend yönü**: `+DI` vs `-DI` (`YUKARI`, `AŞAĞI`, `NÖTR`).
      - **Momentum sinyali**: MACD histogram değişimi (`GÜÇLENEN`, `ZAYIFLAYAN`, `NÖTR`).
    - Bu bireysel sinyalleri `_calculate_overall_signal(...)` fonksiyonuna verir.
  - `_calculate_overall_signal(signals, adx_value)`  
    - RSI, MACD, MA, Bollinger, hacim, trend ve momentum sinyallerine **ağırlık** atar.
    - Her sinyali sayısal değere (AL=+1, SAT=-1, BEKLE=0 vb.) çevirir ve **normalize edilmiş skor** üretir.
    - ADX değerine göre **trend rejimi** (YATAY, ZAYIF_TREND, TREND, GÜÇLÜ_TREND) belirler ve skoru bu rejime göre yeniden ölçekler.
    - Sonuçta:
      - **Genel sinyal**: AL / SAT / BEKLE
      - **Güven skoru**: 0–100 arası
      - **Sinyal gücü**: ZAYIF / ORTA / GÜÇLÜ / ÇOK GÜÇLÜ
      - **Risk seviyesi**: DÜŞÜK / ORTA / YÜKSEK
      - **Trend rejimi** ve ADX değeri
    - Bu sonuçlar hem fiyat sorgusunda hem kapsamlı analizde kullanılır.

### 3. `news_helper.py` – Haber Toplama ve Duyarlılık Analizi

- **Sınıf**: `NewsHelper`
- **Kullanılan Kütüphaneler**:
  - `feedparser` – RSS parsing
  - `requests` – HTTP istekleri (RSS ve NewsAPI)
  - `datetime` – zaman filtreleri (son X saat)
  - `json`, `os` – JSON kayıt/okuma

- **RSS Akışı**:
  - `Config.RSS_FEED_URLS` içindeki kaynaklardan (AA, BloombergHT, Dünya, NTV, vb.) haberleri çeker.
  - `NEWS_HOURS_BACK` saat geriye kadar olan haberleri alır (varsayılan: 720 saat = 30 gün).
  - Her haberde:
    - Başlık, özet, link, yayın tarihi, kaynak adı, içerik alanı işlenir.
  - Haberler **tarihe göre tersten sıralanır** (en yeni en başta).

- **Hisse Bazlı Filtreleme**:
  - `filter_news_by_stock(news_list, stock_symbol)`:
    - `Config.STOCK_KEYWORDS[symbol]` + sembol + (varsa) şirket adı birleşiminden bir **anahtar kelime listesi** oluşturur.
    - Title ve content alanlarında bu kelimeleri arar.
    - Eşleşen haber için:
      - `matched_keyword`
      - `sentiment_score` (aşağıdaki yöntemle)
    - Log’da ilgili hisse için kaç haber bulunduğunu raporlar.

- **Duyarlılık Skoru**:
  - `_calculate_sentiment(text)`:
    - `Config.POSITIVE_WORDS` ve `Config.NEGATIVE_WORDS` listelerindeki kelimeleri sayar.
    - Pozitif – negatif farkını toplam kelime sayısına bölerek **-1 ile +1** arası bir skor üretir.
    - Skoru sınırlar ve yuvarlar.

- **Haber Özeti**:
  - `get_stock_news_summary(stock_symbol)`:
    - Tüm RSS haberlerini çeker, ilgili hisse için filtreler.
    - Bulunan haber sayısını, son 5 haberi, ortalama duyarlılık skorunu ve **POZİTİF/NEGATİF/NÖTR** etiketini hesaplar.
    - AI tarafında kullanılmak üzere **özet bir metin** ve ham veriyi döner.
  - `format_news_for_ai(news_summary)`:
    - AI modeli için hisse bazlı haberleri; duyarlılık, haber sayısı ve son haberler listesi ile birlikte **okunabilir bir formatta** string’e çevirir.

- **NewsAPI Entegrasyonu**:
  - `fetch_newsapi_news(stock_symbol, api_key, language='tr', max_results=10)`:
    - Hisse kodu + (varsa) şirket adı üzerinden OR’lu bir query oluşturur.
    - `https://newsapi.org/v2/everything` endpoint’ine istek atar.
    - Başlık, açıklama, link, tarih, kaynak adı ve içerik alanlarını içeren bir liste döner.
  - `save_news_to_json` / `load_news_from_json`:
    - NewsAPI haberlerini `newsapi_{SYMBOL}.json` dosyalarına kaydedip okur.
  - `print_newsapi_news(...)`:
    - CLI üzerinden test için hem eski JSON, hem yeni NewsAPI sonuçlarını ekrana basar.

### 4. `chatgpt_helper.py` – AI Analiz Motoru

- **Sınıf**: `ChatGPTHelper`
- **Altyapı**:
  - `openai` Python SDK, `OpenAI` client
  - `base_url = Config.OPENROUTER_BASE_URL` (OpenRouter endpoint)
  - `api_key = Config.OPENROUTER_API_KEY`
  - Model: `Config.OPENROUTER_MODEL` (varsayılan: `deepseek/deepseek-chat`)

- **Görevler**:
  - Hisse analizi için **yapılandırılmış** bir prompt üretip AI’dan detaylı yorum almak.
  - Eğitim içerikleri ve piyasa duyarlılığı analizleri üretmek.
  - Bot yardım metnini AI ile oluşturmak.

- **Temel Fonksiyonlar**:
  - `get_stock_analysis(stock_info, technical_data, signals, news_summary)`:
    - Kullanıcıya gösterilecek kapsamlı analiz prompt’unu `_create_analysis_prompt(...)` ile hazırlar.
    - Sistem mesajı olarak `_get_system_prompt()` kullanılır:
      - Deneyimli bir finansal analist rolü
      - BIST odaklı
      - Risk uyarıları, olasılık dili, teknik terim açıklamaları zorunlu
    - Modelden gelen yanıtı `analysis` olarak döner; hata durumunda `_get_default_analysis(...)` ile fallback mesaj üretir.
  - `get_educational_content(topic)`:
    - BIST yatırım eğitimi için konuya özel **eğitim notları** oluşturur.
    - Başlık yapısı:
      - Konu açıklaması
      - Pratik örnekler
      - Dikkat edilecek riskler
      - Yatırımcı ipuçları
      - BIST’te uygulama
  - `get_market_sentiment(stock_list)`:
    - Verilen hisse listesi için genel piyasa duyarlılığı, sektörel dağılım ve kısa/orta vadeli beklentileri AI ile özetler.
  - `get_help_content()`:
    - Botun ne yaptığı, komutlar ve kullanım ipuçları için kullanıcı dostu bir yardım metni üretir.

### 5. `config.py` – Konfigürasyon ve Sabitler

- **API Anahtarları**:
  - `TELEGRAM_TOKEN`, `OPENROUTER_API_KEY`, `TV_USERNAME`, `TV_PASSWORD` `.env` üzerinden okunur.
  - `NEWSAPI_KEY` doğrudan dosyada tanımlıdır (güvenlik için production ortamında `.env`’e taşınması tavsiye edilir).

- **Bot Ayarları**:
  - `MAX_MESSAGE_LENGTH`, `RATE_LIMIT_PER_MINUTE`, `LOG_FILE`, `LOG_LEVEL`, `TIMEZONE`.

- **Teknik Analiz Parametreleri**:
  - `RSI_PERIOD`, `MACD_FAST/SLOW/SIGNAL`, `MA_PERIODS`, `BOLLINGER_PERIOD`, `BOLLINGER_STD`.
  - Trading sinyalleri için eşikler: `RSI_OVERSOLD`, `RSI_OVERBOUGHT`, `VOLUME_THRESHOLD`.
  - ADX periyodu ve trend eşiği: `ADX_PERIOD`, `ADX_TREND_THRESHOLD`.

- **Desteklenen Hisseler**:
  - `SUPPORTED_BIST_STOCKS`: Şu an 20’ye yakın BIST sembolü (THYAO, GARAN, AKBNK, ASELS, KRDMD, TUPRS, vb.).

- **Haber Kaynakları**:
  - `RSS_FEED_URLS`: Türkiye odaklı ekonomi RSS’leri + birkaç global kaynak.

- **Hisse Anahtar Kelimeleri**:
  - `STOCK_KEYWORDS`: Her sembol için haberlerde taranacak Türkçe/İngilizce kelime ve ifade listeleri (örneğin THYAO için “thy”, “türk hava yolları”, “turkish airlines” vb.).

- **Duyarlılık Kelimeleri**:
  - `POSITIVE_WORDS` / `NEGATIVE_WORDS`: Haber metinlerinden duyarlılık skoru çıkarırken kullanılan kelime listeleri.

- **Risk Uyarısı**:
  - `RISK_WARNING`: Her analiz raporunun sonuna eklenen, yatırım tavsiyesi olmadığına dair standart uyarı metni.

---

## 🧑‍💻 Kullanılan Teknolojiler ve Kütüphaneler

- **Dil ve Çalışma Ortamı**
  - Python 3.8+ (proje gereksinimi)
  - Sanal ortam: `venv`

- **Telegram Bot**
  - `python-telegram-bot==20.7`
  - Async tabanlı handler’lar (`Application`, `CommandHandler`, `CallbackQueryHandler`, `MessageHandler`, `filters`).

- **Veri ve Teknik Analiz**
  - `pandas`, `numpy`
  - `ta` (Technical Analysis Library)
  - `tvdatafeed` (TradingView’den BIST verisi çekmek için)

- **Haber ve HTTP**
  - `feedparser` (RSS)
  - `requests` (RSS ve NewsAPI istekleri)

- **AI Entegrasyonu**
  - `openai==1.6.1` (OpenRouter üzerinden DeepSeek Chat modeli)

- **Konfigürasyon**
  - `python-dotenv==1.0.0` (`.env` okuyup ortam değişkenlerine aktarmak için)

---

## 🔄 Kullanıcı Akışları (Özet)

### `/start`
- Kullanıcıyı karşılar, botun ne yaptığını açıklar.
- Inline butonlar + altta kalıcı reply keyboard gösterir:
  - 📊 Hisse Analizi
  - 💰 Fiyat Sorgula
  - 📚 Eğitim
  - ❓ Yardım

### `/analyze HİSSE`
- Hata kontrolü:
  - Hisse girilmemişse örnek ve desteklenen semboller listesi gösterilir.
  - Desteklenmeyen sembolde uyarı verir.
- Analiz akışı:
  1. Teknik + fiyat + sinyaller (`BISTAnalyzer`)
  2. Haber özeti + duyarlılık (`NewsHelper`)
  3. AI analizi (`ChatGPTHelper`)
  4. Tümünün birleştiği tek bir kapsamlı rapor `_build_analysis_message`.

### `/price HİSSE`
- Özet fiyat ve temel veriler:
  - Güncel fiyat, 24 saatlik değişim, hacim.
  - Piyasa değeri (varsa), P/E oranı (varsa), temettü getirisi (şu an çoğunlukla 0 / “Veri yok”).

### `/education`
- Belirlenmiş konu listesinden (RSI, MACD, Bollinger, Risk Yönetimi vb.) seçim yapılır.
- Seçilen konu için AI’dan detaylı **eğitim içeriği** alınır ve uzun metin, `_edit_or_send_long` ile parçalara bölünüp gönderilir.

### `/help`
- AI destekli yardım içeriği alınır; hata durumunda statik bir yardım metni gönderilir.

---

## ⚠️ Sınırlamalar ve Notlar

- **Veri Kaynakları**:
  - TradingView / `tvdatafeed` verileri, resmi BIST datası değildir; gecikme veya veri farkı olabilir.
  - RSS ve NewsAPI kaynakları zaman zaman erişilemeyebilir veya format değiştirebilir.
- **Temettü ve Temel Veriler**:
  - Şu an için temel metrikler (piyasa değeri, P/E, temettü getirisi) **kısıtlı veya sabit** değerlerdir; harici bir finans API’siyle geliştirmeye açıktır.
- **AI Analizi**:
  - DeepSeek Chat modeli olasılıksal çalışır; her seferinde aynı yanıtı üretmeyebilir.
  - Analizler **yatırım tavsiyesi değil**, bilgilendirme amaçlıdır.

---

## 🚀 Geliştirme Fırsatları

- Temettü ve temel veri için **güvenilir bir finans API’si** ile entegrasyon (örneğin BIST veya aracı kurum API’leri).
+- Teknik analiz tarafında:
  - Ek indikatörler (Stochastic, Ichimoku, VWAP, vb.)
  - Farklı zaman dilimleri (4H, 1H, vb.) desteği.
- Haber analizi için:
  - Daha gelişmiş NLP tabanlı duyarlılık analizi (örneğin transformers modelleri).
  - Şirket bazlı özel kelime listelerinin zenginleştirilmesi.
- Kullanıcı deneyimi:
  - Kullanıcı başına **tercih kaydı** (örneğin varsayılan hisse listesi, varsayılan zaman dilimi).
  - Grafik veya görsel çıktı (fiyat / indikatör grafikleri) entegrasyonu.

Bu rapor, mevcut kod tabanını ve tasarımı yansıtır; kodda yapılacak değişikliklere paralel olarak `rapor.md` dosyasının da güncellenmesi önerilir.


