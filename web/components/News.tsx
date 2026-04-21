'use client';

import Image from 'next/image';
import Link from 'next/link';
import { useLanguage } from '@/lib/LanguageContext';
import styles from './News.module.css';

// Güncel BIST haberleri (gerçek veriler)
const newsData = [
    {
        id: 1,
        image: '/images/news-thy.png',
        title: {
            tr: 'Türk Hava Yolları 2024\'te 85,2 Milyon Yolcu Taşıyarak Rekor Kırdı',
            en: 'Turkish Airlines Sets Record with 85.2 Million Passengers in 2024'
        },
        desc: {
            tr: 'THY, 2024 yılında toplam 85,2 milyon yolcu taşıyarak tüm zamanların yolcu rekorunu kırdı. Şirket, KAP\'a yaptığı açıklamada bu başarıyı duyurdu.',
            en: 'THY carried a total of 85.2 million passengers in 2024, breaking the all-time passenger record. The company announced this success in its KAP disclosure.'
        },
        source: 'Eko Türk',
        date: '08.01.2025',
        sentiment: 'positive',
        tags: ['THYAO', 'Havacılık']
    },
    {
        id: 2,
        image: '/images/news-chart.png',
        title: {
            tr: 'THY Q3 2024: 1,3 Milyar Dolar Net Kâr, Yolcu Kapasitesi %5,4 Arttı',
            en: 'THY Q3 2024: $1.3 Billion Net Profit, Passenger Capacity Up 5.4%'
        },
        desc: {
            tr: 'Türk Hava Yolları üçüncü çeyrekte 24,5 milyon yolcu taşıdı. Toplam gelirler %4,9 artışla 6,6 milyar dolara, kargo gelirleri %47 artışla 911 milyon dolara ulaştı.',
            en: 'Turkish Airlines carried 24.5 million passengers in Q3. Total revenues increased 4.9% to $6.6 billion, cargo revenues surged 47% to $911 million.'
        },
        source: 'Haber Apron',
        date: '15.12.2024',
        sentiment: 'positive',
        tags: ['THYAO', 'Bilanço']
    },
    {
        id: 3,
        image: '/images/news-analysis.png',
        title: {
            tr: 'THYAO Hedef Fiyat: J.P. Morgan 547 TL, Tera Yatırım 582 TL Öngördü',
            en: 'THYAO Target Price: J.P. Morgan Forecasts 547 TL, Tera Investment 582 TL'
        },
        desc: {
            tr: 'Aracı kurumlar THY hissesi için yüksek hedef fiyatlar belirledi. J.P. Morgan 547,50 TL, Tera Yatırım 582,40 TL hedef fiyat ve "al" tavsiyesi verdi.',
            en: 'Brokerage firms set high target prices for THY stock. J.P. Morgan targets 547.50 TL, Tera Investment 582.40 TL with "buy" recommendations.'
        },
        source: 'Para Ajansı',
        date: '12.12.2024',
        sentiment: 'positive',
        tags: ['THYAO', 'Analiz']
    },
    {
        id: 4,
        image: '/images/news-cargo.png',
        title: {
            tr: 'Turkish Cargo Dünya Üçüncüsü: Küresel Pazarın %5,7\'sini Aldı',
            en: 'Turkish Cargo Ranks Third Globally: Captures 5.7% of World Market'
        },
        desc: {
            tr: 'THY\'nin kargo taşımacılığı birimi Turkish Cargo, küresel hava kargo pazarında %5,7 pay ile dünyanın en büyük üçüncü taşıyıcısı oldu.',
            en: 'THY\'s cargo unit Turkish Cargo became the world\'s third largest carrier with a 5.7% share in the global air cargo market.'
        },
        source: 'Hava Haber',
        date: '10.12.2024',
        sentiment: 'positive',
        tags: ['THYAO', 'Kargo']
    },
    {
        id: 5,
        image: '/images/news-deal.png',
        title: {
            tr: 'THY 28. Dönem TİS İmzalandı: Çalışanlara %64 Zam',
            en: 'THY Signs 28th Period Collective Agreement: 64% Salary Increase'
        },
        desc: {
            tr: 'Türk Hava Yolları, Hava-İş Sendikası ile 2024-2025 dönemi toplu iş sözleşmesini imzaladı. İlk 6 ay için %64 ücret artışı sağlandı.',
            en: 'Turkish Airlines signed the 2024-2025 collective bargaining agreement with Hava-İş Union. A 64% salary increase was provided for the first 6 months.'
        },
        source: 'Haber.Aero',
        date: '15.03.2024',
        sentiment: 'neutral',
        tags: ['THYAO', 'İnsan Kaynakları']
    },
    {
        id: 6,
        image: '/images/news-bank.png',
        title: {
            tr: 'BIST 100 Endeksi Yükselişte: Bankacılık Hisseleri Öne Çıktı',
            en: 'BIST 100 Index Rising: Banking Stocks Lead the Gains'
        },
        desc: {
            tr: 'Borsa İstanbul\'da bankacılık sektörü hisseleri günü yükselişle kapattı. GARAN, AKBNK ve ISCTR hisselerinde alım ağırlıklı seyir gözlendi.',
            en: 'Banking sector stocks on Borsa Istanbul closed the day higher. Buy-weighted trend observed in GARAN, AKBNK and ISCTR shares.'
        },
        source: 'Bloomberg HT',
        date: '18.12.2024',
        sentiment: 'positive',
        tags: ['GARAN', 'AKBNK', 'Bankacılık']
    }
];

