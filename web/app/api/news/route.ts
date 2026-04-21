import { NextResponse } from 'next/server';

interface NewsItem {
    id: string;
    title: string;
    description: string;
    link: string;
    pubDate: string;
    source: string;
    image?: string;
}

// Maximum Turkish finance/economy news RSS feeds
const RSS_SOURCES = [
    // Major Finance News
    { name: 'Bloomberg HT', url: 'https://www.bloomberght.com/rss' },
    { name: 'Dünya Ekonomi', url: 'https://www.dunya.com/rss/ekonomi' },
    { name: 'Dünya Borsa', url: 'https://www.dunya.com/rss/borsa-finans' },
    { name: 'Ekonomim', url: 'https://www.ekonomim.com/rss' },
    { name: 'Bigpara', url: 'https://bigpara.hurriyet.com.tr/rss/' },
    { name: 'Para Analiz', url: 'https://www.paraanaliz.com/feed/' },

    // Major News Portals - Economy Sections
    { name: 'Hürriyet Ekonomi', url: 'https://www.hurriyet.com.tr/rss/ekonomi' },
    { name: 'Sözcü Ekonomi', url: 'https://www.sozcu.com.tr/rss/ekonomi.xml' },
    { name: 'Milliyet Ekonomi', url: 'https://www.milliyet.com.tr/rss/rssnew/ekonomiall.xml' },
    { name: 'Habertürk Ekonomi', url: 'https://www.haberturk.com/rss/ekonomi.xml' },
    { name: 'NTV Ekonomi', url: 'https://www.ntv.com.tr/ekonomi.rss' },
    { name: 'CNN Türk Ekonomi', url: 'https://www.cnnturk.com/feed/rss/ekonomi/news' },

    // Business News
    { name: 'Fortune Türkiye', url: 'https://www.fortuneturkey.com/rss' },
    { name: 'Capital', url: 'https://www.capital.com.tr/rss' },
];

// GNews API (optional)
const GNEWS_API_KEY = process.env.GNEWS_API_KEY || '';

export async function GET() {
    const allNews: NewsItem[] = [];

    // GNews API (if key available)
    if (GNEWS_API_KEY) {
        try {
            const keywords = encodeURIComponent('borsa istanbul bist hisse thyao');
            const url = `https://gnews.io/api/v4/search?q=${keywords}&lang=tr&country=tr&max=10&apikey=${GNEWS_API_KEY}`;

            const response = await fetch(url, { next: { revalidate: 300 } });

            if (response.ok) {
                const data = await response.json();
                data.articles?.forEach((article: any, index: number) => {
                    allNews.push({
                        id: `gnews-${index}`,
                        title: article.title,
                        description: article.description || '',
                        link: article.url,
                        pubDate: article.publishedAt,
                        source: article.source?.name || 'GNews',
                        image: article.image
                    });
                });
            }
        } catch (e) {
            console.error('GNews error:', e);
        }
    }

    // Fetch from all RSS sources in parallel
    const rssPromises = RSS_SOURCES.map(async (source) => {
        try {
            const rssUrl = encodeURIComponent(source.url);
            const url = `https://api.rss2json.com/v1/api.json?rss_url=${rssUrl}`;

            const controller = new AbortController();
            const timeoutId = setTimeout(() => controller.abort(), 5000);

            const response = await fetch(url, {
                next: { revalidate: 300 },
                signal: controller.signal
            });

            clearTimeout(timeoutId);

            if (response.ok) {
                const data = await response.json();

                if (data.status === 'ok' && data.items?.length > 0) {
                    return data.items.slice(0, 4).map((item: any, index: number) => {
                        // Extract image from multiple sources
                        let image = item.thumbnail ||
                            item.enclosure?.link ||
                            item.enclosure?.url ||
                            extractImageFromContent(item.content) ||
                            extractImageFromContent(item.description);

                        return {
                            id: `${source.name.toLowerCase().replace(/\s+/g, '-')}-${index}`,
                            title: cleanText(item.title),
                            description: cleanText(item.description?.replace(/<[^>]*>/g, ''))?.substring(0, 200) || '',
                            link: item.link,
                            pubDate: item.pubDate,
                            source: source.name,
                            image: image
                        };
                    });
                }
            }
        } catch (e) {
            // Silent fail for individual sources
        }
        return [];
    });

    const rssResults = await Promise.all(rssPromises);
    rssResults.forEach(items => allNews.push(...items));

    // Filter only stock market related news
    const stockNews = allNews.filter(item => isStockRelated(item.title + ' ' + item.description));

    // Sort by date (newest first)
    stockNews.sort((a, b) => {
        const dateA = new Date(a.pubDate).getTime() || 0;
        const dateB = new Date(b.pubDate).getTime() || 0;
        return dateB - dateA;
    });

    // Remove duplicates by title similarity
    const uniqueNews = removeDuplicates(stockNews);

    if (uniqueNews.length > 0) {
        return NextResponse.json({
            success: true,
            data: uniqueNews.slice(0, 30),
            source: 'live',
            totalSources: RSS_SOURCES.length,
            activeSources: [...new Set(uniqueNews.map(n => n.source))].length
        });
    }

    return NextResponse.json({
        success: true,
        data: getLocalNews(),
        source: 'local'
    });
}

