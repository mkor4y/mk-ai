import os
from dotenv import load_dotenv

# .env dosyasını yükle - API anahtarları buradan alınacak
load_dotenv()

class Config:
    """
    BIST Analiz Botu Konfigürasyon Sınıfı
    Tüm bot ayarları, API anahtarları ve sabitler burada tanımlanır
    """
    
    # ==================== API ANAHTARLARI ====================
    # Telegram Bot Token - BotFather'dan alınan token
    TELEGRAM_TOKEN = os.getenv('TELEGRAM_TOKEN')
    
    # OpenRouter API Key - DeepSeek modeli için kullanılacak
    OPENROUTER_API_KEY = os.getenv('OPENROUTER_API_KEY')

    # TradingView tvDatafeed için kullanıcı bilgileri (zorunlu değil, ama önerilir)
    TV_USERNAME = os.getenv('TV_USERNAME')
    TV_PASSWORD = os.getenv('TV_PASSWORD')
    
    # ==================== BOT AYARLARI ====================
    # Maksimum mesaj uzunluğu - Telegram limiti
    MAX_MESSAGE_LENGTH = 4096
    
    # Dakikada maksimum istek sayısı - Rate limiting için
    RATE_LIMIT_PER_MINUTE = 30
    
    # Log dosyası adı
    LOG_FILE = 'bist_bot.log'
    
    # Log seviyesi (DEBUG, INFO, WARNING, ERROR)
    LOG_LEVEL = os.getenv('LOG_LEVEL', 'INFO')
    
    # Zaman dilimi
    TIMEZONE = 'Europe/Istanbul'
    
    # ==================== TEKNİK ANALİZ AYARLARI ====================
    # RSI (Relative Strength Index) periyodu
    RSI_PERIOD = 14
    
    # MACD (Moving Average Convergence Divergence) ayarları
    MACD_FAST = 12      # Hızlı MA periyodu
    MACD_SLOW = 26      # Yavaş MA periyodu
    MACD_SIGNAL = 9     # Sinyal çizgisi periyodu
    
    # Moving Average periyotları
    MA_PERIODS = [20, 50, 100, 200]  # 20, 50, 100, 200 günlük MA'lar
    
    # Bollinger Bands ayarları
    BOLLINGER_PERIOD = 20   # Periyot
    BOLLINGER_STD = 2       # Standart sapma çarpanı
    
    # Trading sinyalleri için eşik değerleri
    RSI_OVERSOLD = 30       # RSI aşırı satım seviyesi
    RSI_OVERBOUGHT = 70     # RSI aşırı alım seviyesi
    VOLUME_THRESHOLD = 1.5  # Hacim eşiği (ortalama hacmin 1.5 katı)
    
    # ==================== DESTEKLENEN BİST HİSSELERİ ====================
    # Bot'un analiz edebileceği hisse kodları (toplam 20+ adet)
    SUPPORTED_BIST_STOCKS = [
        'THYAO',  # Türk Hava Yolları
        'GARAN',  # Garanti Bankası
        'AKBNK',  # Akbank
        'ASELS',  # Aselsan
        'KRDMD',  # Kardemir
        'TUPRS',  # Tüpraş
        'DOFRB',  # Dofer
        'ISCTR',  # İş Bankası
        'YKBNK',  # Yapı Kredi
        'HALKB',  # Halkbank
        'VAKBN',  # Vakıfbank
        'SISE',   # Şişecam
        'BIMAS',  # BİM
        'EREGL',  # Ereğli Demir Çelik
        'HEKTS',  # Hektaş
        'SASA',   # SASA Polyester
        'FROTO',  # Ford Otosan
        'TOASO',  # Tofaş
        'KCHOL',  # Koç Holding
        'SAHOL',  # Sabancı Holding
        'BORLS',  # Borlease Otomotiv
        'TUREX',  # Tureks Turizm Taşımacılık
        'KSTUR',  # Köstür / Kstür Turizm Taşımacılık
        'TKFEN',  # Tekfen Holding
    ]
    
    # ==================== AI (OPENROUTER) AYARLARI ====================
    # OpenRouter API endpoint
    OPENROUTER_BASE_URL = "https://openrouter.ai/api/v1"
    
    # Kullanılacak AI modeli (DeepSeek Chat)
    OPENROUTER_MODEL = "deepseek/deepseek-chat"
    
    # AI analizi için maksimum token sayısı
    # Daha uzun ve detaylı analizler için artırıldı
    AI_MAX_TOKENS = 2500

    # AI analizi için sıcaklık (yaratıcılık seviyesi)
    AI_TEMPERATURE = 0.7
    
    # ==================== GROQ API AYARLARI ====================
    # Groq API (daha hızlı ve stabil)
    # Not: API anahtarlarını koda gömmeyin; sadece environment (.env / panel env) üzerinden verin.
    GROQ_API_KEY = os.getenv('GROQ_API_KEY')
    GROQ_BASE_URL = "https://api.groq.com/openai/v1"
    GROQ_MODEL = "llama-3.3-70b-versatile"
    
    # Hangi AI provider kullanılacak: 'groq' veya 'openrouter'
    AI_PROVIDER = os.getenv('AI_PROVIDER', 'groq')

    # ==================== ADX AYARLARI ====================
    # ADX periyodu ve trend eşiği (rejim filtresi)
    ADX_PERIOD = 14
    ADX_TREND_THRESHOLD = 25

    # ==================== RSS HABER KAYNAKLARI ====================
    # BIST + küresel ekonomi haberleri için RSS feed URL'leri
    RSS_FEED_URLS = {
        # Türkiye (stabil ve hızlı kaynaklar)
        'aa_ekonomi': 'https://www.aa.com.tr/tr/rss/default?cat=ekonomi',
        'bloomberg_tr': 'https://www.bloomberght.com/rss',
        'dunya_genel': 'https://www.dunya.com/rss',
        'ntv_ekonomi': 'https://www.ntv.com.tr/ekonomi.rss',
        'haberturk_ekonomi': 'https://www.haberturk.com/rss/ekonomi.xml',
        'milliyet_ekonomi': 'https://www.milliyet.com.tr/rss/rssNew/ekonomiRss.xml',
        'hurriyet_ekonomi': 'https://www.hurriyet.com.tr/rss/ekonomi',
        'sabah_ekonomi': 'https://www.sabah.com.tr/rss/ekonomi.xml',

        # Küresel / İngilizce (Reuter/CNN hariç, nispeten stabil kaynaklar)
        'bbc_business': 'http://feeds.bbci.co.uk/news/business/rss.xml',
        'marketwatch_top': 'https://feeds.marketwatch.com/marketwatch/topstories/',
        'marketwatch_markets': 'https://feeds.marketwatch.com/marketwatch/marketpulse/',
        'cnbc_markets': 'https://www.cnbc.com/id/10000664/device/rss/rss.html'
    }

    # Haber analizi için son kaç saatlik haberler alınacak
    # 1 ay ≈ 30 gün * 24 saat = 720 saat
    NEWS_HOURS_BACK = 720

    # Maksimum haber sayısı
    MAX_NEWS_COUNT = 25
    
    # ==================== HİSSE KODU EŞLEŞTİRMELERİ ====================
    # RSS haberlerinde hisse kodlarını bulmak için anahtar kelimeler
    STOCK_KEYWORDS = {
        'THYAO': ['thy', 'türk hava yolları', 'turkish airlines', 'havayolu', 'thy hisse', 'thy borsa', 'thy fiyat'],
        'GARAN': ['garanti', 'garanti bankası', 'garanti bank', 'garan hisse', 'garan borsa', 'garan fiyat'],
        'AKBNK': ['akbank', 'ak bank', 'akbnk hisse', 'akbnk borsa', 'akbnk fiyat'],
        'ASELS': ['aselsan', 'savunma', 'asels hisse', 'asels borsa', 'asels fiyat', 'savunma sanayi'],
        'KRDMD': ['kardemir', 'erdemir', 'çelik', 'krdmd hisse', 'krdmd borsa', 'krdmd fiyat', 'demir çelik'],
        'TUPRS': ['tüpraş', 'tupras', 'petrol', 'rafineri', 'tuprs hisse', 'tuprs borsa', 'tuprs fiyat'],
        'ISCTR': ['iş bankası', 'is bank', 'iş c', 'isctr hisse', 'isctr borsa'],
        'YKBNK': ['yapı kredi', 'yapikredi', 'ykbnk hisse', 'ykbnk borsa'],
        'HALKB': ['halkbank', 'halk bankası', 'halkb hisse', 'halkb borsa'],
        'VAKBN': ['vakıfbank', 'vakifbank', 'vakbn hisse', 'vakbn borsa'],
        'SISE': ['şişecam', 'sisecam', 'cam', 'sise hisse', 'sise borsa'],
        'BIMAS': ['bim', 'bim market', 'bim mağaza', 'bimas hisse', 'bimas borsa'],
        'EREGL': ['ereğli', 'eregl', 'erdemir', 'eregl hisse', 'eregl borsa', 'demir çelik'],
        'HEKTS': ['hektaş', 'hektas', 'tarım', 'gübre', 'hekts hisse', 'hekts borsa'],
        'SASA': ['sasa', 'sasa polyester', 'petrokimya', 'sasa hisse', 'sasa borsa'],
        'FROTO': ['ford otosan', 'ford', 'otosan', 'froto hisse', 'froto borsa'],
        'TOASO': ['tofaş', 'tofas', 'fiat', 'toaso hisse', 'toaso borsa'],
        'KCHOL': ['koç holding', 'kocholding', 'kchol hisse', 'kchol borsa'],
        'SAHOL': ['sabancı holding', 'sabanci', 'sahol hisse', 'sahol borsa'],
        'DOFRB': ['dofer', 'dofrb hisse', 'dofrb borsa'],
        'BORLS': ['borlease', 'borlease otomotiv', 'borls hisse', 'borls borsa', 'borlease otm'],
        'TUREX': [
            'turex', 'tureks turizm', 'tureks turizm taşımacılık', 'turex turizm',
            'personel taşımacılığı', 'servis taşımacılığı', 'turex hisse', 'turex borsa'
        ],
        'KSTUR': [
            'kstur', 'köstur', 'koster turizm', 'kostur turizm', 'turizm taşımacılık',
            'kstur hisse', 'kstur borsa'
        ],
        'TKFEN': [
            'tekfen', 'tekfen holding', 'tekfen inşaat', 'tekfen tarım',
            'tkfen hisse', 'tkfen borsa'
        ],
    }

    # İsteğe bağlı: Haber filtrelemede kullanılacak şirket isimleri
    STOCK_NAMES = {
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
        'TUREX': 'Tureks Turizm Taşımacılık A.Ş.',
        'KSTUR': 'KSTUR Turizm Taşımacılık A.Ş.',
        'TKFEN': 'Tekfen Holding A.Ş.',
    }
    
    # ==================== DUYARLILIK ANALİZİ KELİMELERİ ====================
    # Pozitif duyarlılık için anahtar kelimeler
    POSITIVE_WORDS = [
        'artış', 'yükseliş', 'büyüme', 'kar', 'kazanç', 'olumlu', 'güçlü',
        'iyileşme', 'gelişme', 'başarı', 'rekor', 'yükseldi', 'arttı',
        'yükselme', 'güçlenme', 'iyileşme', 'olumlu', 'başarılı', 'pozitif',
        'güçlü performans', 'yükselen trend', 'iyi haber', 'olumlu gelişme',
        'büyüyen', 'gelişen', 'güçlenen', 'artış gösteren', 'yükseliş trendi',
        'başarılı sonuç', 'olumlu rapor', 'güçlü büyüme', 'pozitif beklenti'
    ]
    
    # Negatif duyarlılık için anahtar kelimeler
    NEGATIVE_WORDS = [
        'düşüş', 'kayıp', 'zarar', 'kriz', 'olumsuz', 'zayıf', 'düştü',
        'azaldı', 'kaybetti', 'sorun', 'risk', 'tehlike', 'düşük',
        'düşme', 'zayıflama', 'kayıp', 'olumsuz', 'başarısız', 'negatif',
        'zayıf performans', 'düşen trend', 'kötü haber', 'olumsuz gelişme',
        'küçülen', 'gerileyen', 'zayıflayan', 'düşüş gösteren', 'düşüş trendi',
        'başarısız sonuç', 'olumsuz rapor', 'zayıf büyüme', 'negatif beklenti'
    ]
    
    # ==================== RİSK UYARISI ====================
    # Her analizde gösterilecek risk uyarısı mesajı
    RISK_WARNING = """
⚠️ RİSK UYARISI ⚠️

Bu bot sadece bilgilendirme amaçlıdır ve yatırım tavsiyesi değildir.
BIST hisse yatırımları risk taşır ve sermayenizi kaybedebilirsiniz.
Her zaman kendi araştırmanızı yapın ve risk yönetimi uygulayın.
Geçmiş performans gelecekteki sonuçların garantisi değildir.
    """

    # ==================== NEWSAPI AYARI ====================
    NEWSAPI_KEY = os.getenv('NEWSAPI_KEY')
