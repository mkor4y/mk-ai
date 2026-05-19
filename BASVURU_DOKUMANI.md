# MK AI — BTK Yapay Zeka Hackathon Başvuru Dokümanı

---

## Başvuru Özeti

| Alan | Bilgi |
|------|--------|
| **Yarışma** | BTK Yapay Zeka Hackathon |
| **Proje Adı** | MK AI — Akıllı Yatırım Asistanı |
| **Slogan** | *Akıllı Yatırım Asistanı* |
| **Geliştirici / Takım** | Mustafa Koray Kök |
| **Kategori** | Yapay Zekâ · FinTech · Karar Destek Sistemleri |
| **Hedef Pazar** | Türkiye — Borsa İstanbul (BIST)  yatırımcıları |
| **Durum** | Çalışan MVP (API + Mobil + Telegram + Web) |
| **Güncelleme** | Mayıs 2026 |

---

## 1. Proje Özeti ve Gelişim Hikayesi

**MK AI**, **çok kanallı, yapay zekâ destekli ve manipülasyona karşı çok katmanlı kurgulanmış** bir karar destek ekosistemine dönüşmüştür.

İlk sürümde yalnızca temel fiyat sorgulama ve sınırlı analiz vardı. Kullanıcı geri bildirimleri ve teknik ihtiyaçlar doğrultusunda sistem; **FastAPI REST API**, **Flutter mobil uygulama**, **web panel**, **Telegram bot** ve **yapay zekâ sohbet katmanı** ile genişletildi. Amaç, yatırımcının tek bir kaynağa veya yüzeysel sinyale bağımlı kalmadan; **ölçülebilir teknik göstergeler**, **haber duyarlılığı** ve **yapılandırılmış AI yorumları** ile bilinçli karar vermesine yardımcı olmaktır.

> **Önemli:** MK AI yatırım tavsiyesi vermez; bilgilendirme ve analiz amaçlıdır. Tüm yatırım kararları kullanıcının kendi sorumluluğundadır.

---

## 2. Problem Tanımı

### Türkiye'de bireysel yatırımcının sorunları

1. **Yüksek maliyet:** Profesyonel terminal ve analiz araçları bireysel bütçeler için erişilemez düzeydedir.
2. **Bilgi dağınıklığı:** Teknik analiz, haber ve yorum farklı platformlarda; entegre karar desteği zayıftır.
3. **Manipülasyon ve gürültü:** Sosyal medyada tek haber veya yönlendirme ile alınan kararlar yanıltıcı olabilir.
4. **Dil ve yerellik:** Uluslararası araçlar BIST ve Türkçe kullanıcı ihtiyacına tam odaklanmaz.
5. **Finansal okuryazarlık:** RSI, MACD, Bollinger gibi göstergelerin doğru yorumlanması uzmanlık ister.

### Rakamlarla bağlam

- Türkiye'de milyonlarca bireysel yatırımcı hesabı bulunmaktadır (SPK verileri).
- Büyük çoğunluk profesyonel analiz araçlarına erişememektedir.
- Dijital kanallarda hızlı yayılan bilgi kirliliği bilinçli kararı zorlaştırmaktadır.

---

## 3. Çözüm: MK AI

MK AI, yukarıdaki problemleri **tek ekosistemde** ele alır:

| Problem | MK AI yaklaşımı |
|---------|------------------|
| Yüksek maliyet | Freemium / düşük maliyetli erişim hedefi |
| Bilgi dağınıklığı | Teknik analiz + haber + AI tek platformda |
| Manipülasyon / gürültü | Çok kaynaklı haber, kural tabanlı göstergeler, şeffaf skorlar |
| Dil bariyeri | %100 Türkçe arayüz ve yorumlar |
| Okuryazarlık | Eğitim modülü + sadeleştirilmiş AI açıklamaları |

### Sistem akışı

```
Kullanıcı (Mobil / Web / Telegram / API)
        ↓
    FastAPI REST API
        ↓
┌───────────────┬────────────────┬─────────────────┐
│ BIST Analyzer │  News Helper   │  AI Helper      │
│ (Teknik)      │  (Duyarlılık)  │  (LLM yorum)    │
└───────────────┴────────────────┴─────────────────┘
        ↓
TradingView verisi · RSS/NewsAPI · Groq / OpenRouter
        ↓
AL/SAT/BEKLE sinyali · güven skoru · rapor · sohbet yanıtı
```

