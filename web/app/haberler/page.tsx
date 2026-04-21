'use client';

import { useState, useEffect } from 'react';
import Link from 'next/link';
import DashboardLayout from '@/components/dashboard/DashboardLayout';
import Sidebar from '@/components/dashboard/Sidebar';
import Header from '@/components/dashboard/Header';
import { useLanguage } from '@/lib/LanguageContext';
import styles from './haberler.module.css';

interface NewsItem {
    id: string;
    title: string;
    description: string;
    link: string;
    pubDate: string;
    source: string;
    image?: string;
}

export default function NewsPage() {
    const { lang } = useLanguage();
    const [news, setNews] = useState<NewsItem[]>([]);
    const [loading, setLoading] = useState(true);
    const [error, setError] = useState('');
    const [filter, setFilter] = useState('all');
    const [dataSource, setDataSource] = useState('');
    const [sidebarOpen, setSidebarOpen] = useState(false);

    useEffect(() => {
        fetchNews();
    }, []);

    const fetchNews = async () => {
        try {
            setLoading(true);
            const response = await fetch('/api/news');
            const data = await response.json();

            if (data.success) {
                setNews(data.data);
                setDataSource(data.source);
            } else {
                setError('Haberler yüklenemedi');
            }
        } catch (err) {
            setError('Bağlantı hatası');
        } finally {
            setLoading(false);
        }
    };

    const sources = ['all', ...Array.from(new Set(news.map(n => n.source)))];
    const filteredNews = filter === 'all' ? news : news.filter(n => n.source === filter);

    const formatDate = (dateString: string) => {
        try {
            const date = new Date(dateString);
            const now = new Date();
            const diffMs = now.getTime() - date.getTime();
            const diffMins = Math.floor(diffMs / 60000);
            const diffHours = Math.floor(diffMins / 60);
            const diffDays = Math.floor(diffHours / 24);

            if (diffMins < 60) return `${diffMins} dk önce`;
            if (diffHours < 24) return `${diffHours} saat önce`;
            if (diffDays < 7) return `${diffDays} gün önce`;

            return date.toLocaleDateString('tr-TR', { day: 'numeric', month: 'short' });
        } catch {
            return '';
        }
    };

    return (
        <DashboardLayout>
            <div className={styles.page}>
                <Sidebar isOpen={sidebarOpen} onClose={() => setSidebarOpen(false)} />
                <main className={styles.main}>
                    <Header onMenuToggle={() => setSidebarOpen(true)} />
                    <div className={styles.content}>
                        <div className={styles.header}>
                            <div>
                                <h1>📰 {lang === 'tr' ? 'Finansal Haberler' : 'Financial News'}</h1>
                                <p>{lang === 'tr' ? 'BIST ve piyasalar hakkında güncel haberler' : 'Latest news about BIST and markets'}</p>
                            </div>
                            <div className={styles.headerActions}>
                                <span className={`${styles.badge} ${dataSource !== 'local' ? styles.live : styles.offline}`}>
                                    {dataSource !== 'local' ? '🟢 Canlı' : '📋 Örnek Veri'}
                                </span>
                                <button onClick={fetchNews} className={styles.refreshBtn} disabled={loading}>
                                    🔄 {loading ? 'Yükleniyor...' : 'Yenile'}
                                </button>
                            </div>
                        </div>

                        <div className={styles.filters}>
                            {sources.map((source) => (
                                <button
                                    key={source}
                                    className={`${styles.filterBtn} ${filter === source ? styles.active : ''}`}
                                    onClick={() => setFilter(source)}
                                >
                                    {source === 'all' ? (lang === 'tr' ? 'Tümü' : 'All') : source}
                                </button>
                            ))}
                        </div>

                        {error && (
                            <div className={styles.error}>
                                ⚠️ {error}
                            </div>
                        )}

                        {loading ? (
                            <div className={styles.loading}>
                                <div className={styles.spinner}></div>
                                <p>{lang === 'tr' ? 'Haberler yükleniyor...' : 'Loading news...'}</p>
                            </div>
                        ) : (
                            <div className={styles.grid}>
                                {filteredNews.map((item) => (
                                    <article key={item.id} className={styles.newsCard}>
                                        {item.image && (
                                            <div className={styles.cardImage}>
                                                <img src={item.image} alt={item.title} />
                                            </div>
                                        )}
                                        <div className={styles.cardContent}>
                                            <div className={styles.cardMeta}>
                                                <span className={styles.source}>{item.source}</span>
                                                <span className={styles.date}>{formatDate(item.pubDate)}</span>
                                            </div>
                                            <h3 className={styles.cardTitle}>{item.title}</h3>
                                            {item.description && (
                                                <p className={styles.cardDesc}>{item.description}</p>
                                            )}
                                            {item.link && item.link !== '#' && (
                                                <Link href={item.link} target="_blank" className={styles.readMore}>
                                                    Devamını Oku →
                                                </Link>
                                            )}
                                        </div>
                                    </article>
                                ))}
                            </div>
                        )}

                        {!loading && filteredNews.length === 0 && !error && (
                            <div className={styles.empty}>
                                <p>📭 {lang === 'tr' ? 'Bu kategoride haber bulunamadı.' : 'No news found in this category.'}</p>
                            </div>
                        )}
                    </div>
                </main>
            </div>
        </DashboardLayout>
    );
}
