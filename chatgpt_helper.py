import openai
import logging
from typing import Dict, List
from config import Config

class ChatGPTHelper:
    """
    AI (Groq/OpenRouter) entegrasyon sınıfı.

    Görevleri:
    - Hisse analizi için AI'dan yapılandırılmış yorum almak
    - Eğitim içeriği üretmek
    - Genel piyasa duyarlılığı analizi oluşturmak
    - Bot yardım metnini AI ile üretmek
    """
    
    def __init__(self):
        """Sınıf başlatma - config ve AI client ayarları"""
        self.config = Config()
        self.logger = logging.getLogger(__name__)
        
        # AI provider seçimi: groq veya openrouter
        if self.config.AI_PROVIDER == 'groq':
            self.client = openai.OpenAI(
                base_url=self.config.GROQ_BASE_URL,
                api_key=self.config.GROQ_API_KEY
            )
            self.model = self.config.GROQ_MODEL
            self.logger.info("Groq API kullanılıyor")
        else:
            self.client = openai.OpenAI(
                base_url=self.config.OPENROUTER_BASE_URL,
                api_key=self.config.OPENROUTER_API_KEY
            )
            self.model = self.config.OPENROUTER_MODEL
            self.logger.info("OpenRouter API kullanılıyor")
    
    def get_stock_analysis(self, stock_info: Dict, technical_data: Dict, signals: Dict, news_summary: Dict) -> str:
        """
        Kapsamlı hisse analizi oluştur.

        Trading katmanından gelen teknik/fiyat verilerini ve haber özetini alır,
        bunları tek bir prompt içinde modele gönderir ve yatırımcı dostu bir analiz
        metni üretmesini ister.
        Args:
            stock_info (Dict): Hisse temel bilgileri
            technical_data (Dict): Teknik analiz verileri
            signals (Dict): Trading sinyalleri
            news_summary (Dict): Haber analizi
        Returns:
            str: AI tarafından oluşturulan analiz
        """
        try:
            self.logger.info(f"AI analizi oluşturuluyor: {stock_info.get('symbol', 'UNKNOWN')}")
            
            # AI için prompt hazırla
            prompt = self._create_analysis_prompt(stock_info, technical_data, signals, news_summary)
            
            # AI'dan yanıt al
            response = self.client.chat.completions.create(
                model=self.model,
                messages=[
                    {"role": "system", "content": self._get_system_prompt()},
                    {"role": "user", "content": prompt}
                ],
                max_tokens=self.config.AI_MAX_TOKENS,
                temperature=self.config.AI_TEMPERATURE
            )
            
            analysis = response.choices[0].message.content.strip()
            self.logger.info("AI analizi başarıyla oluşturuldu")
            
            return analysis
            
        except Exception as e:
            self.logger.error(f"AI analizi hatası: {e}")
            return self._get_default_analysis(stock_info, signals)
    
    def _create_analysis_prompt(self, stock_info: Dict, technical_data: Dict, signals: Dict, news_summary: Dict) -> str:
        """
        AI analizi için prompt oluştur.

        Hisse fiyatı, teknik göstergeler, sinyaller ve haber özetini bir araya getirir.
        Modelden istenen çıktı yapısını (1–7 başlık) burada tarif ederiz.
        Args:
            stock_info (Dict): Hisse bilgileri
            technical_data (Dict): Teknik veriler
            signals (Dict): Trading sinyalleri
            news_summary (Dict): Haber özeti
        Returns:
            str: Hazırlanmış prompt
        """
        prompt = f"""
🤖 BIST HİSSE ANALİZİ - {stock_info.get('symbol', 'UNKNOWN')}

📊 TEMEL BİLGİLER:
- Hisse: {stock_info.get('name', 'Bilinmiyor')} ({stock_info.get('symbol', 'UNKNOWN')})
- Güncel Fiyat: {stock_info.get('current_price', 0):.2f} TL
- 24 Saatlik Değişim: {stock_info.get('price_change_24h', 0):.2f}%
- Piyasa Değeri: {stock_info.get('market_cap', 0):,.0f} TL
- Hacim: {stock_info.get('volume_24h', 0):,.0f}

📈 TEKNİK GÖSTERGELER:
- RSI: {technical_data.get('rsi', 0):.2f} (Sinyal: {signals.get('rsi_signal', 'NÖTR')})
- MACD: {technical_data.get('macd', 0):.4f} (Sinyal: {signals.get('macd_signal', 'NÖTR')})
- MA20: {technical_data.get('ma_20', 0):.2f} TL
- MA50: {technical_data.get('ma_50', 0):.2f} TL
- MA100: {technical_data.get('ma_100', 0):.2f} TL
- ADX: {technical_data.get('adx', 0):.2f} (Rejim: {signals.get('trend_regime', '-')}, Yön: {signals.get('trend_direction', '-')})
- Bollinger Orta: {technical_data.get('bb_middle', 0):.2f} TL
- Bollinger Üst: {technical_data.get('bb_upper', 0):.2f} TL
- Bollinger Alt: {technical_data.get('bb_lower', 0):.2f} TL
- Gap Oranı: {technical_data.get('gap_pct', 0):.2f}%

🎯 TRADING SİNYALLERİ:
- Genel Sinyal: {signals.get('overall_signal', 'BEKLE')}
- Güven Skoru: {signals.get('confidence', 0):.1f}%
- Sinyal Gücü: {signals.get('signal_strength', 'ZAYIF')}
- Risk Seviyesi: {signals.get('risk_level', 'ORTA')}

📰 HABER ANALİZİ:
{news_summary.get('summary', 'Haber bulunamadı.')}

🔍 Lütfen bu verileri kullanarak aşağıdaki başlıklar altında kapsamlı bir analiz yap:

1. 📋 GENEL DURUM: Hisse senedinin genel durumu ve piyasa konumu
2. 📊 TEKNİK GÖSTERGELERİN DURUMU: ADX/Trend Rejimi ve Yönü, RSI, MACD, MA ve Bollinger Bands, Gap yorumu
3. ⏰ KISA VADELİ BEKLENTİ (1-7 gün): Yakın gelecek tahmini
4. 📅 ORTA VADELİ BEKLENTİ (1-4 hafta): Orta vadeli beklenti
5. 🎯 UZUN VADELİ BEKLENTİ (1-6 ay): Uzun vadeli görünüm
6. ⚠️ RİSK FAKTÖRLERİ: Dikkat edilmesi gereken riskler
7. 💡 YATIRIMCI ÖNERİLERİ: Alım/satım/bekleme tavsiyeleri

Analizi Türkçe olarak, yatırımcı dostu bir dilde yaz. Teknik terimleri açıkla ve pratik öneriler ver.
"""
        return prompt
    
    def _get_system_prompt(self) -> str:
        """AI hisse analizi için sistem prompt'unu döndürür."""
        return """Sen MK AI, Mustafa Koray Kök tarafından geliştirilen bir yapay zeka asistanısın.
Sen deneyimli bir finansal analist ve yatırım danışmanısın. 
BIST hisse senetleri konusunda uzmanlaşmışsın ve teknik analiz, temel analiz ve haber analizi konularında derin bilgiye sahipsin.

Görevlerin:
1. Verilen teknik göstergeleri doğru yorumla
2. Haber duyarlılığını analiz et
3. Kısa, orta ve uzun vadeli beklentiler oluştur
4. Risk faktörlerini belirle
5. Pratik yatırımcı önerileri ver

Önemli kurallar:
- Her zaman risk uyarısı yap
- Kesin tahminler verme, olasılıkları belirt
- Teknik terimleri açıkla
- Türkçe yaz, yatırımcı dostu ol
- Dengeli ve objektif analiz yap
- Geçmiş performansın gelecek garantisi olmadığını hatırlat

DİL KURALLARI (ÇOK ÖNEMLİ):
- SADECE Türkçe yaz. ASLA Çince (中文), Japonca, Korece veya başka Asya dili karakterleri KULLANMA.
- Yanıtlarında sadece Türkçe alfabesi (a-z, ç, ğ, ı, ö, ş, ü) ve standart ASCII karakterleri kullan.
- Yabancı karakterler görürsen onları Türkçe'ye çevir veya atla.
- Bu kural kesindir ve her durumda geçerlidir."""
    
    def _get_default_analysis(self, stock_info: Dict, signals: Dict) -> str:
        """AI hatası durumunda basit, fallback bir analiz döndürür."""
        return f"""
🤖 {stock_info.get('symbol', 'UNKNOWN')} ANALİZİ

❌ AI analizi sırasında teknik bir hata oluştu. 
Aşağıda mevcut verilerle oluşturulan temel analiz bulunmaktadır:

📊 GENEL DURUM:
Hisse senedi şu anda {signals.get('overall_signal', 'BEKLE')} sinyali veriyor.

🎯 TRADING SİNYALLERİ:
- Genel Sinyal: {signals.get('overall_signal', 'BEKLE')}
- Güven Skoru: {signals.get('confidence', 0):.1f}%
- Risk Seviyesi: {signals.get('risk_level', 'ORTA')}

⚠️ RİSK UYARISI:
Bu analiz sadece bilgilendirme amaçlıdır. Yatırım kararlarınızı kendi araştırmanıza dayandırın.
"""
    
    def get_educational_content(self, topic: str) -> str:
        """
        Eğitim içeriği oluştur.
        Args:
            topic (str): Eğitim konusu
        Returns:
            str: Eğitim içeriği
        """
        try:
            self.logger.info(f"Eğitim içeriği oluşturuluyor: {topic}")
            
            prompt = f"""
📚 BIST YATIRIM EĞİTİMİ - {topic.upper()}

Lütfen "{topic}" konusunda kapsamlı bir eğitim içeriği hazırla.

İçerik şu başlıkları içermeli:
1. 📖 KONU AÇIKLAMASI: Nedir, nasıl çalışır?
2. 🎯 PRATİK ÖRNEKLER: Gerçek hayattan örnekler
3. ⚠️ DİKKAT EDİLECEKLER: Riskler ve uyarılar
4. 💡 YATIRIMCI İPUÇLARI: Pratik öneriler
5. 📊 BIST'TE UYGULAMA: Türkiye piyasasında nasıl kullanılır?

İçeriği:
- Türkçe yaz
- Yeni başlayanlar için anlaşılır olsun
- Pratik örnekler ver
- Emoji kullan (📈📉💰📊)
- Kısa paragraflar halinde yaz
- Önemli noktaları vurgula
"""
            
            response = self.client.chat.completions.create(
                model=self.model,
                messages=[
                    {"role": "system", "content": "Sen deneyimli bir finans eğitmenisin. BIST ve yatırım konularında uzmanlaşmışsın. SADECE Türkçe yaz, ASLA Çince/Japonca/Korece karakter kullanma."},
                    {"role": "user", "content": prompt}
                ],
                max_tokens=self.config.AI_MAX_TOKENS,
                temperature=self.config.AI_TEMPERATURE
            )
            
            content = response.choices[0].message.content.strip()
            self.logger.info("Eğitim içeriği başarıyla oluşturuldu")
            
            return content
            
        except Exception as e:
            self.logger.error(f"Eğitim içeriği hatası: {e}")
            return f"❌ Eğitim içeriği oluşturulurken hata oluştu: {e}"
    
    def get_market_sentiment(self, stock_list: List[str]) -> str:
        """
        Genel piyasa duyarlılığı analizi
        Args:
            stock_list (List[str]): Hisse listesi
        Returns:
            str: Piyasa duyarlılığı analizi
        """
        try:
            self.logger.info("Piyasa duyarlılığı analizi oluşturuluyor")
            
            prompt = f"""
📊 BIST GENEL PİYASA DUYARLILIĞI ANALİZİ

Analiz edilecek hisseler: {', '.join(stock_list)}

Lütfen bu hisselerin genel piyasa duyarlılığını analiz et:

1. 📈 GENEL TREND: Piyasanın genel yönü
2. 🎯 SEKTÖREL ANALİZ: Hangi sektörler güçlü/zayıf
3. ⏰ KISA VADELİ BEKLENTİ: Önümüzdeki günler
4. 📅 ORTA VADELİ BEKLENTİ: Haftalar
5. 💡 YATIRIMCI STRATEJİLERİ: Genel öneriler

Analizi:
- Türkçe yaz
- Emoji kullan
- Pratik öneriler ver
- Risk uyarısı yap
"""
            
            response = self.client.chat.completions.create(
                model=self.model,
                messages=[
                    {"role": "system", "content": "Sen deneyimli bir piyasa analistisin. SADECE Türkçe yaz, ASLA Çince/Japonca/Korece karakter kullanma."},
                    {"role": "user", "content": prompt}
                ],
                max_tokens=self.config.AI_MAX_TOKENS,
                temperature=self.config.AI_TEMPERATURE
            )
            
            sentiment = response.choices[0].message.content.strip()
            self.logger.info("Piyasa duyarlılığı analizi başarıyla oluşturuldu")
            
            return sentiment
            
        except Exception as e:
            self.logger.error(f"Piyasa duyarlılığı hatası: {e}")
            return f"❌ Piyasa duyarlılığı analizi sırasında hata oluştu: {e}"
    
    def get_help_content(self) -> str:
        """Bot yardım içeriği oluştur"""
        try:
            prompt = """
🤖 BIST ANALİZ BOTU YARDIM

Lütfen bu bot için kapsamlı bir yardım içeriği hazırla:

1. 🎯 BOT NEDİR: Bot'un amacı ve özellikleri
2. 📋 KULLANIM: Nasıl kullanılır, komutlar
3. 📊 ÖZELLİKLER: Hangi analizleri yapar
4. ⚠️ UYARILAR: Önemli notlar ve riskler
5. 💡 İPUÇLARI: En iyi kullanım önerileri

İçeriği:
- Türkçe yaz
- Emoji kullan
- Kısa ve öz olsun
- Kolay anlaşılır olsun
"""
            
            response = self.client.chat.completions.create(
                model=self.model,
                messages=[
                    {"role": "system", "content": "Sen kullanıcı dostu bir bot yardım editörüsün. SADECE Türkçe yaz, ASLA Çince/Japonca/Korece karakter kullanma."},
                    {"role": "user", "content": prompt}
                ],
                max_tokens=800,
                temperature=0.5
            )
            
            help_content = response.choices[0].message.content.strip()
            return help_content
            
        except Exception as e:
            self.logger.error(f"Yardım içeriği hatası: {e}")
            return """
🤖 BIST ANALİZ BOTU YARDIM

❌ Yardım içeriği oluşturulamadı. Lütfen daha sonra tekrar deneyin.

Bot özellikleri:
- Hisse analizi
- Teknik göstergeler
- Haber analizi
- AI destekli yorumlar
"""