// Extract first image from HTML content
function extractImageFromContent(content: string | undefined): string | undefined {
    if (!content) return undefined;

    // Try to find img src
    const imgMatch = content.match(/<img[^>]+src=["']([^"']+)["']/i);
    if (imgMatch) return imgMatch[1];

    // Try to find media:content
    const mediaMatch = content.match(/url=["']([^"']+\.(jpg|jpeg|png|gif|webp))/i);
    if (mediaMatch) return mediaMatch[1];

    return undefined;
}

// Clean HTML entities and trim
function cleanText(text: string | undefined): string {
    if (!text) return '';
    return text
        .replace(/&amp;/g, '&')
        .replace(/&lt;/g, '<')
        .replace(/&gt;/g, '>')
        .replace(/&quot;/g, '"')
        .replace(/&#039;/g, "'")
        .replace(/&nbsp;/g, ' ')
        .trim();
}

// Remove duplicate news by similar titles
function removeDuplicates(news: NewsItem[]): NewsItem[] {
    const seen = new Set<string>();
    return news.filter(item => {
        const key = item.title.toLowerCase().substring(0, 50);
        if (seen.has(key)) return false;
        seen.add(key);
        return true;
    });
}

// Check if news is stock market related
function isStockRelated(text: string): boolean {
    const keywords = [
        // Borsa terimleri
        'borsa', 'bist', 'hisse', 'endeks', 'pay', 'yatırım', 'yatirim',
        // Finans
        'banka', 'faiz', 'dolar', 'euro', 'tl', 'kur', 'döviz', 'doviz',
        // Piyasa
        'piyasa', 'alım', 'satım', 'yükseliş', 'düşüş', 'rally', 'resesyon',
        // Analiz
        'kar', 'zarar', 'bilanço', 'gelir', 'temettü', 'sermaye', 'halka arz',
        // Hisse kodları
        'thyao', 'garan', 'akbnk', 'isctr', 'asels', 'tuprs', 'kchol', 'sahol',
        'sise', 'eregl', 'krdmd', 'froto', 'toaso', 'bimas', 'arclk', 'tcell',
        'vakbn', 'halkb', 'petkm', 'kozal', 'mgros', 'tavhl', 'ekgyo', 'pgsus',
        // Kurumlar
        'tcmb', 'merkez bankası', 'spk', 'bddk', 'hazine',
        // Ekonomi finans
        'enflasyon', 'tahvil', 'bono', 'altın', 'altin', 'petrol', 'emtia',
        'kripto', 'bitcoin', 'fon', 'portföy', 'etf', 'viop'
    ];

    const lowerText = text.toLowerCase();
    return keywords.some(keyword => lowerText.includes(keyword));
}

function getLocalNews(): NewsItem[] {
    const now = new Date();
    return [
        {
            id: '1',
            title: 'BIST 100 Güne Yükselişle Başladı',
            description: 'Borsa İstanbul\'da BIST 100 endeksi pozitif açıldı.',
            link: '#',
            pubDate: new Date(now.getTime() - 2 * 60 * 60 * 1000).toISOString(),
            source: 'Fallback',
        }
    ];
}
