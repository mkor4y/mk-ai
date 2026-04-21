# 🤖 BIST Analiz Telegram Botu

Borsa İstanbul (BIST) hisse senetleri için kapsamlı analiz yapan akıllı Telegram botu. Teknik analiz, haber analizi ve AI destekli yorumlar sunar.

## 📊 Özellikler

### 🎯 Ana Özellikler
- **📊 Hisse Analizi**: Kapsamlı teknik ve temel analiz
- **💰 Fiyat Sorgulama**: Anlık fiyat ve değişim bilgileri
- **📰 Haber Analizi**: RSS feed'lerden haber toplama ve duyarlılık analizi
- **🤖 AI Destekli Yorumlar**: OpenRouter (DeepSeek) ile akıllı analiz
- **📚 Eğitim İçerikleri**: Yatırım eğitimi ve ipuçları

### 📈 Teknik Analiz
- **RSI (Relative Strength Index)**: Aşırı alım/satım seviyeleri
- **MACD**: Trend değişim sinyalleri
- **Moving Averages**: 20, 50, 200 günlük ortalamalar
- **Bollinger Bands**: Volatilite analizi
- **Hacim Analizi**: Hacim bazlı sinyaller

### 🎯 Trading Sinyalleri
- **AL/SAT/BEKLE** sinyalleri
- **Güven skoru** (0-100%)
- **Sinyal gücü** (Zayıf/Güçlü/Çok Güçlü)
- **Risk seviyesi** belirleme

### 📰 Haber Analizi
- **10 farklı RSS kaynağı**ndan haber toplama
- **Son 3 günlük** haberler
- **Hisse eşleştirme** (anahtar kelimelerle)
- **Duyarlılık analizi** (pozitif/negatif skor)

## 🚀 Kurulum

### 1. Gereksinimler
- Python 3.8+
- Telegram Bot Token
- OpenRouter API Key

### 2. Proje Kurulumu
```bash
# Projeyi klonla
git clone <repository-url>
cd bist-analiz-bot

# Sanal ortam oluştur
python -m venv venv

# Sanal ortamı aktifleştir
# Windows:
venv\Scripts\activate
# Linux/Mac:
source venv/bin/activate

# Gerekli kütüphaneleri yükle
pip install -r requirements.txt
```

### 3. API Anahtarları
`.env` dosyası oluşturun (**repo'ya koymayın, public paylaşmayın**):
```env
TELEGRAM_TOKEN=your_telegram_bot_token
OPENROUTER_API_KEY=your_openrouter_api_key
LOG_LEVEL=INFO
```

> Not: Örnek şablon için `env.sample` dosyasını kullanabilirsiniz.

### 4. Bot'u Çalıştır
```bash
python main.py
```

## 🧩 cPanel'de Çalıştırma (Sadece Telegram Bot)

Bu bot **polling** ile çalışır; yani process'in arka planda sürekli açık kalması gerekir.

### 1) Python bağımlılıklarını kur
- cPanel → **Setup Python App** ile bir app oluşturun (Python 3.10/3.11 önerilir)
- App root olarak proje klasörünü seçin
- Ardından:

```bash
pip install -r requirements.txt
```

### 2) Environment Variables (önerilen)
cPanel ekranından env girin (dosya yerine):
- `TELEGRAM_TOKEN`
- `OPENROUTER_API_KEY` veya `GROQ_API_KEY`
- `AI_PROVIDER` (`groq` / `openrouter`)
- `LOG_LEVEL`

### 3) Botu tek instance olarak başlat (Cron + flock)
Supervisor/daemon yoksa en güvenli yöntem: **cron + lock**.

1) `scripts/run_bot.sh` dosyasını çalıştırılabilir yapın:

```bash
chmod +x scripts/run_bot.sh
```

2) cPanel → **Cron Jobs** → her dakika çalıştırın (örnek):

```bash
/bin/bash -lc 'cd ~/bist-analiz-bot && PYTHON_BIN=python scripts/run_bot.sh'
```

> `flock` sayesinde cron her dakika tetiklense bile bot ikinci kez başlamaz.

## 📋 Kullanım

