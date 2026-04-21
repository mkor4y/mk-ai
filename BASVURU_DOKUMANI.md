# 🤖 MK AI — Girişimcilik Merkezi Başvuru Dokümanı

---

## 📌 Proje Kimliği

| Bilgi | Detay |
|-------|-------|
| **Proje Adı** | MK AI — Akıllı Yatırım Asistanı |
| **Slogan** | *"İşletmeler İçin Akıl, Müşteriler İçin Değer."* |
| **Geliştirici** | Mustafa Koray Kök |
| **Kategori** | FinTech / Yapay Zekâ / Veri Analitiği |
| **Hedef Pazar** | Türkiye — Borsa İstanbul (BIST) Yatırımcıları |
| **Tarih** | Şubat 2026 |

---

## 1. 🎯 Proje Özeti

**MK AI**, Borsa İstanbul (BIST) yatırımcıları için geliştirilmiş, yapay zekâ destekli kapsamlı bir yatırım analiz platformudur. Teknik analiz, haber duyarlılık analizi ve AI tabanlı yorumları tek bir çatı altında birleştirerek bireysel yatırımcılara profesyonel düzeyde bir **karar destek sistemi** sunar.

Platform, **4 farklı erişim kanalı** üzerinden hizmet verir:
- 🤖 **Telegram Bot** — Mobil erişim, anlık komutlarla analiz
- 🌐 **Web Dashboard** — Kapsamlı görselleştirme ve interaktif analiz
- 🖥️ **Desktop Uygulaması** — Electron tabanlı masaüstü deneyimi
- 🔌 **REST API** — Üçüncü parti entegrasyonlar için FastAPI altyapısı

---

## 2. ❓ Problem Tanımı

### Türkiye'de Bireysel Yatırımcının Sorunları

1. **Yüksek Maliyet**: Profesyonel analiz araçları (Bloomberg Terminal, Reuters Eikon vb.) yıllık **25.000–50.000 USD** maliyetlidir. Bireysel yatırımcılar bu araçlara erişemez.

2. **Bilgi Dağınıklığı**: Teknik analiz yapmak için birden fazla platform ve araç kullanmak gerekir. Yatırımcı RSI için bir site, MACD için başka bir araç, haberler için farklı kaynaklar kullanmak zorundadır.

3. **Haber Etkisinin Anlaşılamaması**: Haberlerin hisse senedi fiyatları üzerindeki etkisini analiz etmek uzmanlık ve zaman gerektirir. Bireysel yatırımcı haberleri tek tek okuyup yorumlayamaz.

4. **Dil Bariyeri**: Mevcut profesyonel analiz araçlarının büyük çoğunluğu İngilizce'dir ve Türk piyasasına özgü analizler sunmaz.

5. **Finansal Okuryazarlık Eksikliği**: Bireysel yatırımcıların önemli bir kısmı teknik göstergeleri (RSI, MACD, Bollinger vb.) bilmez veya doğru yorumlayamaz.

### Rakamlarla Problem

- Türkiye'de **~8 milyon** bireysel yatırımcı hesabı bulunmaktadır (SPK, 2025).
- Bu yatırımcıların **%80'den fazlası** profesyonel analiz aracı kullanmamaktadır.
- Yanlış yatırım kararları nedeniyle bireysel yatırımcıların büyük çoğunluğu zarar etmektedir.

---

## 3. ✅ Çözüm: MK AI

MK AI, yukarıdaki tüm problemleri **tek bir platformda** çözer:

| Problem | MK AI Çözümü |
|---------|-------------|
| Yüksek maliyet | Ücretsiz/düşük maliyetli erişim |
| Bilgi dağınıklığı | Tüm analizler tek platformda |
| Haber etkisi | Otomatik duyarlılık analizi |
| Dil bariyeri | %100 Türkçe arayüz |
| Finansal okuryazarlık | Entegre eğitim modülü |

### Nasıl Çalışır?

```
Kullanıcı → Hisse kodu girer (örn: THYAO)
    ↓
MK AI → Gerçek zamanlı veri çeker (TradingView)
    ↓
Teknik Analiz Motoru → RSI, MACD, Bollinger, ADX hesaplar
    ↓
Haber Motoru → 12+ kaynaktan haber toplar, duyarlılık analizi yapar
    ↓
AI Motoru → Tüm verileri yorumlar, kısa/orta/uzun vadeli beklenti üretir
    ↓
Kullanıcı → Kapsamlı analiz raporu + AL/SAT/BEKLE sinyali alır
```

