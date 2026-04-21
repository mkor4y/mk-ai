# 🤖 MK AI - BIST Akıllı Yatırım Asistanı

## 📋 Proje Özeti

**MK AI**, Borsa İstanbul (BIST) yatırımcıları için geliştirilmiş yapay zeka destekli kapsamlı bir analiz platformudur. Proje, teknik analiz, haber duyarlılık analizi ve AI yorumlarını bir araya getirerek yatırımcılara karar destek sistemi sunar.

---

## 🎯 Problem ve Çözüm

### ❓ Problem
- Bireysel yatırımcılar teknik analiz yapabilmek için çok sayıda araç ve kaynak arasında gezinmek zorunda
- Haberlerin hisse senetleri üzerindeki etkisini analiz etmek zaman alıcı
- Profesyonel analiz araçları genellikle pahalı ve karmaşık

### ✅ Çözüm
MK AI, tüm bu işlemleri tek bir platformda birleştirerek:
- **Otomatik teknik analiz** (RSI, MACD, Bollinger, ADX vb.)
- **Haber duyarlılık analizi** (10+ kaynak)
- **AI destekli yorumlar** sunar

---

## 🏗️ Teknik Mimari

### Multi-Platform Yaklaşım
| Platform | Teknoloji | Amaç |
|----------|-----------|------|
| **Telegram Bot** | Python + python-telegram-bot | Mobil erişim |
| **Web Arayüzü** | Next.js + TypeScript | Dashboard & görselleştirme |
| **Desktop App** | Electron | Masaüstü deneyimi |
| **API** | FastAPI | Tüm platformlara veri sağlar |

### Backend Modülleri
- `BISTAnalyzer` → TradingView'dan veri çekme + teknik göstergeler
- `NewsHelper` → RSS + NewsAPI entegrasyonu + duyarlılık analizi
- `ChatGPTHelper` → Groq/OpenRouter ile AI analiz

---

## 📊 Temel Özellikler

### 1. Teknik Analiz
- **RSI** (Relative Strength Index) - Aşırı alım/satım tespiti
- **MACD** - Trend değişim sinyalleri
- **Bollinger Bands** - Volatilite analizi
- **ADX** - Trend gücü ölçümü
- **Hareketli Ortalamalar** (MA20, MA50, MA100, MA200)

### 2. Trading Sinyalleri
- **AL / SAT / BEKLE** sinyalleri
- **Güven skoru** (0-100%)
- **Risk seviyesi** belirleme
- **Trend rejimi** analizi

### 3. Haber Analizi
- 10+ RSS kaynağından haber toplama
- NewsAPI entegrasyonu
- Duyarlılık skoru hesaplama (pozitif/negatif/nötr)
- Hisse bazlı haber filtreleme

### 4. AI Destekli Yorumlar
- Kısa vadeli beklenti (1-7 gün)
- Orta vadeli beklenti (1-4 hafta)
- Uzun vadeli beklenti (1-6 ay)
- Risk faktörleri analizi
- Yatırımcı önerileri

---

## 🚀 Kullanım Senaryoları

### Senaryo 1: Telegram ile Hızlı Analiz
```
Kullanıcı: /analyze THYAO
Bot: [Kapsamlı teknik analiz + haber özeti + AI yorumu]
```

### Senaryo 2: Web Dashboard
- Canlı piyasa özeti
- Watchlist takibi
- Detaylı grafik analizi

### Senaryo 3: Eğitim Modülü
- Teknik göstergelerin öğretimi
- Yatırım stratejileri
- Risk yönetimi

---

## 💡 Fark Yaratan Özellikler

1. **Türkiye'ye Özgü**: BIST hisselerine özel analiz
2. **Çoklu Kanal**: Telegram + Web + Desktop
3. **AI Entegrasyonu**: Groq/OpenRouter ile akıllı yorumlar
4. **Gerçek Zamanlı Veri**: TradingView entegrasyonu
5. **Duyarlılık Analizi**: Haber etkisi ölçümü
6. **Türkçe Arayüz**: Tam Türkçe destek

---

## 📈 Gelecek Planları

- [ ] Portföy takip sistemi
- [ ] Kullanıcı hesap yönetimi
- [ ] Push notification bildirimleri
- [ ] Daha fazla hisse desteği
- [ ] Backtesting modülü

---

## 👨‍💻 Geliştirici

**Mustafa Koray Kök** tarafından geliştirilmiştir.

---

## ⚠️ Sorumluluk Reddi

Bu platform sadece bilgilendirme amaçlıdır ve yatırım tavsiyesi niteliği taşımaz. Yatırım kararlarınızı kendi araştırmanıza dayandırın. Geçmiş performans, gelecekteki sonuçların garantisi değildir.

---

**Demo için:**
- 🤖 Telegram: `/analyze THYAO` komutu
- 🌐 Web: `http://localhost:3000/dashboard`
- 🔌 API: `http://localhost:8000/docs`
