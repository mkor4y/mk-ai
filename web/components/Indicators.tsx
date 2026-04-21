'use client';

import { useLanguage } from '@/lib/LanguageContext';
import styles from './Indicators.module.css';

export default function Indicators() {
    const { t } = useLanguage();

    return (
        <section className={styles.section}>
            <div className={styles.container}>
                <div className={styles.header}>
                    <h2>{t.indicators.title}</h2>
                    <p>{t.indicators.subtitle}</p>
                </div>

                <div className={styles.grid}>
                    {t.indicators.items.map((item, i) => (
                        <div key={i} className={styles.card}>
                            <div className={styles.name}>{item.name}</div>
                            <div className={styles.full}>{item.full}</div>
                            <p>{item.desc}</p>
                            <span className={styles.value}>{item.value}</span>
                        </div>
                    ))}
                </div>
            </div>
        </section>
    );
}