---

## 4. 💎 Değer Önerisi

> **"MK AI, bireysel yatırımcıların profesyonel analiz araçlarına erişimini demokratikleştirerek, yapay zekâ destekli teknik analiz, haber duyarlılık analizi ve kişiselleştirilmiş yatırım önerileriyle doğru kararlar almasını sağlar."**

### Müşteriye Sağlanan Somut Değerler

| Değer | Açıklama | Etki |
|-------|----------|------|
| 💰 **Maliyet Tasarrufu** | Profesyonel araçların sunduğu analizleri düşük maliyetle sunar | Yıllık binlerce dolar tasarruf |
| ⏱️ **Zaman Tasarrufu** | Saatler süren analiz sürecini saniyeye indirir | Günde 2-3 saat zaman kazanımı |
| 🎓 **Eğitim Değeri** | Yatırımcıya teknik göstergeleri ve stratejiyi öğretir | Finansal okuryazarlık artışı |
| 🇹🇷 **Yerellik** | BIST'e özel, tamamen Türkçe | Dil bariyeri sorunu ortadan kalkar |
| 📊 **Doğru Karar Desteği** | Al/Sat/Bekle sinyalleri + güven skoru | Bilinçli yatırım kararları |
| 🔄 **Çok Kanallı Erişim** | Telegram, Web, Desktop, API | Her yerden, her cihazdan erişim |

---

## 5. 📊 Temel Özellikler

### 5.1 Teknik Analiz Motoru
- **RSI** (Relative Strength Index) — Aşırı alım/aşırı satım tespiti
- **MACD** (Moving Average Convergence Divergence) — Trend değişim sinyalleri
- **Bollinger Bantları** — Volatilite analizi ve fırsat tespiti
- **ADX** (Average Directional Index) — Trend gücü ölçümü
- **Hareketli Ortalamalar** — SMA 20, 50, 100, 200 günlük
- **Hacim Analizi** — Hacim bazlı sinyal üretimi
- **Gap Analizi** — Fiyat boşlukları tespiti

### 5.2 Trading Sinyalleri
- **AL / SAT / BEKLE** sinyalleri — Net yönlendirme
- **Güven Skoru** (0-100%) — Sinyalin güvenilirlik derecesi
- **Risk Seviyesi** — Düşük / Orta / Yüksek kategorileri
- **Sinyal Gücü** — Zayıf / Orta / Güçlü / Çok Güçlü
- **Trend Rejimi** — Yatay / Zayıf Trend / Trend / Güçlü Trend

### 5.3 Haber Analizi ve Duyarlılık
- **12+ haber kaynağı** entegrasyonu (AA, BloombergHT, NTV, Habertürk, BBC, CNBC vb.)
- **RSS + NewsAPI** çift katmanlı haber toplama
- **Anahtar kelime eşleştirme** — Her hisse için özel kelime havuzu
- **Duyarlılık skoru** — -1 ile +1 arası (Pozitif/Negatif/Nötr etiketleme)
- **Hisse bazlı filtreleme** — Sadece ilgili haberleri gösterir

### 5.4 AI Destekli Analiz
- **Kısa vadeli beklenti** (1-7 gün)
- **Orta vadeli beklenti** (1-4 hafta)
- **Uzun vadeli beklenti** (1-6 ay)
- **Risk faktörleri** analizi
- **Yatırımcı önerileri** — Kişiselleştirilmiş stratejiler
- **AI modelleri**: DeepSeek Chat (OpenRouter), Llama 3.3 70B (Groq)

### 5.5 Eğitim Modülü
- Teknik Analiz Temelleri (Mum Grafikleri, Trend Çizgileri, Destek/Direnç)
- RSI Göstergesi (Hesaplama, Aşırı Alım/Satım, Diverjans)
- MACD Stratejileri (Bileşenler, Sinyal Kesişimleri, Histogram)
- Bollinger Bantları (Squeeze Stratejisi, Breakout Tespiti)
- Risk Yönetimi (Stop-Loss, Pozisyon Boyutu, Risk/Ödül Oranı)
- Trading Psikolojisi (FOMO, Disiplin, Kayıp Yönetimi)

