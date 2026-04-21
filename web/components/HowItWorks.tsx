'use client';

import { useLanguage } from '@/lib/LanguageContext';
import styles from './HowItWorks.module.css';

export default function HowItWorks() {
    const { t } = useLanguage();

    return (
        <section id="how-it-works" className={styles.section}>
            <div className={styles.container}>
                <div className={styles.header}>
                    <h2>{t.howItWorks.title}</h2>
                    <p>{t.howItWorks.subtitle}</p>
                </div>

                <div className={styles.steps}>
                    {t.howItWorks.steps.map((step, i) => (
                        <div key={i} className={styles.step}>
                            <div className={styles.stepNum}>{step.num}</div>
                            <h3>{step.title}</h3>
                            <p>{step.desc}</p>
                        </div>
                    ))}
                </div>
            </div>
        </section>
    );
}
