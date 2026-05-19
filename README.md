# MK AI — Akıllı Yatırım Asistanı

Borsa İstanbul (BIST) yatırımcıları için yapay zekâ destekli karar destek platformu. Teknik analiz, haber duyarlılığı ve AI yorumlarını **mobil uygulama**, **REST API**, **Telegram bot** ve **web panel** üzerinden sunar.

> ⚠️ **Yatırım tavsiyesi değildir.** Bilgilendirme amaçlıdır. Kendi araştırmanıza dayanın.

**Canlı API:** https://m-koray.online/api  
**GitHub:** https://github.com/mkor4y/mk-ai

---

## Özellikler

### Mobil (Flutter)
- Dashboard (BIST 100, endeksler, favoriler, top movers)
- Hisse analizi + OHLCV grafik + teknik göstergeler + AI kartı
- Haberler (kategori, arama, duyarlılık, kaydetme, in-app webview)
- AI sohbet (markdown, geçmiş, hisse linkleri)
- Portföy takibi (P/L, sektör dağılımı)
- Ayarlar ve profil

### Backend (FastAPI)
- Piyasa özeti (paralel fetch + 60 sn cache)
- Hisse analizi, grafik verisi, batch fiyat (`/api/quotes`)
- Haber akışı (görsel + sentiment)
- AI chat endpoint

### Telegram Bot
- `/analyze`, `/price`, `/menu`, `/education`
- Anlık analiz ve AI yorumu

### Teknik analiz
- RSI, MACD, Bollinger, ADX, hareketli ortalamalar
- AL / SAT / BEKLE sinyalleri, güven skoru (%), risk seviyesi

### Haber
- 12+ RSS kaynağı + NewsAPI
- Anahtar kelime eşleştirme, duyarlılık skoru

### AI
- OpenRouter (DeepSeek), Groq (Llama 3.3)
- Yapılandırılmış analiz promptları

---

## Proje Yapısı

```
mymodel/
├── api/                    # FastAPI (canlı deploy)
│   ├── main.py
│   └── requirements.txt
├── mobile/                 # Flutter uygulama
│   ├── lib/
│   ├── pubspec.yaml
│   └── .env.example
├── web/                    # Next.js dashboard
├── electron/               # Masaüstü
├── main.py                 # Telegram bot
├── bist_analyzer.py
├── news_helper.py
├── chatgpt_helper.py
├── config.py
├── passenger_wsgi.py       # cPanel ASGI
├── codemagic.yaml          # iOS/Android CI
├── BASVURU_DOKUMANI.md     # BTK Yapay Zeka Hackathon
├── docs/IOS_SIDELOADING.md
├── oku.txt                 # Sadece Flutter komutları
└── requirements.txt
```

---

## Hızlı Başlangıç

### 1. Gereksinimler
- Python 3.11+
- Flutter 3.x (mobil için)
- Node.js 18+ (web için)
- Telegram Bot Token, OpenRouter veya Groq API key

### 2. Backend (yerel)

```bash
cd C:\mymodel
python -m venv venv
venv\Scripts\activate
pip install -r requirements.txt
# .env dosyasını .env.example şablonundan oluştur
python -m uvicorn api.main:app --host 0.0.0.0 --port 8000 --reload
```

API dokümantasyonu: http://localhost:8000/docs

### 3. Flutter mobil

```bash
cd mobile
copy .env.example .env
flutter pub get
flutter run
```

Tüm Flutter komutları: **`oku.txt`**

### 4. Telegram bot

```bash
# Proje kökünde, venv aktif
python main.py
```

### 5. Web

```bash
cd web
npm install
npm run dev
```

---

## Ortam Değişkenleri

Kök `.env` (backend / bot) — şablon: `.env.example`

```env
TELEGRAM_TOKEN=...
OPENROUTER_API_KEY=...
GROQ_API_KEY=...
AI_PROVIDER=groq
LOG_LEVEL=INFO
```

Mobil `mobile/.env`:

```env
API_BASE_URL=https://m-koray.online/api
```

> `.env` dosyalarını repoya commit etmeyin.

---

## API Örnekleri

```bash
curl https://m-koray.online/api/
curl https://m-koray.online/api/api/market/summary
curl https://m-koray.online/api/api/analyze/THYAO
curl "https://m-koray.online/api/api/quotes?codes=THYAO,GARAN"
```

---

## Desteklenen Hisseler (örnek)

THYAO, GARAN, AKBNK, ASELS, KRDMD, TUPRS, ISCTR, YKBNK, HALKB, VAKBN, SISE, BIMAS, EREGL, HEKTS, SASA, FROTO, TOASO, KCHOL, SAHOL, DOFRB, BORLS, TUREX, KSTUR, TKFEN — **24+ hisse** (`config.py` / `AppConfig` ile senkron).

---

## cPanel / Production API

- `passenger_wsgi.py` + `a2wsgi` ile FastAPI ASGI
- `api/` klasörü + kök helper modülleri birlikte deploy edilmeli
- Bağımlılıklar: `api/requirements.txt` veya kök `requirements.txt`

---

## Codemagic (mobil build)

- Workflow: **iOS Unsigned IPA (Sideloadly)** — ücretsiz Apple ID ile yükleme
- Workflow: **Android Unsigned APK**
- Detay: `docs/IOS_SIDELOADING.md`

---

## Geliştirme Notları

### Yeni hisse ekleme
`config.py` → `SUPPORTED_BIST_STOCKS` ve `STOCK_KEYWORDS`  
`mobile/lib/config/app_config.dart` → `supportedStocks` (mobil whitelist)

### Risk uyarısı
Tüm kullanıcı çıktılarında yatırım tavsiyesi olmadığı belirtilir.

---

## Dokümantasyon

| Dosya | İçerik |
|-------|--------|
| `BASVURU_DOKUMANI.md` | BTK Yapay Zeka Hackathon başvurusu |
| `aciklama.md` | Kısa proje özeti |
| `rapor.md` | Teknik mimari raporu |
| `oku.txt` | Flutter komutları |
| `docs/IOS_SIDELOADING.md` | iPhone yükleme rehberi |

---

## Geliştirici

**Mustafa Koray Kök**

---

## Lisans

Eğitim ve kişisel geliştirme amaçlıdır. Ticari kullanım için ayrı değerlendirme gerekebilir.
