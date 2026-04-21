'use client';

import Link from 'next/link';
import { useLanguage } from '@/lib/LanguageContext';
import styles from './CTA.module.css';

export default function CTA() {
    const { t } = useLanguage();

    return (
        <section className={styles.cta}>
            <div className={styles.container}>
                <h2>{t.cta.title}</h2>
                <p>{t.cta.subtitle}</p>
                <div className={styles.buttons}>
                    <Link href="/dashboard" className={styles.btnPrimary}>
                        🚀 {t.cta.button}
                    </Link>
                    <Link href="#" className={styles.btnSecondary}>
                        📱 {t.cta.telegram}
                    </Link>
                </div>
            </div>
        </section>
    );
}