### Manipülasyondan etkilenmeme yaklaşımı

Sistem, **tek bir başlığa veya sosyal medya yönlendirmesine körü körüne tepki vermez**:

- **Teknik katman:** RSI, MACD, ADX, Bollinger, hareketli ortalamalar — önceden tanımlı matematiksel kurallar.
- **Haber katmanı:** 12+ RSS kaynağı + NewsAPI; anahtar kelime eşleştirme; pozitif/negatif/nötr duyarlılık skoru.
- **AI katmanı:** Tüm teknik ve haber çıktıları yapılandırılmış prompt ile modele verilir; serbest uydurma yerine **bağlama dayalı özet**.
- **Şeffaflık:** Güven skoru, risk seviyesi ve risk uyarısı her analizde gösterilir.

---

## 4. Yapay Zekâ Kullanımı (Hackathon Odak Alanı)

BTK Yapay Zeka Hackathon kapsamında MK AI'nın AI bileşenleri:

| Bileşen | Teknoloji | Kullanım |
|---------|-----------|----------|
| **Hisse analiz özeti** | DeepSeek (OpenRouter), Llama 3.3 (Groq) | Kısa/orta/uzun vadeli beklenti, risk faktörleri |
| **AI Chat** | Aynı LLM sağlayıcıları | Doğal dilde BIST ve teknik analiz soruları |
| **Haber duyarlılığı** | Kural tabanlı NLP (anahtar kelime + skor) | Manipülatif tek kaynak yerine çoklu haber özeti |
| **Sinyal birleştirme** | Kural motoru + AI yorum | AL/SAT/BEKLE ve güven skoru (%0–100) |

### AI çıktılarının sınırları

- Model çıktıları **yatırım tavsiyesi değildir**; kullanıcıya bilgilendirme sunar.
- Teknik göstergeler AI'dan bağımsız hesaplanır; AI yorumu bu verilere dayanır.
- Hata durumunda API anlamlı hata mesajı döner; uygulama çökmez.

---

## 5. Ürün Kanalları ve Özellikler

### 5.1 Flutter Mobil Uygulama (MK AI)

| Modül | Özellikler |
|-------|------------|
| **Dashboard** | BIST 100 hero kart, endeksler, favoriler, top movers, izleme listesi |
| **Analiz** | OHLCV grafik (1H–1Y), RSI/MACD/ADX/MA/Bollinger, AI karar kartı |
| **Haberler** | Kategori, arama, duyarlılık renkleri, kaydetme, in-app webview |
| **AI Chat** | Markdown, geçmiş, hisse linkleri, öneri paneli |
| **Portföy** | Pozisyon ekleme, canlı P/L, sektör pasta grafiği, DCA |
| **Ayarlar** | Profil, bağlantı testi, veri sıfırlama |

**Teknik:** Flutter, Riverpod, Dio, fl_chart, shared_preferences, Codemagic CI/CD.

### 5.2 REST API (FastAPI)

- `GET /api/market/summary` — Paralel fetch + 60 sn TTL cache
- `GET /api/analyze/{code}` — Kapsamlı hisse analizi
- `GET /api/chart/{code}?range=` — OHLCV grafik verisi
- `GET /api/quotes?codes=` — Portföy için batch fiyat
- `GET /api/news` — Haber + görsel + duyarlılık
- `POST /api/chat` — AI sohbet

**Canlı API:** https://m-koray.online/api

### 5.3 Telegram Bot

- `/analyze`, `/price`, `/menu`, `/education` komutları
- Anlık analiz, haber özeti, AI yorumu
- Kurulum gerektirmeden erişim

### 5.4 Web Dashboard (Next.js)

- Piyasa özeti, watchlist, teknik kartlar
- PWA desteği

### 5.5 Desktop (Electron)

- Masaüstü deneyimi (mevcut kod tabanı)

---

## 6. Teknik Mimari

