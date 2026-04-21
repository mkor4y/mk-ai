'use client';

import { useState } from 'react';
import { useLanguage } from '@/lib/LanguageContext';
import styles from './QuickAnalysis.module.css';

const popularStocks = ['THYAO', 'GARAN', 'ASELS', 'AKBNK', 'KRDMD', 'TUPRS', 'SAHOL', 'KCHOL'];

export default function QuickAnalysis() {
    const { lang } = useLanguage();
    const [selectedStock, setSelectedStock] = useState('');

    const handleAnalyze = () => {
        if (selectedStock) {
            window.location.href = `/analiz?stock=${selectedStock}`;
        }
    };

    return (
        <div className={styles.card}>
            <div className={styles.cardHeader}>
                <h2>{lang === 'tr' ? 'Hızlı Analiz' : 'Quick Analysis'}</h2>
            </div>

            <div className={styles.content}>
                <div className={styles.inputGroup}>
                    <label>{lang === 'tr' ? 'Hisse Kodu' : 'Stock Code'}</label>
                    <input
                        type="text"
                        placeholder={lang === 'tr' ? 'Örn: THYAO' : 'E.g: THYAO'}
                        value={selectedStock}
                        onChange={(e) => setSelectedStock(e.target.value.toUpperCase())}
                        className={styles.input}
                    />
                </div>

                <div className={styles.popular}>
                    <span className={styles.popularLabel}>
                        {lang === 'tr' ? 'Popüler:' : 'Popular:'}
                    </span>
                    <div className={styles.tags}>
                        {popularStocks.map((stock) => (
                            <button
                                key={stock}
                                className={`${styles.tag} ${selectedStock === stock ? styles.active : ''}`}
                                onClick={() => setSelectedStock(stock)}
                            >
                                {stock}
                            </button>
                        ))}
                    </div>
                </div>

                <button className={styles.analyzeBtn} onClick={handleAnalyze} disabled={!selectedStock}>
                    {lang === 'tr' ? 'Analiz Et' : 'Analyze'} →
                </button>
            </div>
        </div>
    );
}
