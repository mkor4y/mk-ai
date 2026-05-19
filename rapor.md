# MK AI — Teknik Rapor

Bu rapor, **MK AI** (BIST Akıllı Yatırım Asistanı) ekosisteminin mimarisini, modüllerini ve teknolojilerini özetler. Proje; yaklaşık bir ay önce basit bir Telegram botundan başlayıp **FastAPI**, **Flutter mobil**, **web** ve **AI katmanları** ile genişlemiştir.

**Güncelleme:** Mayıs 2026

---

## Genel Bakış

| Bileşen | Açıklama |
|---------|----------|
| **Amaç** | BIST yatırımcılarına çok kanallı, AI destekli karar desteği |
| **Veri** | TradingView (tvdatafeed-enhanced), RSS, NewsAPI |
| **AI** | Groq (Llama), OpenRouter (DeepSeek) |
| **Mobil** | Flutter + Riverpod + Dio |
| **API** | FastAPI, cPanel Passenger (ASGI) |

### Ana yetkinlikler

- Teknik analiz (RSI, MACD, MA, Bollinger, ADX, hacim, gap)
- Trading sinyalleri (AL/SAT/BEKLE, güven skoru, risk)
- Haber toplama ve duyarlılık skoru
- AI analiz ve sohbet
- REST API + Telegram + Flutter mobil + Web

---

## Sistem Mimarisi

```
┌─────────────────────────────────────────────────────────────┐
│  Flutter Mobil │ Next.js Web │ Telegram │ Electron          │
├─────────────────────────────────────────────────────────────┤
│                    FastAPI (api/main.py)                     │
├──────────────┬─────────────────┬───────────────────────────┤
│ BISTAnalyzer │   NewsHelper    │     ChatGPTHelper         │
├──────────────┴─────────────────┴───────────────────────────┤
│ TradingView · RSS/NewsAPI · Groq · OpenRouter               │
└─────────────────────────────────────────────────────────────┘
```

---

## REST API (`api/main.py`)

Canlı taban: `https://m-koray.online/api`

| Endpoint | Metod | Açıklama |
|----------|-------|----------|
| `/` | GET | Health check |
| `/api/market/summary` | GET | Endeks + watchlist; ThreadPoolExecutor + 60 sn TTL cache |
| `/api/analyze/{code}` | GET | Tam analiz (teknik + haber + AI) |
| `/api/chart/{code}` | GET | OHLCV; `range`: 1H, 1A, 3A, 6A, 1Y |
| `/api/quotes` | GET | Batch fiyat; `?codes=THYAO,GARAN` (max 25) |
| `/api/news` | GET | Haber listesi, görsel URL, sentiment, HTML temizleme |
| `/api/chat` | POST | AI sohbet yanıtı |

**Deploy:** `passenger_wsgi.py` → `a2wsgi.ASGIMiddleware` ile WSGI/ASGI köprüsü.

---

## Flutter Mobil (`mobile/`)

### State management
- **Riverpod:** `marketSummaryProvider`, `analysisProvider`, `chartDataProvider`, `newsListProvider`, `portfolioProvider`, `chatMessagesProvider`, `favoritesProvider`, `userProfileProvider`, `stockQuotesProvider`

### Ekranlar
| Ekran | Dosya | Özet |
|-------|-------|------|
| Dashboard | `screens/dashboard/` | BIST 100, endeksler, quick actions, watchlist |
| Analiz | `screens/analysis/` | Grafik, göstergeler, AI kart |
| Haberler | `screens/news/` | Filtre, arama, bookmark, webview |
| Chat | `screens/chat/` | Markdown bubble, geçmiş, öneriler |
| Portföy | `screens/portfolio/` | Holding CRUD, P/L, sektör pie |
| Ayarlar | `screens/settings/` | Profil, API test, veri silme |

### Kalıcı depolama
- `shared_preferences`: favoriler, portföy, sohbet, profil, okunan/kaydedilen haberler

### Konfigürasyon
- `app_config.dart`: API URL önceliği — dart-define → `.env` → production fallback
- `pubspec.yaml`: `.env` asset olarak bundle