### 5.6 AI Chat Asistanı
- Doğal dilde soru-cevap (Türkçe)
- Telegram tarzı komut sistemi (`/analyze`, `/price`, `/menu`)
- Hızlı erişim butonları ve komut menüsü
- Sohbet geçmişi ve bağlamsal yanıtlar

### 5.7 Desteklenen Hisseler
THYAO, GARAN, AKBNK, ASELS, KRDMD, TUPRS, ISCTR, YKBNK, HALKB, VAKBN, SISE, BIMAS, EREGL, HEKTS, SASA, FROTO, TOASO, KCHOL, SAHOL, DOFRB, BORLS, TUREX, KSTUR, TKFEN — **24 hisse ve artıyor.**

---

## 6. 🏗️ Teknik Mimari

### Platform Mimarisi

```
┌─────────────────────────────────────────────────────────┐
│                    KULLANICI KATMANI                      │
├──────────┬──────────┬──────────────┬─────────────────────┤
│ Telegram │   Web    │   Desktop    │   Üçüncü Parti     │
│   Bot    │Dashboard │ (Electron)   │   Entegrasyonlar    │
├──────────┴──────────┴──────────────┴─────────────────────┤
│                    API KATMANI                            │
│              FastAPI (REST API)                           │
├──────────────────────────────────────────────────────────┤
│                  İŞ LOJİĞİ KATMANI                       │
├──────────┬──────────────┬───────────────────────────────-┤
│  BIST    │    Haber      │         AI                    │
│Analyzer  │   Helper      │       Helper                  │
│(Teknik)  │ (Duyarlılık)  │    (Yapay Zekâ)              │
├──────────┴──────────────┴────────────────────────────────┤
│                   VERİ KATMANI                            │
├──────────┬──────────────┬────────────────────────────────┤
│TradingView│  RSS Feeds  │   OpenRouter / Groq           │
│(Fiyat)    │ + NewsAPI   │    (AI Modelleri)             │
│           │ (Haberler)  │                                │
└──────────┴──────────────┴────────────────────────────────┘
```

### Kullanılan Teknolojiler

| Katman | Teknoloji | Amaç |
|--------|-----------|------|
| **Backend** | Python 3.8+, FastAPI | API ve iş lojiği |
| **Frontend** | Next.js, TypeScript, React | Web arayüzü |
| **Desktop** | Electron | Masaüstü uygulaması |
| **Bot** | python-telegram-bot | Telegram entegrasyonu |
| **Veri** | TradingView (tvDatafeed) | Gerçek zamanlı BIST verileri |
| **Haberler** | feedparser, NewsAPI, requests | Haber toplama |
| **Teknik Analiz** | pandas, numpy, ta | Gösterge hesaplama |
| **AI** | OpenAI SDK, OpenRouter, Groq | Yapay zekâ analizi |
| **Modeller** | DeepSeek Chat, Llama 3.3 70B | AI motoru |
| **Deployment** | cPanel, PWA, Service Worker | Yayınlama ve offline |

---

## 7. 🎯 Hedef Kitle

### Birincil Hedef Kitle
| Segment | Profil | Tahmini Büyüklük |
|---------|--------|-------------------|
| **Bireysel Yatırımcılar** | 25-45 yaş, aktif BIST yatırımcısı, mobil odaklı | ~3 milyon |
| **Yeni Başlayan Yatırımcılar** | 18-30 yaş, finansal okuryazarlık ihtiyacı olan | ~2 milyon |
| **Part-time Trader'lar** | Gün içi trade yapan, hızlı sinyal ihtiyacı olan | ~500 bin |

### İkincil Hedef Kitle
| Segment | Profil |
|---------|--------|
| **Finans Öğrencileri** | Üniversite öğrencileri, pratik uygulama arayan |
| **Yatırım Kulüpleri** | Üniversite ve özel yatırım toplulukları |
| **Küçük Finans Firmaları** | API entegrasyonu ile kendi ürünlerine eklemek isteyen |

---

## 8. 💼 İş Modeli

### Gelir Kaynakları

| Model | Açıklama | Fiyatlandırma |
|-------|----------|---------------|
| **Freemium** | Temel analiz ve sınırlı sorgu hakkı ücretsiz | Ücretsiz |
| **Premium Abonelik** | Sınırsız analiz, gelişmiş AI yorumları, öncelikli destek | Aylık 49-99 ₺ |
| **Pro Abonelik** | API erişimi, özel hisse listeleri, portföy takibi | Aylık 199-299 ₺ |
| **Kurumsal API** | Üçüncü parti entegrasyonlar için API lisansı | Özel fiyatlandırma |
| **Eğitim İçerikleri** | Premium eğitim paketleri ve sertifika programları | Tek seferlik |

