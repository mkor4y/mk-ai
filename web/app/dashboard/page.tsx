'use client';

import { useState, useEffect } from 'react';
import DashboardLayout from '@/components/dashboard/DashboardLayout';
import Sidebar from '@/components/dashboard/Sidebar';
import Header from '@/components/dashboard/Header';
import Watchlist from '@/components/dashboard/Watchlist';
import MarketOverview from '@/components/dashboard/MarketOverview';
import QuickAnalysis from '@/components/dashboard/QuickAnalysis';
import RecentNews from '@/components/dashboard/RecentNews';
import styles from './dashboard.module.css';

interface DashboardData {
    indices: any[];
    watchlist: any[];
}

export default function DashboardPage() {
    const [data, setData] = useState<DashboardData | null>(null);
    const [loading, setLoading] = useState(true);
    const [sidebarOpen, setSidebarOpen] = useState(false);

    useEffect(() => {
        const fetchData = async () => {
            try {
                const res = await fetch('/api/market/summary');
                const json = await res.json();
                if (json.success) {
                    setData(json);
                }
            } catch (e) {
                console.error('Veri çekme hatası:', e);
            } finally {
                setLoading(false);
            }
        };

        fetchData();

        // 30 saniyede bir güncelle
        const interval = setInterval(fetchData, 30000);
        return () => clearInterval(interval);
    }, []);

    return (
        <DashboardLayout>
            <div className={styles.dashboard}>
                <Sidebar isOpen={sidebarOpen} onClose={() => setSidebarOpen(false)} />
                <main className={styles.main}>
                    <Header onMenuToggle={() => setSidebarOpen(true)} />
                    <div className={styles.content}>
                        {loading && !data ? (
                            <div style={{ padding: '20px', color: '#fff', textAlign: 'center' }}>
                                Veriler Yükleniyor...
                            </div>
                        ) : (
                            <div className={styles.grid}>
                                <div className={styles.primary}>
                                    <MarketOverview data={data?.indices} />
                                    <QuickAnalysis />
                                </div>
                                <div className={styles.secondary}>
                                    <Watchlist />
                                    <RecentNews />
                                </div>
                            </div>
                        )}
                    </div>
                </main>
            </div>
        </DashboardLayout>
    );
}
