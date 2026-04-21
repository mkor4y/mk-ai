'use client';

import { useState } from 'react';
import DashboardLayout from '@/components/dashboard/DashboardLayout';
import Sidebar from '@/components/dashboard/Sidebar';
import Header from '@/components/dashboard/Header';
import styles from './analiz.module.css';

const POPULAR_STOCKS = [
    { code: 'THYAO', name: 'Türk Hava Yolları' },
    { code: 'GARAN', name: 'Garanti Bankası' },
    { code: 'ASELS', name: 'Aselsan' },
    { code: 'AKBNK', name: 'Akbank' },
    { code: 'TUPRS', name: 'Tüpraş' },
    { code: 'KCHOL', name: 'Koç Holding' },
    { code: 'SAHOL', name: 'Sabancı Holding' },
    { code: 'EREGL', name: 'Erdemir' },
    { code: 'BIMAS', name: 'BİM Mağazalar' },
    { code: 'SISE', name: 'Şişe Cam' },
    { code: 'FROTO', name: 'Ford Otosan' },
    { code: 'TOASO', name: 'Tofaş' },
];

interface AnalysisResult {
    stock_symbol: string;
    stock_info: {
        name: string;
        current_price: number;
        price_change_24h: number;
        volume_24h: number;
    };
    technical_data: {
        rsi: number;
        macd: number;
        macd_signal: number;
        macd_histogram: number;
        ma_20: number;
        ma_50: number;
        ma_100: number;
        adx: number;
        bb_upper: number;
        bb_middle: number;
        bb_lower: number;
        gap_pct: number;
    };
    signals: {
        rsi_signal: string;
        macd_signal: string;
        ma_signal: string;
        bb_signal: string;
        volume_signal: string;
        trend_signal: string;
        momentum_signal: string;
        overall_signal: string;
        confidence: number;
        risk_level: string;
        signal_strength: string;
        trend_regime: string;
        trend_direction: string;
    };
    ai_analysis: string;
}