### Gelir Projeksiyonu (İlk 3 Yıl)

| Yıl | Kullanıcı Sayısı | Premium Dönüşüm | Tahmini Aylık Gelir |
|-----|-------------------|------------------|---------------------|
| 1. Yıl | 10.000 | %5 (500 premium) | ~35.000 ₺ |
| 2. Yıl | 50.000 | %7 (3.500 premium) | ~250.000 ₺ |
| 3. Yıl | 150.000 | %10 (15.000 premium) | ~1.000.000 ₺ |

---

## 9. 🏆 Rekabet Analizi

### Mevcut Alternatifler ve MK AI'ın Farkı

| Özellik | Bloomberg | Investing.com | Matriks | **MK AI** |
|---------|-----------|---------------|---------|-----------|
| BIST Odaklı | ❌ | Kısmen | ✅ | ✅ |
| Türkçe Arayüz | ❌ | Kısmen | ✅ | ✅ |
| AI Destekli Yorum | ❌ | ❌ | ❌ | ✅ |
| Haber Duyarlılık | ❌ | ❌ | ❌ | ✅ |
| Telegram Bot | ❌ | ❌ | ❌ | ✅ |
| Eğitim Modülü | ❌ | Kısmen | ❌ | ✅ |
| Maliyet | $25.000/yıl | Ücretsiz/reklam | ~500-1000 ₺/ay | **Freemium** |
| Çok Kanallı | ❌ | Web/Mobil | Web | **4 Kanal** |

### Rekabet Avantajları

1. **Türkiye'nin ilk** tamamen Türkçe, BIST'e özel, AI destekli analiz platformu
2. **Multi-platform** — Tek ürün, 4 farklı erişim kanalı
3. **Yapay zekâ entegrasyonu** — Rakiplerin hiçbirinde yok
4. **Haber duyarlılık analizi** — 12+ kaynaktan otomatik sentiment
5. **Düşük maliyet** — Öğrenci ve bireysel yatırımcı dostu
6. **Eğitim odaklı** — Sadece sinyal değil, öğretici içerik de sunar

---

## 10. � Satış ve Pazarlama

### Ürün veya hizmetinizi müşteri/faydalanıcılara nasıl sunuyorsunuz/sunacaksınız?

MK AI, **çok kanallı dijital dağıtım modeli** ile müşterilerine ulaşır:

- **Telegram Bot**: Kullanıcı tek bir komutla (`/analyze THYAO`) anında profesyonel analiz alır. Kurulum gerektirmez, uygulama indirmeye gerek yoktur, Telegram üzerinden anında erişim sağlanır.
- **Web Dashboard (PWA)**: Tarayıcı üzerinden interaktif grafik, teknik gösterge kartları ve AI sohbet asistanı ile detaylı analiz sunar. Progressive Web App desteği sayesinde offline erişim de mümkündür.
- **Desktop Uygulaması**: Electron tabanlı Windows ve Mac masaüstü uygulaması ile profesyonel kullanıcılara tam ekran deneyim sunar.
- **REST API**: Kurumsal müşteriler ve üçüncü parti uygulamalar için FastAPI altyapısı ile entegrasyon hizmeti sağlar.
- **Freemium Model**: Temel analizler ücretsiz sunularak giriş bariyeri sıfıra indirilir. Gelişmiş AI yorumları, sınırsız sorgu ve portföy takibi gibi özellikler premium abonelik ile sunulur.

### Müşteri/faydalanıcıyı nasıl edineceksiniz?

1. **Organik Büyüme (Telegram Viral Döngüsü)**: Telegram yatırımcı grupları ve borsa forumlarında (Borsa İstanbul toplulukları, Reddit r/borsaistanbul, Ekşi Sözlük borsa başlıkları) doğrudan bot tanıtımı yapılır. Telegram'ın paylaşım yapısı viral büyümeyi destekler.

2. **Sosyal Medya Pazarlama**: Twitter/X, Instagram ve YouTube üzerinden günlük BIST analiz içerikleri, piyasa yorumları ve eğitim videoları paylaşılarak hedef kitleye organik olarak ulaşılır.

