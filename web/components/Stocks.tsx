'use client';

import Link from 'next/link';
import { useLanguage } from '@/lib/LanguageContext';
import styles from './Stocks.module.css';

const stocksData = [
    { symbol: 'THYAO', name: 'Türk Hava Yolları', price: '285.50', change: '+2.35', up: true },
    { symbol: 'GARAN', name: 'Garanti Bankası', price: '142.30', change: '-0.85', up: false },
    { symbol: 'ASELS', name: 'Aselsan', price: '58.75', change: '+1.25', up: true },
    { symbol: 'AKBNK', name: 'Akbank', price: '54.20', change: '+0.45', up: true },
    { symbol: 'KRDMD', name: 'Kardemir', price: '32.80', change: '-1.15', up: false },
    { symbol: 'TUPRS', name: 'Tüpraş', price: '178.40', change: '+0.92', up: true },
    { symbol: 'SAHOL', name: 'Sabancı Holding', price: '89.60', change: '+1.78', up: true },
    { symbol: 'KCHOL', name: 'Koç Holding', price: '156.25', change: '-0.45', up: false },
    { symbol: 'EREGL', name: 'Ereğli Demir Çelik', price: '48.90', change: '+2.10', up: true },
    { symbol: 'SISE', name: 'Şişecam', price: '62.35', change: '+0.65', up: true },
];

export default function Stocks() {
    const { t } = useLanguage();

    return (
        <section id="stocks" className={styles.section}>
            <div className={styles.container}>
                <div className={styles.header}>
                    <div className={styles.headerText}>
                        <h2>{t.stocks.title}</h2>
                        <p>{t.stocks.subtitle}</p>
                    </div>
                    <Link href="/analiz" className={styles.viewAll}>
                        {t.stocks.viewAll} →
                    </Link>
                </div>

                <div className={styles.grid}>
                    {stocksData.map((stock) => (
                        <div key={stock.symbol} className={styles.stockCard}>
                            <div className={styles.stockHeader}>
                                <span className={styles.symbol}>{stock.symbol}</span>
                                <span className={`${styles.badge} ${stock.up ? styles.up : styles.down}`}>
                                    {stock.change}%
                                </span>
                            </div>
                            <div className={styles.name}>{stock.name}</div>
                            <div className={styles.price}>{stock.price} ₺</div>
                            <button className={styles.analyzeBtn}>{t.stocks.analyze}</button>
                        </div>
                    ))}
                </div>
            </div>
        </section>
    );
}
