'use client';

import { useLanguage } from '@/lib/LanguageContext';
import styles from './Features.module.css';

export default function Features() {
    const { t } = useLanguage();

    return (
        <section id="features" className={styles.features}>
            <div className={styles.container}>
                <div className={styles.header}>
                    <h2>{t.features.title}</h2>
                    <p>{t.features.subtitle}</p>
                </div>

                <div className={styles.grid}>
                    {t.features.items.map((f, i) => (
                        <div key={i} className={styles.card}>
                            <div className={styles.icon}>{f.icon}</div>
                            <h3>{f.title}</h3>
                            <p>{f.desc}</p>
                        </div>
                    ))}
                </div>
            </div>
        </section>
    );
}
