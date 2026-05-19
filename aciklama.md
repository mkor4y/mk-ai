# MK AI — BIST Akıllı Yatırım Asistanı

## Proje Özeti

**MK AI**, Borsa İstanbul (BIST) yatırımcıları için geliştirilmiş, yapay zekâ destekli kapsamlı bir karar destek platformudur. Yaklaşık bir ay önce geliştirmeye başlanan **basit BIST Telegram botu**, bugün **çok kanallı ve manipülasyona karşı çok katmanlı** bir ekosisteme dönüşmüştür.

Platform; teknik analiz, haber duyarlılığı ve AI yorumlarını bir araya getirir. **Yatırım tavsiyesi vermez** — bilgilendirme amaçlıdır.

**Geliştirici:** Mustafa Koray Kök  
**Canlı API:** https://m-koray.online/api  
**GitHub:** https://github.com/mkor4y/mk-ai

---

## Problem ve Çözüm

### Problem
- Analiz araçları dağınık, pahalı veya İngilizce ağırlıklı
- Haberlerin fiyat üzerindeki etkisi zaman alıcı analiz gerektirir
- Sosyal medyada tek kaynaklı yanıltıcı yönlendirmeler

### Çözüm
- **Otomatik teknik analiz** (RSI, MACD, Bollinger, ADX, MA)
- **12+ kaynaktan haber** + duyarlılık skoru (pozitif/negatif/nötr)
- **AI destekli yorum** (Groq / OpenRouter)
- **Çok kanallı erişim:** Flutter mobil, Web, Telegram, REST API

---

## Platformlar

| Kanal | Teknoloji | Durum |
|-------|-----------|--------|
| **Mobil** | Flutter, Riverpod | ✅ MVP |
| **API** | FastAPI, Python | ✅ Canlı |
| **Telegram** | python-telegram-bot | ✅ |
| **Web** | Next.js, TypeScript | ✅ |
| **Desktop** | Electron | ✅ |

---

## Mobil Uygulama Özellikleri

- **Dashboard:** BIST 100, endeksler, favoriler, top movers, izleme listesi
- **Analiz:** OHLCV grafik, teknik göstergeler, AI karar kartı
- **Haberler:** Kategori, arama, duyarlılık renkleri, kaydetme, webview
- **AI Chat:** Markdown, geçmiş, hisse linkleri
- **Portföy:** Pozisyon, canlı P/L, sektör dağılımı
- **Ayarlar:** Profil, API testi, veri yönetimi

---

## Backend Modülleri

- `bist_analyzer.py` — TradingView verisi + teknik göstergeler + sinyaller
- `news_helper.py` — RSS + NewsAPI + duyarlılık
- `chatgpt_helper.py` — LLM analiz ve sohbet
- `api/main.py` — REST API (market, analyze, chart, quotes, news, chat)

---

## API Uçları (özet)

| Endpoint | Açıklama |
|----------|----------|
| `GET /api/market/summary` | Piyasa özeti (cache + paralel) |
| `GET /api/analyze/{code}` | Kapsamlı analiz |
| `GET /api/chart/{code}?range=` | OHLCV grafik |
| `GET /api/quotes?codes=` | Batch fiyat (portföy) |
| `GET /api/news` | Haber + sentiment + görsel |
| `POST /api/chat` | AI sohbet |

---

## Manipülasyona Dayanıklı Tasarım

- Teknik göstergeler **kural tabanlı** (matematiksel)
- Haberler **çok kaynaklı** + skor
- AI yorumu **yapılandırılmış prompt** ile teknik + haber verisine dayanır
- Her çıktıda **risk uyarısı** ve güven skoru

---

## Demo

| Kanal | Erişim |
|-------|--------|
| Telegram | `/analyze THYAO` |
| API | https://m-koray.online/api/docs |
| Mobil | `flutter run` (bkz. `oku.txt`) |
| Web | `http://localhost:3000/dashboard` |

---

## Gelecek Planları

- [ ] Tüm BIST hisseleri
- [ ] Push / fiyat alarmları
- [ ] Bulut hesap senkronizasyonu
- [ ] Gelişmiş NLP duyarlılık
- [ ] Backtesting

---

## Sorumluluk Reddi

Bu platform yalnızca bilgilendirme amaçlıdır; yatırım tavsiyesi değildir. Geçmiş performans gelecekteki sonuçların garantisi değildir. BIST yatırımları risk taşır.

---

*Detaylı başvuru: `BASVURU_DOKUMANI.md` · Teknik rapor: `rapor.md` · Flutter komutları: `oku.txt`*
