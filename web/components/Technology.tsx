'use client';

import { useLanguage } from '@/lib/LanguageContext';
import styles from './Technology.module.css';

const technologies = {
    tr: [
        {
            icon: '🤖',
            name: 'Yapay Zeka',
            desc: 'Google Gemini AI ile gelişmiş doğal dil işleme ve analiz yetenekleri',
            features: ['Gerçek zamanlı analiz', 'Akıllı öneriler', 'Doğal dil işleme']
        },
        {
            icon: '📊',
            name: 'Teknik Analiz',
            desc: 'RSI, MACD, Bollinger Bands ve daha fazla gösterge ile kapsamlı analiz',
            features: ['20+ teknik gösterge', 'Otomatik sinyal üretimi', 'Trend tespiti']
        },
        {
            icon: '📰',
            name: 'Haber Analizi',
            desc: 'Finans haberlerinin AI ile sentiment analizi ve özet çıkarımı',
            features: ['Gerçek zamanlı haberler', 'Duygu analizi', 'Akıllı özetleme']
        },
        {
            icon: '⚡',
            name: 'Gerçek Zamanlı Veri',
            desc: 'BIST hisselerinin anlık fiyat ve hacim bilgileri',
            features: ['Canlı fiyatlar', 'Hacim takibi', 'Anlık güncelleme']
        },
        {
            icon: '🔒',
            name: 'Güvenlik',
            desc: 'Modern güvenlik standartları ile verileriniz güvende',
            features: ['SSL şifreleme', 'Güvenli API', 'Veri koruma']
        },
        {
            icon: '📱',
            name: 'Çoklu Platform',
            desc: 'Web, masaüstü ve mobil cihazlarda kesintisiz deneyim',
            features: ['PWA desteği', 'Electron uygulaması', 'Responsive tasarım']
        }
    ],
    en: [
        {
            icon: '🤖',
            name: 'Artificial Intelligence',
            desc: 'Advanced natural language processing and analysis capabilities with Google Gemini AI',
            features: ['Real-time analysis', 'Smart recommendations', 'NLP']
        },
        {
            icon: '📊',
            name: 'Technical Analysis',
            desc: 'Comprehensive analysis with RSI, MACD, Bollinger Bands and more indicators',
            features: ['20+ technical indicators', 'Auto signal generation', 'Trend detection']
        },
        {
            icon: '📰',
            name: 'News Analysis',
            desc: 'AI-powered sentiment analysis and summarization of financial news',
            features: ['Real-time news', 'Sentiment analysis', 'Smart summarization']
        },
        {
            icon: '⚡',
            name: 'Real-Time Data',
            desc: 'Instant price and volume information for BIST stocks',
            features: ['Live prices', 'Volume tracking', 'Instant updates']
        },
        {
            icon: '🔒',
            name: 'Security',
            desc: 'Your data is safe with modern security standards',
            features: ['SSL encryption', 'Secure API', 'Data protection']
        },
        {
            icon: '📱',
            name: 'Multi-Platform',
            desc: 'Seamless experience on web, desktop and mobile devices',
            features: ['PWA support', 'Electron app', 'Responsive design']
        }
    ]
};

export default function Technology() {
    const { lang } = useLanguage();
    const techList = technologies[lang];

    return (
        <section id="technology" className={styles.section}>
            <div className={styles.container}>
                <div className={styles.header}>
                    <span className={styles.badge}>⚙️ {lang === 'tr' ? 'Teknoloji' : 'Technology'}</span>
                    <h2>{lang === 'tr' ? 'Güçlü Teknoloji Altyapısı' : 'Powerful Technology Infrastructure'}</h2>
                    <p>
                        {lang === 'tr'
                            ? 'En son teknolojiler ile geliştirilen MK AI, size en iyi deneyimi sunmak için tasarlandı.'
                            : 'Developed with the latest technologies, MK AI is designed to provide you with the best experience.'
                        }
                    </p>
                </div>

                <div className={styles.grid}>
                    {techList.map((tech, index) => (
                        <div key={index} className={styles.card}>
                            <div className={styles.cardIcon}>{tech.icon}</div>
                            <h3>{tech.name}</h3>
                            <p>{tech.desc}</p>
                            <ul className={styles.features}>
                                {tech.features.map((feature, i) => (
                                    <li key={i}>
                                        <span className={styles.checkIcon}>✓</span>
                                        {feature}
                                    </li>
                                ))}
                            </ul>
                        </div>
                    ))}
                </div>

                {/* Tech Stack */}
                <div className={styles.techStack}>
                    <h4>{lang === 'tr' ? 'Kullanılan Teknolojiler' : 'Tech Stack'}</h4>
                    <div className={styles.stackGrid}>
                        <div className={styles.stackItem}>
                            <span>Next.js</span>
                        </div>
                        <div className={styles.stackItem}>
                            <span>React</span>
                        </div>
                        <div className={styles.stackItem}>
                            <span>TypeScript</span>
                        </div>
                        <div className={styles.stackItem}>
                            <span>Python</span>
                        </div>
                        <div className={styles.stackItem}>
                            <span>FastAPI</span>
                        </div>
                        <div className={styles.stackItem}>
                            <span>Gemini AI</span>
                        </div>
                    </div>
                </div>
            </div>
        </section>
    );
}
