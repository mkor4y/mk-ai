'use client';

import { useRef, useEffect } from 'react';
import Link from 'next/link';
import Image from 'next/image';
import { usePathname } from 'next/navigation';
import { useLanguage } from '@/lib/LanguageContext';
import styles from './Sidebar.module.css';

const menuItems = [
    { icon: '📊', href: '/dashboard', label: { tr: 'Dashboard', en: 'Dashboard' } },
    { icon: '🔍', href: '/analiz', label: { tr: 'Analiz', en: 'Analysis' } },
    { icon: '📰', href: '/haberler', label: { tr: 'Haberler', en: 'News' } },
    { icon: '🤖', href: '/chat', label: { tr: 'AI Chat', en: 'AI Chat' } },
    { icon: '📚', href: '/egitim', label: { tr: 'Eğitim', en: 'Education' } },
    { icon: '📈', href: '/grafik', label: { tr: 'Grafikler', en: 'Charts' } },
];

interface SidebarProps {
    isOpen?: boolean;
    onClose?: () => void;
}

export default function Sidebar({ isOpen = false, onClose }: SidebarProps) {
    const pathname = usePathname();
    const { lang } = useLanguage();
    const prevPathname = useRef(pathname);

    // Sadece navigasyon gerçekleştiğinde sidebar'ı kapat
    useEffect(() => {
        if (prevPathname.current !== pathname && onClose) {
            onClose();
        }
        prevPathname.current = pathname;
    }, [pathname, onClose]);

    return (
        <>
            {/* Overlay */}
            {isOpen && (
                <div
                    className={styles.overlay}
                    onClick={onClose}
                />
            )}

            <aside className={`${styles.sidebar} ${isOpen ? styles.open : ''}`}>
                <button
                    className={styles.closeButton}
                    onClick={onClose}
                    aria-label="Close"
                >
                    ✕
                </button>

                <div className={styles.logo}>
                    <Link href="/">
                        <Image src="/images/logo-dark.png" alt="MK AI" width={40} height={40} />
                        <span>MK AI</span>
                    </Link>
                </div>

                <nav className={styles.nav}>
                    {menuItems.map((item) => (
                        <Link
                            key={item.href}
                            href={item.href}
                            className={`${styles.navItem} ${pathname === item.href ? styles.active : ''}`}
                        >
                            <span className={styles.icon}>{item.icon}</span>
                            <span className={styles.label}>{item.label[lang]}</span>
                        </Link>
                    ))}
                </nav>

                <div className={styles.footer}>
                    <Link href="/" className={styles.backLink}>
                        ← {lang === 'tr' ? 'Ana Sayfa' : 'Home'}
                    </Link>
                </div>
            </aside>
        </>
    );
}