```
┌─────────────────────────────────────────────────────────────┐
│                    KULLANICI KATMANI                         │
├──────────┬──────────┬────────────┬───────────┬──────────────┤
│ Flutter  │   Web    │  Telegram  │  Desktop  │  3. parti    │
│  Mobil   │ Next.js  │    Bot     │ Electron  │  entegrasyon │
├──────────┴──────────┴────────────┴───────────┴──────────────┤
│              FastAPI REST API (ASGI / cPanel Passenger)      │
├──────────────┬─────────────────┬───────────────────────────┤
│ BISTAnalyzer │   NewsHelper    │      ChatGPTHelper          │
├──────────────┴─────────────────┴───────────────────────────┤
│ TradingView · RSS/NewsAPI · Groq · OpenRouter                │
└─────────────────────────────────────────────────────────────┘
```

### Teknoloji yığını

| Katman | Teknoloji |
|--------|-----------|
| Backend | Python 3.11+, FastAPI, pandas, numpy, ta |
| Mobil | Flutter 3.x, Dart, Riverpod |
| Web | Next.js, TypeScript, React |
| Bot | python-telegram-bot |
| Veri | tvdatafeed-enhanced (TradingView) |
| AI | OpenRouter (DeepSeek), Groq (Llama 3.3) |
| Deploy | cPanel Passenger, Codemagic (iOS/Android build) |

### Desteklenen BIST hisseleri (örnek)

THYAO, GARAN, AKBNK, ASELS, KRDMD, TUPRS, ISCTR, YKBNK, HALKB, VAKBN, SISE, BIMAS, EREGL, HEKTS, SASA, FROTO, TOASO, KCHOL, SAHOL ve diğerleri — **24+ hisse**, genişletilebilir whitelist.

---

## 7. Değer Önerisi ve Hackathon Katkısı

**MK AI**, yapay zekâyı finansal okuryazarlığı artırmak ve bireysel yatırımcıya **şeffaf, çok kaynaklı karar desteği** sunmak için kullanır:

- **Demokratikleştirme:** Profesyonel düzey analiz mantığını erişilebilir kanallara taşır.
- **Yerellik:** BIST ve Türkçe odaklı; uluslararası generic araçların boşluğunu doldurur.
- **AI etiği:** Tavsiye değil bilgilendirme; risk uyarısı zorunlu.
- **Ölçeklenebilir mimari:** REST API ile üçüncü parti ve kurumsal entegrasyona açık.

---

## 8. Rekabet ve Farklılaşma

| Özellik | Klasik terminal | Genel finans siteleri | **MK AI** |
|---------|-----------------|----------------------|-----------|
| BIST odaklı | Kısmen | Kısmen | ✅ |
| Türkçe AI sohbet | ❌ | ❌ | ✅ |
| Haber duyarlılık (çok kaynak) | ❌ | Kısmen | ✅ |
| Telegram + Mobil + API | ❌ | Kısmen | ✅ |
| Manipülasyona dayanıklı çok katman | ❌ | ❌ | ✅ (tasarım hedefi) |
| Düşük maliyet / freemium | ❌ | Reklamlı | ✅ hedef |

---

## 9. Yol Haritası

### Faz 1 — MVP (Tamamlandı ✅)

- [x] Telegram bot ve teknik analiz motoru
- [x] Haber toplama ve duyarlılık skoru
- [x] AI entegrasyonu (Groq + OpenRouter)
- [x] FastAPI REST API ve cPanel deploy
- [x] Flutter mobil uygulama (Dashboard, Analiz, Haber, Chat, Portföy, Ayarlar)
- [x] Web dashboard ve Electron
- [x] Codemagic iOS/Android build pipeline

### Faz 2 — Büyüme (2026)

- [ ] Tüm BIST hisselerine genişleme
- [ ] Gelişmiş NLP duyarlılık (transformer tabanlı)
- [ ] Push notification / fiyat alarmları
- [ ] Kullanıcı hesabı ve bulut senkronizasyonu
- [ ] Backtesting modülü

### Faz 3 — Ölçekleme (2026–2027)

- [ ] Premium abonelik ve ödeme
- [ ] B2B API lisanslama
- [ ] Kripto / forex genişlemesi (opsiyonel)
- [ ] Kurumsal aracı kurum entegrasyonları

