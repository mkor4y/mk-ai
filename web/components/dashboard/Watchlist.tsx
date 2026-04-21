'use client';

import { useState } from 'react';
import Link from 'next/link';
import { useLanguage } from '@/lib/LanguageContext';
import styles from './Watchlist.module.css';

const WATCHLIST_STOCKS = [
    { symbol: 'THYAO', name: 'Türk Hava Yolları', price: '285.50', change: '+2.35', percent: '+0.83%', up: true },
    { symbol: 'GARAN', name: 'Garanti Bankası', price: '142.30', change: '-1.20', percent: '-0.84%', up: false },
    { symbol: 'AKBNK', name: 'Akbank', price: '54.20', change: '+0.45', percent: '+0.84%', up: true },
    { symbol: 'TUPRS', name: 'Tüpraş', price: '168.90', change: '+3.10', percent: '+1.87%', up: true },
    { symbol: 'KCHOL', name: 'Koç Holding', price: '198.40', change: '-0.60', percent: '-0.30%', up: false },
];

export default function Watchlist() {
    const { lang } = useLanguage();
    const [stocks] = useState(WATCHLIST_STOCKS);

    return (
        <div className={styles.card}>
            <div className={styles.cardHeader}>
                <h2>📊 {lang === 'tr' ? 'Takip Listesi' : 'Watchlist'}</h2>
                <Link href="/grafik" className={styles.viewAllBtn}>
                    {lang === 'tr' ? 'Grafikleri Gör' : 'View Charts'} →
                </Link>
            </div>

            <div className={styles.list}>
                {stocks.map((stock) => (
                    <Link
                        href={`/grafik?symbol=${stock.symbol}`}
                        key={stock.symbol}
                        className={styles.item}
                    >
                        <div className={styles.leftSection}>
                            <div className={styles.symbolBadge}>
                                {stock.symbol.slice(0, 2)}
                            </div>
                            <div className={styles.stockInfo}>
                                <span className={styles.symbol}>{stock.symbol}</span>
                                <span className={styles.name}>{stock.name}</span>
                            </div>
                        </div>

                        <div className={styles.rightSection}>
                            <span className={styles.price}>{stock.price} ₺</span>
                            <div className={`${styles.changeBox} ${stock.up ? styles.up : styles.down}`}>
                                <span className={styles.changeIcon}>{stock.up ? '▲' : '▼'}</span>
                                <span className={styles.percent}>{stock.percent}</span>
                            </div>
                        </div>
                    </Link>
                ))}
            </div>

            <div className={styles.footer}>
                <span className={styles.updateTime}>
                    {lang === 'tr' ? 'Son güncelleme: Şimdi' : 'Last update: Now'}
                </span>
            </div>
        </div>
    );
}
