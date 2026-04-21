'use client';

import { useState, useEffect } from 'react';
import Image from 'next/image';
import Link from 'next/link';
import { useLanguage } from '@/lib/LanguageContext';
import styles from './Navbar.module.css';

export default function Navbar() {
    const [scrolled, setScrolled] = useState(false);
    const { lang, toggleLang, t } = useLanguage();

    useEffect(() => {
        const onScroll = () => setScrolled(window.scrollY > 20);
        window.addEventListener('scroll', onScroll);
        return () => window.removeEventListener('scroll', onScroll);
    }, []);

    return (
        <nav className={`${styles.navbar} ${scrolled ? styles.scrolled : ''}`}>
            <div className={styles.navContainer}>
                {/* Logo - Sol */}
                <Link href="/" className={styles.logo}>
                    <Image
                        src="/images/logo-dark.png"
                        alt="MK AI"
                        width={38}
                        height={38}
                    />
                    <span className={styles.logoText}>
                        <span className={styles.logoMain}>MK</span>
                        <span className={styles.logoHighlight}>AI</span>
                    </span>
                </Link>

                {/* Sağ taraf: Linkler + CTA Butonu */}
                <div className={styles.navRight}>
                    <ul className={styles.navLinks}>
                        <li><Link href="#features" className={styles.navLink}>{t.nav.features}</Link></li>
                        <li><Link href="#how-it-works" className={styles.navLink}>{t.nav.howItWorks}</Link></li>
                        <li><Link href="#technology" className={styles.navLink}>{lang === 'tr' ? 'Teknoloji' : 'Technology'}</Link></li>
                        <li><Link href="#stocks" className={styles.navLink}>{t.nav.stocks}</Link></li>
                        <li><Link href="#news" className={styles.navLink}>{lang === 'tr' ? 'Haberler' : 'News'}</Link></li>
                        <li>
                            <button onClick={toggleLang} className={styles.navLink}>
                                {lang === 'tr' ? 'English' : 'Türkçe'}
                            </button>
                        </li>
                    </ul>

                    <Link href="/dashboard" className={styles.ctaBtn}>
                        {t.nav.start}
                    </Link>
                </div>
            </div>
        </nav>
    );
}