---

## 10. Demo ve Değerlendirme Kriterleri

### Canlı demo adresleri

| Kanal | Adres / Erişim |
|-------|----------------|
| **API** | https://m-koray.online/api |
| **API Docs** | https://m-koray.online/api/docs |
| **GitHub** | https://github.com/mkor4y/mk-ai |
| **Mobil** | Flutter APK / iOS (Codemagic artifact + Sideloadly) |
| **Telegram** | Bot komutu: `/analyze THYAO` |

### Jüri için önerilen demo akışı (5 dk)

1. **API health:** `GET /` → `status: running`
2. **Piyasa:** `GET /api/market/summary` → BIST 100 + watchlist
3. **Analiz:** `GET /api/analyze/THYAO` → teknik + sinyal + AI özeti
4. **Mobil:** Dashboard → THYAO analiz → haber duyarlılığı → AI chat sorusu
5. **Manipülasyon vurgusu:** Tek haber yerine çok kaynak + kural tabanlı RSI/MACD + risk uyarısı

---

## 11. SWOT Analizi

| Güçlü | Zayıf |
|-------|-------|
| Çalışan çok kanallı MVP | Sınırlı hisse whitelist (genişletilebilir) |
| AI + teknik + haber entegrasyonu | Tek kişilik geliştirme ekibi |
| Türkçe, BIST odaklı | Marka bilinirliği yeni |
| Düşük operasyon maliyeti hedefi | Temel veriler (P/E) kısmen eksik |

| Fırsat | Tehdit |
|--------|--------|
| Büyüyen bireysel yatırımcı tabanı | SPK / düzenleyici gereksinimler |
| AI maliyetlerinin düşmesi | Büyük oyuncuların benzer ürünü |
| FinTech yatırım ilgisi | Veri kaynağı erişim kısıtları |

---

## 12. Ekip

**Mustafa Koray Kök** — Kurucu ve full-stack geliştirici

- Python, FastAPI, Flutter, TypeScript, React/Next.js
- Yapay zekâ entegrasyonu (LLM API, prompt mühendisliği)
- BIST piyasa bilgisi ve ürün tasarımı

**İletişim:** 24390008063@yyu.edu.tr (YYÜ)

---

## 13. Yasal Bilgilendirme

- MK AI **yatırım tavsiyesi vermez**; yalnızca bilgilendirme amaçlıdır.
- Geçmiş performans gelecekteki sonuçların garantisi değildir.
- BIST yatırımları sermaye kaybı riski taşır.
- Kullanıcılar kararlarını kendi araştırmalarına dayandırmalıdır.
- Uygulama içinde risk uyarısı gösterilmektedir.

---

## 14. Ürün Detayı (Başvuru Formu Metni)

MK AI, yaklaşık bir ay önce geliştirmeye başladığım basit Borsa İstanbul Telegram botundan, bugün tam kapsamlı ve manipülasyonlardan etkilenmeyecek şekilde tasarlanmış bir yapay zekâ destekli karar destek sistemine evrilmiştir. Sistem; teknik analiz motoru, çok kaynaklı haber duyarlılığı, büyük dil modelleri ile yorum üretimi ve Flutter mobil uygulama üzerinden kullanıcı deneyimini bir araya getirir. Yatırımcıya tek kanallı yanıltıcı yönlendirmeler yerine ölçülebilir göstergeler, şeffaf güven skorları ve zorunlu risk uyarıları sunar. Telegram, mobil uygulama, web ve REST API ile erişilebilir; Türkiye'deki bireysel BIST yatırımcılarına yönelik yerel ve Türkçe bir çözümdür.

---

## 15. İletişim

| Kanal | Bilgi |
|-------|--------|
| **Geliştirici** | Mustafa Koray Kök |
| **E-posta** | 24390008063@yyu.edu.tr |
| **Web / API** | https://m-koray.online/api |
| **GitHub** | https://github.com/mkor4y/mk-ai |

---

> **MK AI — Akıllı Yatırım Asistanı**  
> *BTK Yapay Zeka Hackathon başvuru dokümanı — Mayıs 2026*