3. **İçerik Pazarlama (SEO)**: Eğitim modülündeki içerikler blog yazılarına dönüştürülerek Google aramalarında üst sıralarda yer alınır. "RSI nedir?", "BIST teknik analiz nasıl yapılır?" gibi anahtar kelimeler hedeflenir.

4. **Ağızdan Ağıza Yayılım**: Ücretsiz katman sayesinde kullanıcılar botu arkadaşlarıyla paylaşır. Telegram'ın link paylaşım yapısı bu modele uygundur.

5. **Üniversite İş Birlikleri**: Üniversite yatırım kulüpleri ile demo sunumlar, workshop'lar ve öğrenci indirimleri ile genç yatırımcı segmentine ulaşılır.

6. **Finans İçerik Üreticileri**: Borsa alanında içerik üreten YouTube kanalları, podcast'ler ve influencer'larla iş birliği yapılarak ürün deneme ve tanıtım gerçekleştirilir.

7. **Referans Programı**: Mevcut kullanıcıların yeni kullanıcı getirdiğinde premium özellikler kazanmasını sağlayan bir davet sistemi kurulur.

---

## 11. �📈 SWOT Analizi

### Güçlü Yönler (Strengths)
- ✅ Yapay zekâ entegrasyonu (DeepSeek + Llama 3.3)
- ✅ Multi-platform erişim (Telegram, Web, Desktop, API)
- ✅ %100 Türkçe, BIST'e özel
- ✅ 12+ haber kaynağı entegrasyonu
- ✅ Çalışan MVP (Minimum Viable Product) mevcut
- ✅ Düşük operasyon maliyeti

### Zayıf Yönler (Weaknesses)
- ⚠️ İlk aşamada sınırlı hisse kapsamı (24 hisse)
- ⚠️ Tek kişilik geliştirici ekibi
- ⚠️ Temel veriler (P/E, temettü) henüz sınırlı
- ⚠️ Marka bilinirliği henüz yok

### Fırsatlar (Opportunities)
- 🚀 Türkiye'de hızla büyüyen bireysel yatırımcı sayısı (+%30 yıllık artış)
- 🚀 FinTech sektörüne artan yatırımcı ilgisi
- 🚀 AI teknolojisinin hızla gelişmesi ve maliyetlerin düşmesi
- 🚀 Kripto para ve forex piyasalarına genişleme potansiyeli
- 🚀 B2B API satışı ile aracı kurumlara hizmet

### Tehditler (Threats)
- ⛔ Büyük finans şirketlerinin benzer ürün geliştirmesi
- ⛔ Düzenleyici (SPK) kısıtlamalar
- ⛔ Veri kaynaklarının erişilebilirlik sorunları
- ⛔ AI model maliyetlerinin artması

---

## 12. 🗺️ Yol Haritası

### Faz 1: MVP ve Doğrulama (Tamamlandı ✅)
- [x] Telegram Bot geliştirme
- [x] Teknik analiz motoru (RSI, MACD, Bollinger, ADX)
- [x] Haber duyarlılık analizi
- [x] AI entegrasyonu (OpenRouter + Groq)
- [x] Web Dashboard (Next.js)
- [x] Desktop uygulaması (Electron)
- [x] REST API (FastAPI)
- [x] PWA desteği ve offline çalışma
- [x] Eğitim modülü

### Faz 2: Büyüme (2026 Q2-Q3)
- [ ] Kullanıcı hesap sistemi ve kişiselleştirme
- [ ] Portföy takip sistemi
- [ ] Push notification / fiyat alarmları
- [ ] Hisse kapsamını genişletme (tüm BIST hisseleri)
- [ ] Gelişmiş grafik modülü (TradingView widget)
- [ ] Backtesting modülü

### Faz 3: Ölçekleme (2026 Q4 - 2027)
- [ ] Premium abonelik sistemi ve ödeme entegrasyonu
- [ ] Mobil uygulama (React Native)
- [ ] Kripto para ve forex desteği
- [ ] Gelişmiş NLP tabanlı duyarlılık analizi
- [ ] B2B API lisanslama
- [ ] Topluluk özellikleri (yatırımcı forumu)