const translations = {
    tr: {
        title: 'Son Haberler',
        subtitle: 'BIST ve hisse senetleri hakkında güncel haberler',
        viewAll: 'Tüm Haberler',
        positive: 'Pozitif',
        negative: 'Negatif',
        neutral: 'Nötr'
    },
    en: {
        title: 'Latest News',
        subtitle: 'Latest news about BIST and stocks',
        viewAll: 'All News',
        positive: 'Positive',
        negative: 'Negative',
        neutral: 'Neutral'
    }
};

export default function News() {
    const { lang } = useLanguage();
    const t = translations[lang];

    const getSentimentLabel = (sentiment: string) => {
        if (sentiment === 'positive') return t.positive;
        if (sentiment === 'negative') return t.negative;
        return t.neutral;
    };

    return (
        <section id="news" className={styles.section}>
            <div className={styles.container}>
                <div className={styles.header}>
                    <div className={styles.headerText}>
                        <h2>{t.title}</h2>
                        <p>{t.subtitle}</p>
                    </div>
                    <Link href="/haberler" className={styles.viewAll}>
                        {t.viewAll} →
                    </Link>
                </div>

                <div className={styles.grid}>
                    {newsData.slice(0, 6).map((news) => (
                        <article key={news.id} className={styles.newsCard}>
                            <div className={styles.cardImage}>
                                <Image
                                    src={news.image}
                                    alt={news.title[lang]}
                                    fill
                                    style={{ objectFit: 'cover' }}
                                />
                            </div>
                            <div className={styles.cardContent}>
                                <div className={styles.cardMeta}>
                                    <span className={styles.source}>🏢 {news.source}</span>
                                    <span>📅 {news.date}</span>
                                    <span className={`${styles.sentiment} ${styles[news.sentiment]}`}>
                                        {getSentimentLabel(news.sentiment)}
                                    </span>
                                </div>
                                <h3 className={styles.cardTitle}>
                                    {news.title[lang]}
                                </h3>
                                <p className={styles.cardDesc}>
                                    {news.desc[lang]}
                                </p>
                                <div className={styles.tags}>
                                    {news.tags.map((tag, i) => (
                                        <span key={i} className={styles.tag}>{tag}</span>
                                    ))}
                                </div>
                            </div>
                        </article>
                    ))}
                </div>
            </div>
        </section>
    );
}
