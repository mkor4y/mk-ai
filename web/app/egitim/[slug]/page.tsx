'use client';

import { useParams, useRouter } from 'next/navigation';
import Link from 'next/link';
import DashboardLayout from '@/components/dashboard/DashboardLayout';
import Sidebar from '@/components/dashboard/Sidebar';
import styles from './lesson.module.css';

const lessons: Record<string, {
    icon: string;
    title: string;
    level: string;
    duration: string;
    intro: string;
    sections: { title: string; content: string; tip?: string; warning?: string; example?: string }[];
    quiz?: { question: string; options: string[]; correct: number }[];
}> = {
    'teknik-analiz': {
        icon: '📊',
        title: 'Teknik Analiz Temelleri',
        level: 'Başlangıç',
        duration: '15 dk',
        intro: '🎯 Bu derste grafiklerin dilini öğrenecek, piyasaların size ne söylediğini anlayacaksınız!',
        sections: [
            {
                title: '🕯️ Mum Grafikleri (Candlestick)',
                content: `Mum grafikleri, Japonlar tarafından 18. yüzyılda pirinç ticareti için geliştirildi. Bugün dünya genelinde en popüler grafik türü!

📦 **Bir Mumun 4 Bileşeni:**

| Bileşen | Açıklama |
|---------|----------|
| 🔵 Açılış (Open) | Dönemin başlangıç fiyatı |
| 🔴 Kapanış (Close) | Dönemin bitiş fiyatı |
| ⬆️ En Yüksek (High) | Dönemdeki zirve |
| ⬇️ En Düşük (Low) | Dönemdeki dip |

🟢 **Yeşil/Beyaz Mum** = Kapanış > Açılış (Boğalar kazandı! 🐂)
🔴 **Kırmızı/Siyah Mum** = Kapanış < Açılış (Ayılar kazandı! 🐻)`,
                tip: '💡 Uzun gövdeli mumlar güçlü alıcı/satıcı baskısını, kısa gövdeli mumlar kararsızlığı gösterir!',
                example: `📈 **Örnek:** THYAO hissesinde uzun yeşil mum görürseniz, o gün güçlü alıcı ilgisi var demektir.`
            },
            {
                title: '📈 Trend Çizgileri',
                content: `Trend, piyasanın genel yönüdür. "Trend senin dostunadir!" 🤝

**3 Tip Trend:**

🚀 **Yükseliş Trendi (Uptrend)**
- Yükselen diplerden oluşur
- Trend çizgisi DİPLERDEN geçer
- AL sinyali verir

📉 **Düşüş Trendi (Downtrend)**  
- Alçalan tepelerden oluşur
- Trend çizgisi TEPELERDEN geçer
- SAT sinyali verir

➡️ **Yatay Trend (Sideways)**
- Belirli bir aralıkta salınım
- BEKLE sinyali verir`,
                tip: '💡 Trend çizgisine 3+ kez dokunulması onu "güçlü" yapar. Ne kadar çok dokunuş = O kadar güvenilir!',
                warning: '⚠️ Trende karşı işlem yapmayın! %70 başarısızlık oranı var.'
            },
            {
                title: '🎯 Destek ve Direnç Seviyeleri',
                content: `Destek ve direnç, fiyatın "duvar"lara çarptığı seviyelerdir.

🛡️ **Destek (Support)**
- Fiyatın düşerken durduğu seviye
- Alıcıların yoğunlaştığı bölge
- "Zemin" gibi düşünün 🏠

🧱 **Direnç (Resistance)**
- Fiyatın yükselirken durduğu seviye  
- Satıcıların yoğunlaştığı bölge
- "Tavan" gibi düşünün 🏢

🔄 **Rol Değişimi:**
Kırılan destek → Yeni direnç olur
Kırılan direnç → Yeni destek olur`,
                example: `📊 **Gerçek Örnek:**
GARAN 140 TL'de 3 kez durdu = Güçlü destek
144 TL'yi kıramadı = Güçlü direnç
140-144 TL arası işlem aralığı oluştu!`,
                tip: '💡 Yuvarlak sayılar (100, 50, 25) psikolojik seviyelerdir ve önemlidir!'
            }
        ],
        quiz: [
            { question: 'Yeşil mum ne anlama gelir?', options: ['Düşüş', 'Yükseliş', 'Yatay'], correct: 1 },
            { question: 'Destek seviyesi nedir?', options: ['Fiyatın durduğu tavan', 'Fiyatın durduğu zemin', 'Ortalama fiyat'], correct: 1 }
        ]
    },
    'rsi': {
        icon: '📈',
        title: 'RSI Göstergesi',
        level: 'Orta',
        duration: '20 dk',
        intro: '🔥 RSI, piyasanın "nabzını" ölçer! Aşırı alım/satım bölgelerini tespit edin.',
        sections: [
            {
                title: '🤔 RSI Nedir?',
                content: `RSI (Relative Strength Index) = Göreceli Güç Endeksi

1978'de J. Welles Wilder tarafından geliştirildi. Momentum göstergesidir!

📊 **Temel Bilgiler:**
- Değer aralığı: 0️⃣ ile 💯 arasında
- Varsayılan periyot: 14 gün
- Hesaplama: RSI = 100 - (100 / (1 + RS))

🧮 **RS = Ortalama Kazanç / Ortalama Kayıp**`,
                tip: '💡 RSI tek başına AL/SAT kararı vermek için yeterli değil! Diğer göstergelerle birlikte kullanın.'
            },
            {
                title: '🚨 Aşırı Alım ve Aşırı Satım',
                content: `RSI değerlerine göre piyasa durumu:

🔴 **AŞIRI ALIM (Overbought): RSI > 70**
- Fiyat çok hızlı yükselmiş olabilir
- Düzeltme/geri çekilme beklenebilir
- ⚠️ Ama güçlü trendlerde RSI 80-90'da kalabilir!

🟢 **AŞIRI SATIM (Oversold): RSI < 30**
- Fiyat çok hızlı düşmüş olabilir
- Toparlanma beklenebilir
- ⚠️ Ama düşüş trendinde RSI 10-20'de kalabilir!

⚪ **NÖTR BÖLGE: 30-70 arası**
- Net sinyal yok
- Trend takibi yapın`,
                warning: '⚠️ RSI > 70 demek "hemen sat" değil! Trend yönüne bakın.',
                example: `📈 **Örnek Senaryo:**
THYAO RSI = 25 (Aşırı satım)
+ Destek seviyesinde
+ Hacim artıyor
= 🎯 Potansiyel alım fırsatı!`
            },
            {
                title: '🔀 RSI Diverjansları (Uyumsuzluklar)',
                content: `Diverjans = Fiyat ve RSI'ın farklı yönlere gitmesi. EN GÜÇLLİ sinyallerden biridir! 💪

📈 **Bullish (Yükseliş) Diverjans:**
- Fiyat: Yeni DİP yapıyor ⬇️
- RSI: Yeni dip YAPMIYOR ➡️
- Sonuç: Düşüş zayıflıyor, DÖNÜŞ gelebilir! 🔄

📉 **Bearish (Düşüş) Diverjans:**
- Fiyat: Yeni TEPE yapıyor ⬆️
- RSI: Yeni tepe YAPMIYOR ➡️
- Sonuç: Yükseliş zayıflıyor, DÖNÜŞ gelebilir! 🔄`,
                tip: '💡 Diverjans + Destek/Direnç = ÇOK GÜÇLÜ sinyal! 🎯',
                example: `📊 **Gerçek Örnek:**
ASELS fiyatı 55 TL → 52 TL (yeni dip)
RSI: 28 → 32 (yeni dip YOK!)
= Bullish Diverjans 🟢
Sonuç: Fiyat 58 TL'ye yükseldi! ✅`
            }
        ]
    },
    'macd': {
        icon: '🎯',
        title: 'MACD Stratejileri',
        level: 'Orta',
        duration: '25 dk',
        intro: '⚡ MACD, trend takibi için en popüler göstergelerden biri! Momentum + Trend = Güç!',
        sections: [
            {
                title: '🧩 MACD Bileşenleri',
                content: `MACD = Moving Average Convergence Divergence
(Hareketli Ortalama Yakınsama Iraksama)

**3️⃣ ANA BİLEŞEN:**

📘 **MACD Line (Mavi çizgi)**
= 12 günlük EMA - 26 günlük EMA
Hızlı tepki verir!

📙 **Signal Line (Turuncu çizgi)**  
= MACD'nin 9 günlük EMA'sı
Yavaş tepki verir!

📊 **Histogram (Çubuklar)**
= MACD Line - Signal Line
Momentum gücünü gösterir!

*EMA = Exponential Moving Average*`,
                tip: '💡 Histogram büyüyorsa momentum artıyor, küçülüyorsa zayıflıyor!'
            },
            {
                title: '✂️ Kesişim Sinyalleri',
                content: `MACD'nin EN ÖNEMLİ sinyalleri kesişimlerdir!

🟢 **BULLISH CROSSOVER (AL Sinyali):**
- MACD Line, Signal Line'ı ALTTAN keser ⬆️
- Histogram: Negatiften pozitife döner
- Trend yukarı dönüyor! 🚀

🔴 **BEARISH CROSSOVER (SAT Sinyali):**
- MACD Line, Signal Line'ı ÜSTTEN keser ⬇️
- Histogram: Pozitiften negatife döner
- Trend aşağı dönüyor! 📉

**SIFIR ÇİZGİSİ:**
- MACD > 0: Yükseliş trendi 🐂
- MACD < 0: Düşüş trendi 🐻`,
                warning: '⚠️ Yatay piyasalarda çok fazla yanlış sinyal verebilir!',
                example: `📈 **Örnek:**
KRDMD - MACD sıfırın altından yukarı keser
+ Signal line kesişimi
+ Histogram yeşile döner
= GÜÇLÜ AL sinyali! ✅`
            },
            {
                title: '🤝 MACD + RSI Kombinasyonu',
                content: `İki göstergeyi birlikte kullanmak başarı oranını ARTIRIR! 📊

🎯 **SÜPER AL SİNYALİ:**
✅ RSI < 30 (Aşırı satım bölgesi)
✅ MACD Bullish Crossover
✅ Histogram pozitife dönüyor
✅ Destek seviyesinde
= 💎 GÜÇLÜ ALIM FIRSATI!

🎯 **SÜPER SAT SİNYALİ:**
✅ RSI > 70 (Aşırı alım bölgesi)
✅ MACD Bearish Crossover
✅ Histogram negatife dönüyor
✅ Direnç seviyesinde
= 📉 GÜÇLÜ SATIM FIRSATI!`,
                tip: '💡 3+ gösterge aynı yönü gösteriyorsa, sinyal güvenilirliği %80+ olur!'
            }
        ]
    },
    'bollinger': {
        icon: '📉',
        title: 'Bollinger Bantları',
        level: 'Orta',
        duration: '20 dk',
        intro: '🎸 Bollinger Bantları volatiliteyi (oynaklığı) ölçer. Sıkışma = Patlama gelecek!',
        sections: [
            {
                title: '🎵 Bollinger Bantları Nedir?',
                content: `1980'lerde John Bollinger tarafından geliştirildi. 3 banttan oluşur!

📊 **BANTLAR:**

🔵 **Üst Bant** = SMA(20) + (2 × Standart Sapma)
⚪ **Orta Bant** = 20 günlük SMA
🔴 **Alt Bant** = SMA(20) - (2 × Standart Sapma)

📈 **Önemli İstatistik:**
Fiyatın %95'i bu bantlar içinde hareket eder!`,
                tip: '💡 Bantlar genişliyorsa volatilite artıyor, daralıyorsa azalıyor!'
            },
            {
                title: '💥 Squeeze (Sıkışma) Stratejisi',
                content: `🤫 SQUEEZE = Bantların birbirine yaklaşması

Bu, düşük volatilite dönemidir ve BÜYÜK BİR HAREKET yaklaşıyor demektir! 🚀

**SQUEEZE NASIL TESPİT EDİLİR?**
1. Bantlar olağandışı şekilde sıkışır
2. Hacim azalır
3. Fiyat yatay hareket eder

**PATLAMA YÖNÜ:**
- Fiyat üst bantı kırarsa → YUKARI git! 🚀
- Fiyat alt bantı kırarsa → AŞAĞI git! 📉`,
                warning: '⚠️ Squeeze sadece HAREKET sinyali verir, YÖN göstermez! Kırılımı bekleyin.',
                example: `📊 **Örnek:**
TUPRS - Bantlar 3 hafta sıkışık kaldı
Sonra üst bandı kırdı
= %15 yükseliş geldi! 🎯`
            },
            {
                title: '👆 Bant Stratejileri',
                content: `**BANT DOKUNUŞLARI:**

⬆️ **Üst Bant Dokunuşu:**
- Tek başına SAT sinyali DEĞİL!
- Güçlü trendde fiyat bantta "yürüyebilir"
- RSI ile teyit alın

⬇️ **Alt Bant Dokunuşu:**
- Tek başına AL sinyali DEĞİL!
- Düşüşte fiyat alt bantta kalabilir
- RSI ile teyit alın

🔄 **Double Bottom (W Formasyonu):**
1. Fiyat alt banda dokunur
2. Toparlanır
3. Tekrar düşer ama alt banda ULAŞAMAZ
4. = POTANSİYEL ALIM FIRSATI! 🎯`,
                tip: '💡 Bollinger + RSI + MACD = Triple Confirmation (Üçlü Teyit) ✅✅✅'
            }
        ]
    },
    'risk-yonetimi': {
        icon: '⚠️',
        title: 'Risk Yönetimi',
        level: 'Başlangıç',
        duration: '15 dk',
        intro: '🛡️ Para kazanmak önemli, ama kaybetmemek DAHA ÖNEMLİ! Sermayeni koru!',
        sections: [
            {
                title: '🛑 Stop-Loss Kullanımı',
                content: `Stop-Loss = Zararı durdur emri. EN ÖNEMLİ araç! 🔧

**NEDEN KRİTİK?**
❌ Stop-loss olmadan → Küçük kayıp → BÜYÜK FELAKETe dönüşür
✅ Stop-loss ile → Kayıp kontrol altında kalır

**STOP-LOSS YERLEŞTİRME:**

📍 **Teknik Seviyeler:**
- Desteğin %1-2 altına
- Son dipin altına

📍 **ATR Yöntemi:**
- Stop = Giriş - (1.5 × ATR)

📍 **Sabit Yüzde:**
- Her işlemde max %2-3 kayıp`,
                warning: '⚠️ ASLA stop-loss koymadan işlem açmayın! Bu kural %1 bile esnetilemez!',
                example: `📊 **Örnek:**
THYAO 280 TL'den alındı
Destek: 275 TL
Stop-Loss: 273 TL (%2.5 kayıp)
= Maximum risk belirlendi! ✅`
            },
            {
                title: '📏 Pozisyon Boyutlandırma',
                content: `NE KADAR alacağınız, NE alacağınız kadar önemli! 💰

🎯 **%1-2 KURALI (ALTIN KURAL):**
Tek işlemde portföyün MAX %1-2'sini riske at!

**HESAPLAMA FORMÜLÜ:**
Pozisyon = (Portföy × Risk %) / Stop-Loss %

📊 **ÖRNEK:**
- Portföy: 100,000 TL
- Risk: %2 = 2,000 TL max kayıp
- Stop-Loss: %5 uzakta
- Pozisyon = 2,000 / 0.05 = 40,000 TL

✅ 40,000 TL'lik pozisyon açılabilir
✅ %5 düşerse 2,000 TL kayıp (kabul edilebilir)`,
                tip: '💡 Üst üste kayıp durumunda pozisyon boyutunu KÜÇÜLTÜN, büyütmeyin!'
            },
            {
                title: '⚖️ Risk/Ödül Oranı (R:R)',
                content: `Her işlemde sorulacak soru: "Kazanç, riske değer mi?" 🤔

📊 **MİNİMUM ORAN: 1:2**
100 TL riske karşı → En az 200 TL potansiyel kar

**NEDEN 1:2?**
%40 kazanma oranıyla bile KARLI olursunuz!

📈 **10 işlem örneği:**
- 4 kazanç × 200 TL = +800 TL
- 6 kayıp × 100 TL = -600 TL
- NET: +200 TL KAR! ✅

**İDEAL ORANLAR:**
- 1:2 = Minimum kabul edilebilir
- 1:3 = İyi
- 1:4+ = Mükemmel 🏆`,
                tip: '💡 Risk/Ödül 1:1 altındaki işlemleri ASLA yapmayın!',
                warning: '⚠️ Her "fırsat" işlem yapmak için geçerli değil. Beklemek de stratejidir!'
            }
        ]
    },
    'psikoloji': {
        icon: '🧠',
        title: 'Trading Psikolojisi',
        level: 'İleri',
        duration: '30 dk',
        intro: '🧘 Trading %80 psikoloji, %20 teknik! Zihninizi kontrol edin, piyasayı kontrol edin.',
        sections: [
            {
                title: '😰 FOMO ve FUD',
                content: `İki büyük düşman: FOMO ve FUD 👿

😱 **FOMO (Fear Of Missing Out)**
"Treni Kaçırma Korkusu"

- Herkes kazanıyor, ben kaçırıyorum!
- Geç giriş → Kötü fiyat → Kayıp
- Sabırsızlık + Açgözlülük

🎯 **FOMO'yu Yenme:**
✅ Planına sadık kal
✅ "Gelecek fırsat her zaman var"
✅ Başkalarının kazancına odaklanma

😨 **FUD (Fear, Uncertainty, Doubt)**
"Korku, Belirsizlik, Şüphe"

- Her şey batıyor!
- Panik satışı
- Negatif haberlere aşırı tepki

🎯 **FUD'u Yenme:**
✅ Stratejine güven
✅ Haberleri filtrele
✅ Uzun vadeli düşün`,
                example: `📊 **Gerçek Senaryo:**
Hisse %10 yükseldi → FOMO atağı! 😱
"Hemen almalıyım!" 
→ Girdin, ertesi gün %5 düştü
→ Panik → Sattın
→ Sonraki hafta %15 yükseldi
= FOMO + FUD = KAYIP ❌`
            },
            {
                title: '💪 Trading Disiplini',
                content: `Disiplin = Uzun vadeli başarının ANAHTARI 🔑

🏆 **BAŞARILI TRADER ÖZELLİKLERİ:**
✅ Planına %100 sadık kalır
✅ Duygularını kontrol eder
✅ Kayıpları doğal kabul eder
✅ Sürekli öğrenir ve gelişir
✅ Sabırlıdır

📋 **DİSİPLİN İÇİN KURALLAR:**

1️⃣ **Günlük Rutin Oluştur**
- Aynı saatlerde analiz yap
- Aynı checklist kullan

2️⃣ **İşlem Günlüğü Tut 📓**
- Her işlemi kaydet
- Neden girdin, neden çıktın?
- Duyguların neydi?

3️⃣ **Ara Ver 🧘**
- Yorgunken işlem YAPMA
- Kaybedince ara ver
- Her gün max 2-3 saat ekran

4️⃣ **Öğren ve Adapte Ol 📚**
- Hatalarını analiz et
- Başarıları tekrarla`,
                tip: '💡 "Kazanan trader, en çok kazanan değil, en disiplinli olandır!"'
            },
            {
                title: '📉 Kayıp Yönetimi',
                content: `Kayıplar trading'in DOĞAL bir parçasıdır! 🎲

📊 **GERÇEK:**
En iyi traderlar bile %40-50 oranında kaybeder!
Önemli olan KAZANÇLAR > KAYIPLAR olması.

😤 **KAYIPTAN SONRA YAPILMAYACAKLAR:**
❌ İntikam trade'i (Revenge trading)
❌ Pozisyon boyutunu 2x'e çıkarmak
❌ Stop-loss'u kaldırmak
❌ "Kesin döner" demek

✅ **KAYIPTAN SONRA YAPILACAKLAR:**
1. Sakin ol, 15 dk mola ver ☕
2. Neyi yanlış yaptın, analiz et 📝
3. İşlem günlüğüne kaydet 📓
4. Pozisyon boyutunu KÜÇÜLT
5. Gerekirse gün için DUR 🛑

🚨 **ALTIN KURAL:**
Bir günde portföyün %5'inden fazlasını kaybetme!
Bu limite ulaşırsan: O GÜN İÇİN DUR! 🛑`,
                warning: '⚠️ "Batık maliyet yanılgısı"na düşme! Geçmiş kayıplar gelecek kararları etkilememeli.',
                tip: '💡 Her kayıp bir ders! Ama aynı dersi tekrar tekrar almak=başarısızlık. Öğren ve ilerle! 🚀'
            }
        ]
    }
};

