'use client';

import Image from 'next/image';
import Link from 'next/link';
import { useLanguage } from '@/lib/LanguageContext';
import styles from './Footer.module.css';

export default function Footer() {
    const { t } = useLanguage();

    return (
        <footer id="about" className={styles.footer}>
            <div className={styles.container}>
                <div className={styles.top}>
                    <div className={styles.brand}>
                        <div className={styles.logo}>
                            <Image src="/images/logo-dark.png" alt="MK AI" width={32} height={32} />
                            <span>MK AI</span>
                        </div>
                        <p>{t.footer.desc}</p>
                    </div>

                    <div className={styles.column}>
                        <h4>{t.footer.platform}</h4>
                        <ul>
                            <li><Link href="/dashboard">Dashboard</Link></li>
                            <li><Link href="/analiz">Analiz</Link></li>
                            <li><Link href="/chat">AI Chat</Link></li>
                            <li><Link href="/haberler">Haberler</Link></li>
                        </ul>
                    </div>

                    <div className={styles.column}>
                        <h4>{t.footer.resources}</h4>
                        <ul>
                            <li><Link href="/egitim">{t.footer.education}</Link></li>
                            <li><Link href="#">{t.footer.docs}</Link></li>
                            <li><Link href="#">API</Link></li>
                        </ul>
                    </div>

                    <div className={styles.column}>
                        <h4>{t.footer.developer}</h4>
                        <ul>
                            <li><Link href="#">Mustafa Koray KÖK</Link></li>
                            <li><Link href="#">GitHub</Link></li>
                            <li><Link href="#">Telegram Bot</Link></li>
                        </ul>
                    </div>
                </div>

                <div className={styles.warning}>
                    <strong>⚠️ {t.footer.riskWarning}</strong> {t.footer.riskText}
                </div>

                <div className={styles.bottom}>
                    <p>{t.footer.copyright}</p>
                    <p>{t.footer.version}</p>
                </div>
            </div>
        </footer>
    );
}
