'use client';

import { useLanguage } from '@/lib/LanguageContext';
import styles from './MarketOverview.module.css';

interface MarketIndex {
    name: string;
    value: string;
    change: string;
    up: boolean;
}

interface MarketOverviewProps {
    data?: MarketIndex[];
}

export default function MarketOverview({ data = [] }: MarketOverviewProps) {
    const { lang } = useLanguage();

    const displayData = data.length > 0 ? data : [
        { name: 'BIST 100', value: '...', change: '...', up: true },
        { name: 'BIST 30', value: '...', change: '...', up: true },
    ];

    return (
        <div className={styles.card}>
            <div className={styles.cardHeader}>
                <h2>{lang === 'tr' ? 'Piyasa Özeti' : 'Market Overview'}</h2>
                <span className={styles.live}>● {lang === 'tr' ? 'Canlı' : 'Live'}</span>
            </div>

            <div className={styles.grid}>
                {displayData.map((item, index) => (
                    <div key={index} className={styles.item}>
                        <div className={styles.itemName}>{item.name}</div>
                        <div className={styles.itemValue}>{item.value}</div>
                        <div className={`${styles.itemChange} ${item.up ? styles.up : styles.down}`}>
                            {item.change}
                        </div>
                    </div>
                ))}
            </div>
        </div>
    );
}
