/** @type {import('next').NextConfig} */
const nextConfig = {
    reactStrictMode: true,

    // Cross-origin development için izin ver (Cloudflare Tunnel)
    allowedDevOrigins: [
        'indexes-halloween-hon-expects.trycloudflare.com',
    ],

    // API proxy ayarları (FastAPI backend'e yönlendirme)
    async rewrites() {
        // Prod'da API genellikle ayrı bir subdomain'de olur (örn: https://api.example.com)
        // Dev'da local FastAPI: http://localhost:8000
        const apiBaseUrl = process.env.API_BASE_URL || 'http://localhost:8000';
        return [
            {
                source: '/api/:path*',
                destination: `${apiBaseUrl}/api/:path*`,
            },
        ];
    },

    // Image patterns (yeni format)
    images: {
        remotePatterns: [
            {
                protocol: 'http',
                hostname: 'localhost',
            },
        ],
    },
};

module.exports = nextConfig;
