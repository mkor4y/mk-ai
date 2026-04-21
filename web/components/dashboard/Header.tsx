'use client';

import { useState } from 'react';
import { useLanguage } from '@/lib/LanguageContext';
import styles from './Header.module.css';

interface HeaderProps {
    onMenuToggle?: () => void;
}

export default function Header({ onMenuToggle }: HeaderProps) {
    const { lang, toggleLang } = useLanguage();
    const [searchQuery, setSearchQuery] = useState('');

    return (
        <header className={styles.header}>
            {/* Hamburger Menu - Mobilde görünür */}
            <button
                className={styles.menuBtn}
                onClick={onMenuToggle}
                aria-label="Menu"
            >
                ☰
            </button>

            <div className={styles.search}>
                <span className={styles.searchIcon}>🔍</span>
                <input
                    type="text"
                    placeholder={lang === 'tr' ? 'Hisse ara... (örn: THYAO)' : 'Search stock... (e.g: THYAO)'}
                    value={searchQuery}
                    onChange={(e) => setSearchQuery(e.target.value)}
                    className={styles.searchInput}
                />
            </div>

            <div className={styles.actions}>
                <button className={styles.iconBtn} onClick={toggleLang} title="Language">
                    {lang === 'tr' ? 'EN' : 'TR'}
                </button>
                <button className={styles.iconBtn} title="Notifications">
                    🔔
                </button>
                <div className={styles.user}>
                    <div className={styles.avatar}>K</div>
                </div>
            </div>
        </header>
    );
}