export default function AnalysisPage() {
    const [stockCode, setStockCode] = useState('');
    const [loading, setLoading] = useState(false);
    const [result, setResult] = useState<AnalysisResult | null>(null);
    const [error, setError] = useState<string | null>(null);
    const [sidebarOpen, setSidebarOpen] = useState(false);

    const analyzeStock = async (code: string) => {
        if (!code.trim()) return;

        setLoading(true);
        setError(null);
        setResult(null);
        setStockCode(code.toUpperCase());

        try {
            const response = await fetch(`/api/analyze/${code.toUpperCase()}`);
            const data = await response.json();

            if (data.success) {
                // Backend'den gelen veri yapısı: { success: true, stock: "...", data: { ...AnalysisResult... }, ... }
                // Veya { success: true, stock: "...", analysis: "TEXT..." } (Eski yapı, artık kullanılmıyor olmalı ama kontrol edelim)
                // Yeni yapı: { success: true, stock: "...", data: { stock_symbol: "...", stock_info: {}, ... } }

                if (data.data) {
                    setResult(data.data);
                } else {
                    setError('Beklenmedik veri formatı.');
                }
            } else {
                setError(data.error || 'Analiz yapılamadı.');
            }
        } catch (err: any) {
            setError(err.message || 'Bağlantı hatası.');
        } finally {
            setLoading(false);
        }
    };

    const getSignalColor = (signal: string) => {
        if (['AL', 'YÜKSELEN', 'GÜÇLENEN', 'YÜKSEK_HACİM', 'YUKARI'].includes(signal)) return styles.signalBuy;
        if (['SAT', 'DÜŞEN', 'ZAYIFLAYAN', 'DÜŞÜK_HACİM', 'AŞAĞI'].includes(signal)) return styles.signalSell;
        return styles.signalNeutral;
    };

    const getRSIStatus = (rsi: number) => {
        if (rsi > 70) return { text: 'Aşırı Alım', color: '#ef4444' };
        if (rsi < 30) return { text: 'Aşırı Satım', color: '#10b981' };
        return { text: 'Nötr', color: '#f59e0b' };
    };

    return (
        <DashboardLayout>
            <div className={styles.page}>
                <Sidebar isOpen={sidebarOpen} onClose={() => setSidebarOpen(false)} />
                <main className={styles.main}>
                    <Header onMenuToggle={() => setSidebarOpen(true)} />
                    <div className={styles.content}>
                        {/* Search Section */}
                        <div className={styles.searchSection}>
                            <h1>📊 Hisse Analizi</h1>
                            <p>Gerçek zamanlı teknik göstergeler ve AI destekli analiz</p>

                            <div className={styles.searchBox}>
                                <input
                                    type="text"
                                    value={stockCode}
                                    onChange={(e) => setStockCode(e.target.value.toUpperCase())}
                                    onKeyDown={(e) => e.key === 'Enter' && analyzeStock(stockCode)}
                                    placeholder="Hisse kodu girin (örn: THYAO)"
                                    className={styles.searchInput}
                                />
                                <button
                                    onClick={() => analyzeStock(stockCode)}
                                    className={styles.searchBtn}
                                    disabled={loading}
                                >
                                    {loading ? '⏳' : '🔍'} Analiz Et
                                </button>
                            </div>

                            <div className={styles.popularStocks}>
                                <span>Popüler:</span>
                                {POPULAR_STOCKS.slice(0, 6).map((stock) => (
                                    <button
                                        key={stock.code}
                                        onClick={() => analyzeStock(stock.code)}
                                        className={styles.stockTag}
                                    >
                                        {stock.code}
                                    </button>
                                ))}
                            </div>

                            {error && (
                                <div className={styles.errorMessage}>
                                    ⚠️ {error}
                                </div>
                            )}
                        </div>

                        {/* Results */}
                        {result && (
                            <div className={styles.results}>
                                {/* Price Card */}
                                <div className={styles.priceCard}>
                                    <div className={styles.priceHeader}>
                                        <div>
                                            <h2>{result.stock_symbol}</h2>
                                            <span className={styles.stockName}>
                                                {result.stock_info.name}
                                            </span>
                                        </div>
                                        <div className={styles.priceInfo}>
                                            <span className={styles.price}>{result.stock_info.current_price.toFixed(2)} ₺</span>
                                            <span className={`${styles.change} ${result.stock_info.price_change_24h >= 0 ? styles.positive : styles.negative}`}>
                                                {result.stock_info.price_change_24h >= 0 ? '+' : ''}{result.stock_info.price_change_24h.toFixed(2)}%
                                            </span>
                                        </div>
                                    </div>
                                    <div className={styles.priceStats}>
                                        <div><span>Hacim</span><strong>{result.stock_info.volume_24h.toLocaleString()}</strong></div>
                                        <div><span>Destek</span><strong>{result.technical_data.bb_lower.toFixed(2)} ₺</strong></div>
                                        <div><span>Direnç</span><strong>{result.technical_data.bb_upper.toFixed(2)} ₺</strong></div>
                                    </div>
                                </div>

                                {/* Indicators Grid */}
                                <div className={styles.indicatorsGrid}>
                                    {/* RSI */}
                                    <div className={styles.indicatorCard}>
                                        <div className={styles.indicatorHeader}>
                                            <span className={styles.indicatorIcon}>📈</span>
                                            <h3>RSI (14)</h3>
                                        </div>
                                        <div className={styles.indicatorValue}>
                                            <span className={styles.bigValue}>{result.technical_data.rsi.toFixed(1)}</span>
                                            <span
                                                className={styles.indicatorStatus}
                                                style={{ color: getRSIStatus(result.technical_data.rsi).color }}
                                            >
                                                {getRSIStatus(result.technical_data.rsi).text}
                                            </span>
                                        </div>
                                        <div className={styles.rsiBar}>
                                            <div className={styles.rsiZones}>
                                                <span>0</span>
                                                <span>30</span>
                                                <span>70</span>
                                                <span>100</span>
                                            </div>
                                            <div className={styles.rsiTrack}>
                                                <div
                                                    className={styles.rsiIndicator}
                                                    style={{ left: `${result.technical_data.rsi}%` }}
                                                />
                                            </div>
                                        </div>
                                    </div>

                                    {/* MACD */}
                                    <div className={styles.indicatorCard}>
                                        <div className={styles.indicatorHeader}>
                                            <span className={styles.indicatorIcon}>🎯</span>
                                            <h3>MACD</h3>
                                        </div>
                                        <div className={styles.macdValues}>
                                            <div>
                                                <span>MACD</span>
                                                <strong style={{ color: result.technical_data.macd >= 0 ? '#10b981' : '#ef4444' }}>
                                                    {result.technical_data.macd.toFixed(2)}
                                                </strong>
                                            </div>
                                            <div>
                                                <span>Sinyal</span>
                                                <strong>{result.technical_data.macd_signal.toFixed(2)}</strong>
                                            </div>
                                        </div>
                                        <div className={styles.macdSignal}>
                                            {result.signals.macd_signal === 'AL' ? (
                                                <span className={styles.bullish}>🐂 Boğa Sinyali</span>
                                            ) : result.signals.macd_signal === 'SAT' ? (
                                                <span className={styles.bearish}>🐻 Ayı Sinyali</span>
                                            ) : (
                                                <span className={styles.neutral}>⚖️ Nötr</span>
                                            )}
                                        </div>
                                    </div>

                                    {/* Moving Averages */}
                                    <div className={styles.indicatorCard}>
                                        <div className={styles.indicatorHeader}>
                                            <span className={styles.indicatorIcon}>📊</span>
                                            <h3>Ortalamalar</h3>
                                        </div>
                                        <div className={styles.maList}>
                                            <div className={styles.maItem}>
                                                <span>SMA 20</span>
                                                <strong className={result.stock_info.current_price > result.technical_data.ma_20 ? styles.aboveMa : styles.belowMa}>
                                                    {result.technical_data.ma_20.toFixed(2)} ₺
                                                </strong>
                                            </div>
                                            <div className={styles.maItem}>
                                                <span>SMA 50</span>
                                                <strong className={result.stock_info.current_price > result.technical_data.ma_50 ? styles.aboveMa : styles.belowMa}>
                                                    {result.technical_data.ma_50.toFixed(2)} ₺
                                                </strong>
                                            </div>
                                            <div className={styles.maItem}>
                                                <span>SMA 100</span>
                                                <strong className={result.stock_info.current_price > result.technical_data.ma_100 ? styles.aboveMa : styles.belowMa}>
                                                    {result.technical_data.ma_100.toFixed(2)} ₺
                                                </strong>
                                            </div>
                                        </div>
                                    </div>

                                    {/* Signals Summary */}
                                    <div className={styles.indicatorCard}>
                                        <div className={styles.indicatorHeader}>
                                            <span className={styles.indicatorIcon}>🚀</span>
                                            <h3>Sinyaller</h3>
                                        </div>
                                        <div className={styles.signalsList}>
                                            <div className={styles.signalItem}>
                                                <span>Genel Görünüm</span>
                                                <span className={getSignalColor(result.signals.overall_signal)}>
                                                    {result.signals.overall_signal}
                                                </span>
                                            </div>
                                            <div className={styles.signalItem}>
                                                <span>Güven Skoru</span>
                                                <span style={{ color: '#38bdf8' }}>
                                                    %{result.signals.confidence}
                                                </span>
                                            </div>
                                            <div className={styles.signalItem}>
                                                <span>Risk</span>
                                                <span className={result.signals.risk_level === 'DÜŞÜK' ? styles.signalBuy : styles.signalSell}>
                                                    {result.signals.risk_level}
                                                </span>
                                            </div>
                                            <div className={styles.signalItem}>
                                                <span>Trend</span>
                                                <span className={getSignalColor(result.signals.trend_direction)}>
                                                    {result.signals.trend_direction}
                                                </span>
                                            </div>
                                        </div>
                                    </div>
                                </div>

                                {/* AI Analysis */}
                                <div className={styles.aiCard}>
                                    <div className={styles.aiHeader}>
                                        <span>🤖</span>
                                        <h3>Yapay Zeka Yorumu</h3>
                                    </div>
                                    <div className={styles.aiContent}>
                                        <p>{result.ai_analysis}</p>
                                    </div>
                                    <div className={styles.aiDisclaimer}>
                                        ⚠️ Bu analiz yapay zeka tarafından oluşturulmuştur ve yatırım tavsiyesi değildir.
                                    </div>
                                </div>
                            </div>
                        )}

                        {/* Empty State */}
                        {!result && !loading && !error && (
                            <div className={styles.emptyState}>
                                <span className={styles.emptyIcon}>📊</span>
                                <h3>Hisse Analizi Yapın</h3>
                                <p>Yukarıdan bir hisse kodu girin veya popüler hisselerden birini seçin. <br />Gerçek piyasa verileri ve yapay zeka ile anında analiz alın.</p>
                            </div>
                        )}

                        {/* Loading State */}
                        {loading && (
                            <div className={styles.loadingState}>
                                <div className={styles.spinner}></div>
                                <p>Piyasa verileri çekiliyor ve analiz ediliyor...<br /><small>(Bu işlem 5-10 saniye sürebilir)</small></p>
                            </div>
                        )}
                    </div>
                </main>
            </div>
        </DashboardLayout>
    );
}