### CI/CD
- `codemagic.yaml`: iOS unsigned IPA, Android APK
- `docs/IOS_SIDELOADING.md`: Sideloadly rehberi

---

## Mimari Bileşenler (Backend / Bot)

### 1. `main.py` — BISTBot (Telegram)

- **Sınıf:** `BISTBot`
- Komutlar: `/start`, `/help`, `/menu`, `/analyze`, `/price`, `/education`
- `perform_stock_analysis`: BISTAnalyzer → NewsHelper → ChatGPTHelper → birleşik rapor
- Uzun mesaj bölme (4096 karakter limiti)

### 2. `bist_analyzer.py` — Teknik Analiz

- **Veri:** `tvdatafeed-enhanced`, `BIST:SYMBOL`, günlük OHLCV, in-memory cache
- **Göstergeler:** RSI, MACD, MA20–200, Bollinger, ADX, hacim oranı, gap
- **Sinyaller:** `_calculate_overall_signal` — ağırlıklı skor, güven %, risk, trend rejimi

### 3. `news_helper.py` — Haber

- RSS (`Config.RSS_FEED_URLS`) + NewsAPI
- `filter_news_by_stock`, `_calculate_sentiment` (-1 … +1)
- `_extract_image_url` — mobil haber görselleri için
- `get_stock_news_summary`, `format_news_for_ai`

### 4. `chatgpt_helper.py` — AI

- OpenRouter / Groq client
- `get_stock_analysis`, `get_educational_content`, `get_help_content`
- Sistem prompt: BIST odaklı, risk uyarısı, tavsiye değil bilgilendirme

### 5. `config.py` — Konfigürasyon

- `SUPPORTED_BIST_STOCKS`, `STOCK_KEYWORDS`, `RSS_FEED_URLS`
- RSI/MACD/ADX parametreleri, `RISK_WARNING`

---

## Kullanılan Teknolojiler

| Alan | Paket / Araç |
|------|----------------|
| Backend | Python 3.11+, FastAPI, uvicorn, pandas, numpy, ta |
| Veri | tvdatafeed-enhanced, websocket-client |
| Haber | feedparser, requests |
| AI | openai SDK, Groq, OpenRouter |
| Bot | python-telegram-bot 20.x |
| Mobil | Flutter, Riverpod, Dio, fl_chart, shared_preferences, cached_network_image |
| Web | Next.js, TypeScript |
| Deploy | cPanel Passenger, a2wsgi, Codemagic |

---

## Kullanıcı Akışları

### Mobil
1. Dashboard → piyasa özeti yüklenir (`/api/market/summary`)
2. Analiz → THYAO seç → grafik + `/api/analyze/THYAO`
3. Portföy → pozisyon ekle → `/api/quotes` ile canlı fiyat
4. Haber → tıkla → webview; duyarlılık rengi

### Telegram
- `/analyze THYAO` → tek mesajda tam rapor

### API (üçüncü parti)
- REST JSON; OpenAPI `/docs`

---

## Sınırlamalar

- TradingView verisi resmi BIST feed değildir; gecikme olabilir
- Temel veriler (P/E, temettü) kısıtlı
- AI çıktıları olasılıksal; yatırım tavsiyesi değildir
- Hisse whitelist sınırlı (genişletilebilir)
- Ücretsiz Apple ID ile iOS sideload 7 gün geçerlilik

---

## Geliştirme Fırsatları

- [x] Flutter mobil MVP
- [x] REST API chart + quotes
- [x] Market summary cache
- [ ] Transformer tabanlı sentiment
- [ ] Tüm BIST hisseleri
- [ ] Push notification
- [ ] Backtesting
- [ ] Kullanıcı bulut hesabı

---

## İlgili Dosyalar

| Dosya | Açıklama |
|-------|----------|
| `README.md` | Kurulum ve genel bakış |
| `aciklama.md` | Kısa tanıtım |
| `BASVURU_DOKUMANI.md` | Hackathon başvurusu |
| `oku.txt` | Flutter komutları |

---

*Bu rapor kod tabanıyla birlikte güncellenmelidir.*
