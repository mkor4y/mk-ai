'use client';

import { useState, useEffect, useRef } from 'react';
import DashboardLayout from '@/components/dashboard/DashboardLayout';
import Sidebar from '@/components/dashboard/Sidebar';
import Header from '@/components/dashboard/Header';
import styles from './grafik.module.css';

declare global {
    interface Window {
        TradingView: any;
    }
}

const POPULAR_STOCKS = [
    { code: 'THYAO', name: 'Türk Hava Yolları' },
    { code: 'GARAN', name: 'Garanti Bankası' },
    { code: 'AKBNK', name: 'Akbank' },
    { code: 'TUPRS', name: 'Tüpraş' },
    { code: 'KCHOL', name: 'Koç Holding' },
    { code: 'SAHOL', name: 'Sabancı Holding' },
    { code: 'EREGL', name: 'Erdemir' },
    { code: 'BIMAS', name: 'BİM Mağazalar' },
    { code: 'SISE', name: 'Şişe Cam' },
    { code: 'FROTO', name: 'Ford Otosan' },
    { code: 'TOASO', name: 'Tofaş' },
    { code: 'ASELS', name: 'Aselsan' },
    { code: 'AEFES', name: 'Anadolu Efes' },
    { code: 'PETKM', name: 'Petkim' },
    { code: 'YKBNK', name: 'Yapı Kredi' },
    { code: 'HALKB', name: 'Halkbank' },
];

export default function GrafikPage() {
    const [selectedStock, setSelectedStock] = useState('THYAO');
    const [searchTerm, setSearchTerm] = useState('');
    const [sidebarOpen, setSidebarOpen] = useState(false);
    const containerRef = useRef<HTMLDivElement>(null);

    useEffect(() => {
        // Container'ı temizle ve yeni widget ekle
        if (!containerRef.current) return;

        // Önce içeriği temizle
        containerRef.current.innerHTML = '';

        // Unique container ID
        const containerId = `tv_chart_${Date.now()}`;

        // Inner div oluştur
        const innerDiv = document.createElement('div');
        innerDiv.id = containerId;
        innerDiv.style.width = '100%';
        innerDiv.style.height = '600px';
        containerRef.current.appendChild(innerDiv);

        // Script yükle ve widget oluştur
        const script = document.createElement('script');
        script.src = 'https://s3.tradingview.com/tv.js';
        script.async = true;
        script.onload = () => {
            if (window.TradingView) {
                new window.TradingView.widget({
                    "customer": "mynetcom",
                    "width": "100%",
                    "height": 600,
                    "symbol": selectedStock,
                    "interval": "D",
                    "timezone": "Europe/Istanbul",
                    "theme": "dark",
                    "style": "1",
                    "locale": "tr",
                    "toolbar_bg": "#0f0f0f",
                    "enable_publishing": false,
                    "allow_symbol_change": true,
                    "container_id": containerId
                });
            }
        };
        containerRef.current.appendChild(script);

        return () => {
            // Cleanup
            if (containerRef.current) {
                containerRef.current.innerHTML = '';
            }
        };
    }, [selectedStock]);

    const handleStockSelect = (code: string) => {
        if (code !== selectedStock) {
            setSelectedStock(code);
            setSearchTerm('');
        }
    };

    const filteredStocks = POPULAR_STOCKS.filter(stock =>
        stock.code.toLowerCase().includes(searchTerm.toLowerCase()) ||
        stock.name.toLowerCase().includes(searchTerm.toLowerCase())
    );

    return (
        <DashboardLayout>
            <div className={styles.page}>
                <Sidebar isOpen={sidebarOpen} onClose={() => setSidebarOpen(false)} />
                <main className={styles.main}>
                    <Header onMenuToggle={() => setSidebarOpen(true)} />
                    <div className={styles.content}>
                        {/* Header Section */}
                        <div className={styles.headerSection}>
                            <div className={styles.titleArea}>
                                <h1>📈 Canlı Grafikler</h1>
                                <p>TradingView ile BIST hisselerini gerçek zamanlı takip edin</p>
                            </div>

                            <div className={styles.stockSelector}>
                                <div className={styles.searchBox}>
                                    <input
                                        type="text"
                                        value={searchTerm}
                                        onChange={(e) => setSearchTerm(e.target.value.toUpperCase())}
                                        placeholder="Hisse ara..."
                                        className={styles.searchInput}
                                    />
                                    <span className={styles.searchIcon}>🔍</span>
                                </div>

                                <div className={styles.stockTags}>
                                    {filteredStocks.map((stock) => (
                                        <button
                                            key={stock.code}
                                            onClick={() => handleStockSelect(stock.code)}
                                            className={`${styles.stockTag} ${selectedStock === stock.code ? styles.active : ''}`}
                                        >
                                            {stock.code}
                                        </button>
                                    ))}
                                </div>
                            </div>
                        </div>

                        {/* Current Stock Info */}
                        <div className={styles.currentStock}>
                            <span className={styles.stockBadge}>
                                <span className={styles.liveIndicator}></span>
                                {selectedStock}
                            </span>
                            <span className={styles.stockFullName}>
                                {POPULAR_STOCKS.find(s => s.code === selectedStock)?.name || selectedStock} - Teknik Analiz
                            </span>
                        </div>

                        {/* Chart Container */}
                        <div className={styles.chartWrapper}>
                            <div
                                ref={containerRef}
                                className={styles.chartContainer}
                            />
                            <div className={styles.tradingviewCopyright}>
                                TradingView'den <a
                                    href={`https://tr.tradingview.com/symbols/${selectedStock}/`}
                                    rel="noopener noreferrer"
                                    target="_blank"
                                >
                                    {selectedStock}
                                </a>
                            </div>
                        </div>

                        {/* Info Footer */}
                        <div className={styles.infoFooter}>
                            <div className={styles.infoCard}>
                                <span className={styles.infoIcon}>💡</span>
                                <div>
                                    <strong>İpucu</strong>
                                    <p>Grafik üzerinde farklı zaman dilimlerini seçebilir, teknik göstergeler ekleyebilir ve çizim araçlarını kullanabilirsiniz.</p>
                                </div>
                            </div>
                            <div className={styles.infoCard}>
                                <span className={styles.infoIcon}>⚠️</span>
                                <div>
                                    <strong>Uyarı</strong>
                                    <p>Veriler TradingView tarafından sağlanmaktadır. Yatırım kararlarınız için ek kaynakları da değerlendirin.</p>
                                </div>
                            </div>
                        </div>
                    </div>
                </main>
            </div>
        </DashboardLayout>
    );
}
