'use client';

import { useState } from 'react';
import Link from 'next/link';
import DashboardLayout from '@/components/dashboard/DashboardLayout';
import Sidebar from '@/components/dashboard/Sidebar';
import Header from '@/components/dashboard/Header';
import styles from './egitim.module.css';

const educationContent = [
    {
        id: 1,
        slug: 'teknik-analiz',
        icon: '📊',
        title: { tr: 'Teknik Analiz Temelleri', en: 'Technical Analysis Basics' },
        desc: { tr: 'Grafik okuma, trend çizgileri ve destek/direnç seviyeleri hakkında temel bilgiler.', en: 'Basic information about chart reading, trend lines and support/resistance levels.' },
        topics: [
            { tr: 'Mum Grafikleri', en: 'Candlestick Charts' },
            { tr: 'Trend Çizgileri', en: 'Trend Lines' },
            { tr: 'Destek ve Direnç', en: 'Support & Resistance' },
        ],
        level: { tr: 'Başlangıç', en: 'Beginner' },
        duration: '15 dk'
    },
    {
        id: 2,
        slug: 'rsi',
        icon: '📈',
        title: { tr: 'RSI Göstergesi', en: 'RSI Indicator' },
        desc: { tr: 'Relative Strength Index - aşırı alım ve satım bölgelerini tespit edin.', en: 'Relative Strength Index - identify overbought and oversold zones.' },
        topics: [
            { tr: 'RSI Hesaplama', en: 'RSI Calculation' },
            { tr: 'Aşırı Alım/Satım', en: 'Overbought/Oversold' },
            { tr: 'Diverjans', en: 'Divergence' },
        ],
        level: { tr: 'Orta', en: 'Intermediate' },
        duration: '20 dk'
    },
    {
        id: 3,
        slug: 'macd',
        icon: '🎯',
        title: { tr: 'MACD Stratejileri', en: 'MACD Strategies' },
        desc: { tr: 'Moving Average Convergence Divergence ile trend takibi ve sinyal üretimi.', en: 'Trend following and signal generation with MACD.' },
        topics: [
            { tr: 'MACD Bileşenleri', en: 'MACD Components' },
            { tr: 'Sinyal Kesişimleri', en: 'Signal Crossovers' },
            { tr: 'Histogram Analizi', en: 'Histogram Analysis' },
        ],
        level: { tr: 'Orta', en: 'Intermediate' },
        duration: '25 dk'
    },
    {
        id: 4,
        slug: 'bollinger',
        icon: '📉',
        title: { tr: 'Bollinger Bantları', en: 'Bollinger Bands' },
        desc: { tr: 'Volatilite analizi ve fiyat bantlarını kullanarak trade fırsatları.', en: 'Volatility analysis and trading opportunities using price bands.' },
        topics: [
            { tr: 'Bant Hesaplama', en: 'Band Calculation' },
            { tr: 'Squeeze Stratejisi', en: 'Squeeze Strategy' },
            { tr: 'Breakout Tespiti', en: 'Breakout Detection' },
        ],
        level: { tr: 'Orta', en: 'Intermediate' },
        duration: '20 dk'
    },
    {
        id: 5,
        slug: 'risk-yonetimi',
        icon: '⚠️',
        title: { tr: 'Risk Yönetimi', en: 'Risk Management' },
        desc: { tr: 'Pozisyon boyutlandırma, stop-loss ve portföy çeşitlendirmesi.', en: 'Position sizing, stop-loss and portfolio diversification.' },
        topics: [
            { tr: 'Stop-Loss Kullanımı', en: 'Using Stop-Loss' },
            { tr: 'Pozisyon Boyutu', en: 'Position Sizing' },
            { tr: 'Risk/Ödül Oranı', en: 'Risk/Reward Ratio' },
        ],
        level: { tr: 'Başlangıç', en: 'Beginner' },
        duration: '15 dk'
    },
    {
        id: 6,
        slug: 'psikoloji',
        icon: '🧠',
        title: { tr: 'Trading Psikolojisi', en: 'Trading Psychology' },
        desc: { tr: 'Duygusal kontrol, disiplin ve başarılı trader mindset.', en: 'Emotional control, discipline and successful trader mindset.' },
        topics: [
            { tr: 'FOMO ve FUD', en: 'FOMO and FUD' },
            { tr: 'Disiplin', en: 'Discipline' },
            { tr: 'Kayıp Yönetimi', en: 'Loss Management' },
        ],
        level: { tr: 'İleri', en: 'Advanced' },
        duration: '30 dk'
    },
];

export default function EducationPage() {
    const [sidebarOpen, setSidebarOpen] = useState(false);

    return (
        <DashboardLayout>
            <div className={styles.page}>
                <Sidebar isOpen={sidebarOpen} onClose={() => setSidebarOpen(false)} />
                <main className={styles.main}>
                    <Header onMenuToggle={() => setSidebarOpen(true)} />
                    <div className={styles.content}>
                        <div className={styles.header}>
                            <h1>📚 Eğitim / Education</h1>
                            <p>BIST yatırımları için temel ve ileri düzey eğitim içerikleri</p>
                        </div>

                        <div className={styles.grid}>
                            {educationContent.map((item) => (
                                <article key={item.id} className={styles.card}>
                                    <div className={styles.cardIcon}>{item.icon}</div>
                                    <div className={styles.cardContent}>
                                        <div className={styles.cardMeta}>
                                            <span className={styles.level}>{item.level.tr}</span>
                                            <span className={styles.duration}>⏱️ {item.duration}</span>
                                        </div>
                                        <h3>{item.title.tr}</h3>
                                        <p>{item.desc.tr}</p>
                                        <div className={styles.topics}>
                                            {item.topics.map((topic, i) => (
                                                <span key={i} className={styles.topic}>{topic.tr}</span>
                                            ))}
                                        </div>
                                        <Link href={`/egitim/${item.slug}`} className={styles.startBtn}>
                                            Başla →
                                        </Link>
                                    </div>
                                </article>
                            ))}
                        </div>
                    </div>
                </main>
            </div>
        </DashboardLayout>
    );
}