### Komutlar
- `/start` - Bot'u başlat
- `/menu` - Ana menü
- `/analyze [HİSSE]` - Hisse analizi (örn: `/analyze THYAO`)
- `/price [HİSSE]` - Fiyat sorgulama (örn: `/price GARAN`)
- `/education` - Eğitim içerikleri
- `/help` - Yardım

### Desteklenen Hisse Kodları
- **THYAO** - Türk Hava Yolları
- **GARAN** - Garanti Bankası
- **AKBNK** - Akbank
- **ASELS** - Aselsan
- **KRDMD** - Kardemir
- **TUPRS** - Tüpraş

## 🏗️ Proje Yapısı

```
bist-analiz-bot/
├── main.py              # Ana bot dosyası
├── config.py            # Konfigürasyon ayarları
├── bist_analyzer.py     # BIST analiz modülü
├── news_helper.py       # Haber analizi modülü
├── chatgpt_helper.py    # AI entegrasyon modülü
├── requirements.txt     # Gerekli kütüphaneler
├── .env                 # API anahtarları
├── README.md           # Bu dosya
└── archive/            # Eski kodlar
```

## 🔧 Teknik Detaylar

### Veri Kaynakları
- **yfinance**: BIST hisse verileri (ücretsiz)
- **RSS Feeds**: Haber kaynakları
- **OpenRouter**: AI analizi (DeepSeek modeli)

### Teknik Analiz Algoritmaları
- **Ağırlıklı Skor Sistemi**: RSI ve MACD daha önemli
- **Güven Skoru**: 0-100 arası normalize edilmiş
- **Risk Seviyesi**: Düşük/Orta/Yüksek kategorileri

### Haber Analizi
- **10 RSS Kaynağı**: Anadolu Ajansı, Bloomberg, Reuters, vs.
- **Anahtar Kelime Eşleştirme**: Her hisse için özel kelimeler
- **Duyarlılık Analizi**: Pozitif/negatif kelime sayımı

## ⚠️ Önemli Notlar

### Risk Uyarısı
- Bu bot sadece **bilgilendirme amaçlıdır**
- **Yatırım tavsiyesi değildir**
- Her zaman kendi araştırmanızı yapın
- Risk yönetimi uygulayın
- Geçmiş performans gelecekteki sonuçların garantisi değildir

### Teknik Sınırlamalar
- **yfinance** veri kalitesi değişebilir
- **RSS feed'ler** bazen erişilemeyebilir
- **AI analizi** tahmin amaçlıdır, kesin değildir
- **Rate limiting** uygulanmıştır

## 🛠️ Geliştirme

### Yeni Hisse Ekleme
`config.py` dosyasında:
```python
SUPPORTED_BIST_STOCKS = [
    'THYAO', 'GARAN', 'AKBNK', 'ASELS', 'KRDMD', 'TUPRS',
    'YENI_HISSE'  # Yeni hisse ekle
]

STOCK_KEYWORDS = {
    'YENI_HISSE': ['anahtar', 'kelimeler', 'buraya']  # Anahtar kelimeler
}
```

### Yeni RSS Kaynağı Ekleme
```python
RSS_FEED_URLS = {
    'yeni_kaynak': 'https://yeni-kaynak.com/rss'  # Yeni RSS feed
}
```

### Teknik Analiz Parametreleri
```python
# RSI ayarları
RSI_PERIOD = 14
RSI_OVERSOLD = 30
RSI_OVERBOUGHT = 70

# MACD ayarları
MACD_FAST = 12
MACD_SLOW = 26
MACD_SIGNAL = 9
```

## 📞 Destek

### Hata Raporlama
- Log dosyası: `bist_bot.log`
- Hata detayları için log seviyesini `DEBUG` yapın

### Öneriler
- Yeni özellik önerileri için issue açın
- Kod iyileştirmeleri için pull request gönderin

## 📄 Lisans

Bu proje eğitim amaçlı geliştirilmiştir. Ticari kullanım için lisans gerekebilir.

## 🤝 Katkıda Bulunanlar

- **Geliştirici**: [Adınız]
- **AI Modeli**: DeepSeek (OpenRouter)
- **Veri Kaynakları**: Yahoo Finance, RSS Feeds

---

**⚠️ UYARI**: Bu bot sadece bilgilendirme amaçlıdır. Yatırım kararlarınızı kendi araştırmanıza dayandırın.
