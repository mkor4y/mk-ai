'use client';

import Link from 'next/link';
import { useLanguage } from '@/lib/LanguageContext';
import styles from './Hero.module.css';

const stocks = [
    { symbol: 'THYAO', name: 'Türk Hava Yolları', price: '285.50', change: '+2.35%', up: true },
    { symbol: 'GARAN', name: 'Garanti Bankası', price: '142.30', change: '-0.85%', up: false },
    { symbol: 'ASELS', name: 'Aselsan', price: '58.75', change: '+1.25%', up: true },
    { symbol: 'AKBNK', name: 'Akbank', price: '54.20', change: '+0.45%', up: true },
];

export default function Hero() {
    const { t } = useLanguage();

    return (
        <section className={styles.hero}>
            <div className={styles.heroContainer}>
                <div className={styles.heroContent}>
                    <div className={styles.badge}>
                        🤖 {t.hero.badge} <span>• {t.hero.badgeHighlight}</span>
                    </div>

                    <h1 className={styles.heroTitle}>
                        {t.hero.title}<br />
                        <span className={styles.highlight}>{t.hero.titleHighlight}</span>
                    </h1>

                    <p className={styles.heroDesc}>
                        {t.hero.description}
                    </p>

                    <div className={styles.heroButtons}>
                        <Link href="/dashboard" className="btn btn-primary">
                            {t.hero.cta} →
                        </Link>
                        <Link href="#how-it-works" className="btn btn-outline">
                            {t.hero.secondary}
                        </Link>
                    </div>

                    <div className={styles.heroStats}>
                        <div className={styles.stat}>
                            <h4>20+</h4>
                            <p>{t.hero.stats.stocks}</p>
                        </div>
                        <div className={styles.stat}>
                            <h4>10+</h4>
                            <p>{t.hero.stats.sources}</p>
                        </div>
                        <div className={styles.stat}>
                            <h4>5</h4>
                            <p>{t.hero.stats.indicators}</p>
                        </div>
                    </div>
                </div>

                <div className={styles.heroVisual}>
                    <div className={styles.visualCard}>
                        <div className={styles.cardHeader}>
                            <h3>📊 {t.hero.liveCard}</h3>
                            <span className={styles.live}>{t.hero.live}</span>
                        </div>

                        {stocks.map((stock) => (
                            <div key={stock.symbol} className={styles.stockItem}>
                                <div className={styles.stockInfo}>
                                    <h4>{stock.symbol}</h4>
                                    <p>{stock.name}</p>
                                </div>
                                <div className={styles.stockPrice}>
                                    <div className={styles.price}>{stock.price} ₺</div>
                                    <div className={`${styles.change} ${stock.up ? styles.up : styles.down}`}>
                                        {stock.change}
                                    </div>
                                </div>
                            </div>
                        ))}
                    </div>
                </div>
            </div>
        </section>
    );
}
