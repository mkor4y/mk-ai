'use client';

import Link from 'next/link';
import { useLanguage } from '@/lib/LanguageContext';
import styles from './RecentNews.module.css';

const newsData = [
    {
        title: { tr: 'THY 85 Milyon Yolcu Rekorunu Kırdı', en: 'THY Breaks 85M Passenger Record' },
        source: 'Eko Türk',
        time: '2s',
        sentiment: 'positive'
    },
    {
        title: { tr: 'BIST 100 Güne Yükselişle Başladı', en: 'BIST 100 Starts Day Higher' },
        source: 'Bloomberg HT',
        time: '1s',
        sentiment: 'positive'
    },
    {
        title: { tr: 'Bankacılık Sektöründe Dalgalanma', en: 'Volatility in Banking Sector' },
        source: 'Para Ajansı',
        time: '3s',
        sentiment: 'neutral'
    },
];

export default function RecentNews() {
    const { lang } = useLanguage();

    return (
        <div className={styles.card}>
            <div className={styles.cardHeader}>
                <h2>{lang === 'tr' ? 'Son Haberler' : 'Recent News'}</h2>
                <Link href="/haberler" className={styles.viewAll}>
                    {lang === 'tr' ? 'Tümü' : 'All'} →
                </Link>
            </div>

            <div className={styles.list}>
                {newsData.map((news, i) => (
                    <div key={i} className={styles.item}>
                        <div className={`${styles.indicator} ${styles[news.sentiment]}`} />
                        <div className={styles.content}>
                            <div className={styles.title}>{news.title[lang]}</div>
                            <div className={styles.meta}>
                                <span>{news.source}</span>
                                <span>•</span>
                                <span>{news.time} {lang === 'tr' ? 'önce' : 'ago'}</span>
                            </div>
                        </div>
                    </div>
                ))}
            </div>
        </div>
    );
}