### Faz 4: Genişleme (2027+)
- [ ] Uluslararası piyasalar (NYSE, NASDAQ desteği)
- [ ] Çok dilli destek
- [ ] Portföy optimizasyonu (Markowitz modeli)
- [ ] Sosyal trading özellikleri
- [ ] Otomatik trading entegrasyonu (aracı kurum API'leri)

---

## 13. 💰 Mali Gereksinimler

### Başlangıç Maliyetleri

| Kalem | Maliyet (Aylık) | Açıklama |
|-------|-----------------|----------|
| Sunucu / Hosting | ~500-1.000 ₺ | cPanel veya VPS |
| AI API Maliyeti | ~1.000-3.000 ₺ | OpenRouter + Groq kullanım |
| Domain + SSL | ~200 ₺ | Yıllık, aylığa bölünmüş |
| Haber API | ~500 ₺ | NewsAPI premium |
| **Toplam** | **~2.200 - 4.700 ₺/ay** | |

### İlk Yıl Tahmini Toplam Bütçe
- Geliştirme ve operasyon: **~50.000 ₺**
- Pazarlama ve kullanıcı kazanımı: **~30.000 ₺**
- **Toplam: ~80.000 ₺**

---

## 14. 👨‍💻 Ekip

### Kurucu ve Geliştirici
**Mustafa Koray Kök**
- Full-stack geliştirici
- Python, TypeScript, React, Next.js, FastAPI
- Yapay zekâ ve veri analitiği deneyimi
- BIST piyasa bilgisi

### İhtiyaç Duyulan Roller (Büyüme Aşaması)
| Rol | Görev | Zaman |
|-----|-------|-------|
| UI/UX Tasarımcı | Arayüz iyileştirme | Part-time |
| Pazarlama Uzmanı | Dijital pazarlama, sosyal medya | Part-time |
| Finans Danışmanı | SPK uyumluluk, içerik doğrulama | Danışman |

---

## 15. 📋 Kullanım Senaryoları

### Senaryo 1: Telegram ile Hızlı Analiz
```
Kullanıcı: /analyze THYAO
MK AI Bot: 
  📊 Türk Hava Yolları (THYAO) Analizi
  
  💰 Fiyat: 312.50 ₺ (+%2.3)
  📈 RSI: 62.3 (Nötr)
  🎯 MACD: Boğa Sinyali
  🚀 Genel Sinyal: AL (%72 Güven)
  
  📰 Haber Duyarlılığı: POZİTİF (+0.45)
  
  🤖 AI Yorumu: Kısa vadede yükseliş beklentisi...
```

### Senaryo 2: Web Dashboard
- Canlı piyasa özeti ve endeks takibi
- Watchlist ile favori hisseleri izleme
- Detaylı teknik gösterge kartları (RSI, MACD, Bollinger, Ortalamalar)
- AI destekli interaktif analiz

### Senaryo 3: AI Chat Asistanı
- Doğal dilde soru: *"BIST 100 bugün nasıl?"*
- Teknik soru: *"RSI göstergesini açıkla"*
- Analiz talebi: *"THYAO teknik analizi yap"*

### Senaryo 4: Eğitim
- Başlangıç seviyesinden ileri düzeye kademeli eğitim
- Teknik göstergelerin teorisi ve pratik uygulaması
- Risk yönetimi ve trading psikolojisi

---

## 16. ⚠️ Yasal Bilgilendirme

- Bu platform **sadece bilgilendirme amaçlıdır** ve **yatırım tavsiyesi niteliği taşımaz**.
- Kullanıcılar yatırım kararlarını kendi araştırmalarına dayandırmalıdır.
- Geçmiş performans, gelecekteki sonuçların garantisi değildir.
- Platform, SPK düzenlemelerine uygun olarak geliştirilmektedir.
- Her analiz çıktısında risk uyarısı gösterilmektedir.

---

## 17. 📞 İletişim

| Kanal | Bilgi |
|-------|-------|
| **Geliştirici** | Mustafa Koray Kök |
| **E-posta** | [E-posta adresinizi buraya ekleyin] |
| **Telegram Bot** | [Bot linkini buraya ekleyin] |
| **Web** | [Web sitesi adresini buraya ekleyin] |
| **GitHub** | [Repo linkini buraya ekleyin] |

---

> **"MK AI — İşletmeler İçin Akıl, Müşteriler İçin Değer."**

---

*Bu doküman MK AI girişimcilik merkezi başvurusu için hazırlanmıştır. Şubat 2026.*
