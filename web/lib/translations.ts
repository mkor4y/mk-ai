// Dil çevirileri - Türkçe ve İngilizce
export const translations = {
    tr: {
        // Navbar
        nav: {
            features: 'Özellikler',
            howItWorks: 'Nasıl Çalışır',
            stocks: 'Hisseler',
            about: 'Hakkında',
            dashboard: 'Dashboard',
            start: 'Başla',
        },

        // Hero
        hero: {
            badge: 'AI Destekli',
            badgeHighlight: 'BIST Analiz',
            title: 'Borsa İstanbul\'da',
            titleHighlight: 'Akıllı Yatırım',
            description: 'Yapay zeka destekli teknik analiz, anlık haber takibi ve trading sinyalleri ile BIST yatırımlarınızı güçlendirin.',
            cta: 'Analiz Yap',
            secondary: 'Nasıl Çalışır?',
            stats: {
                stocks: 'BIST Hissesi',
                sources: 'Haber Kaynağı',
                indicators: 'Teknik Gösterge',
            },
            liveCard: 'Popüler Hisseler',
            live: 'Canlı',
        },

        // Features
        features: {
            title: 'Neler Sunuyoruz?',
            subtitle: 'BIST yatırımlarınız için ihtiyacınız olan tüm araçlar tek platformda',
            items: [
                {
                    icon: '📊',
                    title: 'Teknik Analiz',
                    desc: 'RSI, MACD, Bollinger Bands ve ADX ile kapsamlı teknik analiz. Trend yönü ve momentum göstergeleri.'
                },
                {
                    icon: '🎯',
                    title: 'Trading Sinyalleri',
                    desc: 'AL/SAT/BEKLE sinyalleri, güven skoru ve risk seviyesi ile karar desteği.'
                },
                {
                    icon: '📰',
                    title: 'Haber Analizi',
                    desc: '10+ kaynaktan anlık haberler ve duyarlılık analizi ile piyasa nabzını takip edin.'
                },
                {
                    icon: '🤖',
                    title: 'AI Destekli Yorumlar',
                    desc: 'DeepSeek AI modeli ile detaylı analiz ve yorum. Akıllı piyasa değerlendirmesi.'
                },
                {
                    icon: '📚',
                    title: 'Eğitim İçerikleri',
                    desc: 'Teknik analiz, risk yönetimi ve BIST yatırım stratejileri konusunda eğitici içerikler.'
                },
                {
                    icon: '💬',
                    title: 'Telegram Botu',
                    desc: 'Telegram üzerinden anlık analiz ve fiyat sorgulama. Hızlı ve kolay erişim.'
                }
            ]
        },

        // How It Works
        howItWorks: {
            title: 'Nasıl Çalışır?',
            subtitle: 'Üç adımda kapsamlı hisse analizi',
            steps: [
                {
                    num: '01',
                    title: 'Hisse Seçin',
                    desc: '20+ desteklenen BIST hissesinden birini seçin veya arama yapın.'
                },
                {
                    num: '02',
                    title: 'Analiz Alın',
                    desc: 'Teknik göstergeler, haber duyarlılığı ve AI yorumları ile kapsamlı analiz.'
                },
                {
                    num: '03',
                    title: 'Karar Verin',
                    desc: 'Trading sinyalleri, güven skoru ve risk seviyesi ile bilinçli karar.'
                }
            ]
        },

        // Indicators
        indicators: {
            title: 'Teknik Göstergeler',
            subtitle: 'Profesyonel düzeyde teknik analiz araçları',
            items: [
                {
                    name: 'RSI',
                    full: 'Relative Strength Index',
                    desc: 'Aşırı alım/satım seviyelerini tespit eder. 30 altı alım, 70 üstü satım sinyali.',
                    value: '0-100'
                },
                {
                    name: 'MACD',
                    full: 'Moving Average Convergence Divergence',
                    desc: 'Trend değişim sinyallerini yakalar. Sinyal çizgisi kesişimleri önemlidir.',
                    value: 'Sinyal'
                },
                {
                    name: 'Bollinger',
                    full: 'Bollinger Bands',
                    desc: 'Volatilite ve fiyat bantlarını gösterir. Bant dışı hareketler önemlidir.',
                    value: 'Bantlar'
                },
                {
                    name: 'ADX',
                    full: 'Average Directional Index',
                    desc: 'Trend gücünü ölçer. 25+ güçlü trend, altı yatay piyasa.',
                    value: '0-100'
                }
            ]
        },

        // Stocks
        stocks: {
            title: 'Desteklenen Hisseler',
            subtitle: 'BIST\'in en popüler hisselerini analiz edin',
            viewAll: 'Tümünü Gör',
            analyze: 'Analiz Et'
        },

        // CTA
        cta: {
            title: 'Hemen Başlayın',
            subtitle: 'Ücretsiz olarak BIST hisselerini analiz edin',
            button: 'Dashboard\'a Git',
            telegram: 'Telegram Bot'
        },

        // Footer
        footer: {
            desc: 'Yapay zeka destekli Borsa İstanbul analiz platformu. Teknik analiz, haberler ve trading sinyalleri tek yerde.',
            platform: 'Platform',
            resources: 'Kaynaklar',
            developer: 'Geliştirici',
            education: 'Eğitim',
            docs: 'Dokümantasyon',
            riskWarning: 'Risk Uyarısı:',
            riskText: 'Bu platform sadece bilgilendirme amaçlıdır ve yatırım tavsiyesi değildir. Yatırım kararlarınızı kendi araştırmanıza dayandırın. Geçmiş performans gelecekteki sonuçların garantisi değildir.',
            copyright: '© 2024 MK AI - Mustafa Koray KÖK. Tüm hakları saklıdır.',
            version: 'BIST Analiz Platformu v1.0'
        }
    },

    en: {
        // Navbar
        nav: {
            features: 'Features',
            howItWorks: 'How It Works',
            stocks: 'Stocks',
            about: 'About',
            dashboard: 'Dashboard',
            start: 'Get Started',
        },

        // Hero
        hero: {
            badge: 'AI Powered',
            badgeHighlight: 'BIST Analysis',
            title: 'Smart Investment in',
            titleHighlight: 'Borsa Istanbul',
            description: 'Empower your BIST investments with AI-powered technical analysis, real-time news tracking, and trading signals.',
            cta: 'Analyze Now',
            secondary: 'How It Works?',
            stats: {
                stocks: 'BIST Stocks',
                sources: 'News Sources',
                indicators: 'Indicators',
            },
            liveCard: 'Popular Stocks',
            live: 'Live',
        },

        // Features
        features: {
            title: 'What We Offer',
            subtitle: 'All the tools you need for BIST investments in one platform',
            items: [
                {
                    icon: '📊',
                    title: 'Technical Analysis',
                    desc: 'Comprehensive analysis with RSI, MACD, Bollinger Bands and ADX. Trend direction and momentum indicators.'
                },
                {
                    icon: '🎯',
                    title: 'Trading Signals',
                    desc: 'BUY/SELL/HOLD signals with confidence score and risk level for decision support.'
                },
                {
                    icon: '📰',
                    title: 'News Analysis',
                    desc: 'Real-time news from 10+ sources with sentiment analysis to track market pulse.'
                },
                {
                    icon: '🤖',
                    title: 'AI-Powered Insights',
                    desc: 'Detailed analysis with DeepSeek AI model. Intelligent market evaluation.'
                },
                {
                    icon: '📚',
                    title: 'Educational Content',
                    desc: 'Educational content on technical analysis, risk management and BIST investment strategies.'
                },
                {
                    icon: '💬',
                    title: 'Telegram Bot',
                    desc: 'Instant analysis and price queries via Telegram. Fast and easy access.'
                }
            ]
        },

        // How It Works
        howItWorks: {
            title: 'How It Works',
            subtitle: 'Comprehensive stock analysis in three steps',
            steps: [
                {
                    num: '01',
                    title: 'Select Stock',
                    desc: 'Choose from 20+ supported BIST stocks or search for one.'
                },
                {
                    num: '02',
                    title: 'Get Analysis',
                    desc: 'Comprehensive analysis with technical indicators, news sentiment and AI insights.'
                },
                {
                    num: '03',
                    title: 'Make Decision',
                    desc: 'Informed decision with trading signals, confidence score and risk level.'
                }
            ]
        },

        // Indicators
        indicators: {
            title: 'Technical Indicators',
            subtitle: 'Professional-grade technical analysis tools',
            items: [
                {
                    name: 'RSI',
                    full: 'Relative Strength Index',
                    desc: 'Detects overbought/oversold levels. Below 30 buy signal, above 70 sell signal.',
                    value: '0-100'
                },
                {
                    name: 'MACD',
                    full: 'Moving Average Convergence Divergence',
                    desc: 'Captures trend change signals. Signal line crossovers are important.',
                    value: 'Signal'
                },
                {
                    name: 'Bollinger',
                    full: 'Bollinger Bands',
                    desc: 'Shows volatility and price bands. Movements outside bands are significant.',
                    value: 'Bands'
                },
                {
                    name: 'ADX',
                    full: 'Average Directional Index',
                    desc: 'Measures trend strength. 25+ strong trend, below is sideways market.',
                    value: '0-100'
                }
            ]
        },

        // Stocks
        stocks: {
            title: 'Supported Stocks',
            subtitle: 'Analyze the most popular stocks on BIST',
            viewAll: 'View All',
            analyze: 'Analyze'
        },

        // CTA
        cta: {
            title: 'Get Started Now',
            subtitle: 'Analyze BIST stocks for free',
            button: 'Go to Dashboard',
            telegram: 'Telegram Bot'
        },

        // Footer
        footer: {
            desc: 'AI-powered Borsa Istanbul analysis platform. Technical analysis, news and trading signals in one place.',
            platform: 'Platform',
            resources: 'Resources',
            developer: 'Developer',
            education: 'Education',
            docs: 'Documentation',
            riskWarning: 'Risk Warning:',
            riskText: 'This platform is for informational purposes only and does not constitute investment advice. Base your investment decisions on your own research. Past performance is not a guarantee of future results.',
            copyright: '© 2024 MK AI - Mustafa Koray KÖK. All rights reserved.',
            version: 'BIST Analysis Platform v1.0'
        }
    }
};

export type Language = 'tr' | 'en';
export type Translations = typeof translations.tr;