export default function LessonPage() {
    const params = useParams();
    const router = useRouter();
    const slug = params.slug as string;
    const lesson = lessons[slug];

    if (!lesson) {
        return (
            <DashboardLayout>
                <div className={styles.page}>
                    <Sidebar />
                    <main className={styles.main}>
                        <div className={styles.notFound}>
                            <h1>❌ Ders Bulunamadı</h1>
                            <Link href="/egitim">← Eğitime Dön</Link>
                        </div>
                    </main>
                </div>
            </DashboardLayout>
        );
    }

    return (
        <DashboardLayout>
            <div className={styles.page}>
                <Sidebar />
                <main className={styles.main}>
                    <div className={styles.content}>
                        <div className={styles.header}>
                            <Link href="/egitim" className={styles.back}>← Eğitime Dön</Link>
                            <div className={styles.lessonInfo}>
                                <span className={styles.icon}>{lesson.icon}</span>
                                <div>
                                    <h1>{lesson.title}</h1>
                                    <div className={styles.meta}>
                                        <span className={styles.level}>{lesson.level}</span>
                                        <span className={styles.duration}>⏱️ {lesson.duration}</span>
                                    </div>
                                </div>
                            </div>
                            <p className={styles.intro}>{lesson.intro}</p>
                        </div>

                        <div className={styles.sections}>
                            {lesson.sections.map((section, i) => (
                                <section key={i} className={styles.section}>
                                    <h2>{section.title}</h2>
                                    <div className={styles.sectionContent}>
                                        {section.content.split('\n\n').map((para, j) => (
                                            <p key={j} dangerouslySetInnerHTML={{ __html: para.replace(/\*\*(.*?)\*\*/g, '<strong>$1</strong>') }} />
                                        ))}
                                    </div>

                                    {section.tip && (
                                        <div className={styles.tipBox}>
                                            {section.tip}
                                        </div>
                                    )}

                                    {section.warning && (
                                        <div className={styles.warningBox}>
                                            {section.warning}
                                        </div>
                                    )}

                                    {section.example && (
                                        <div className={styles.exampleBox}>
                                            {section.example}
                                        </div>
                                    )}
                                </section>
                            ))}
                        </div>

                        <div className={styles.navigation}>
                            <button onClick={() => router.push('/egitim')} className={styles.completeBtn}>
                                ✓ Dersi Tamamla
                            </button>
                        </div>
                    </div>
                </main>
            </div>
        </DashboardLayout>
    );
}
