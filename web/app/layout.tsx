import type { Metadata } from 'next'
import { Inter } from 'next/font/google'
import './globals.css'
import { LanguageProvider } from '@/lib/LanguageContext'

const inter = Inter({ subsets: ['latin'] })

export const metadata: Metadata = {
    title: 'MK AI - BIST Analiz Platformu',
    description: 'Yapay zeka destekli Borsa İstanbul analiz platformu. Teknik analiz, haberler ve akıllı öneriler.',
    keywords: 'borsa, bist, hisse analizi, teknik analiz, yapay zeka, trading, stock analysis',
    authors: [{ name: 'Mustafa Koray KÖK' }],
    icons: {
        icon: '/images/favicon.png',
    },
    manifest: '/manifest.json',
}

export default function RootLayout({
    children,
}: {
    children: React.ReactNode
}) {
    return (
        <html lang="tr" suppressHydrationWarning>
            <head>
                <script
                    dangerouslySetInnerHTML={{
                        __html: `
              (function() {
                const theme = localStorage.getItem('theme') || 'dark';
                document.documentElement.setAttribute('data-theme', theme);
                
                // Service Worker kaydı
                if ('serviceWorker' in navigator) {
                  window.addEventListener('load', function() {
                    navigator.serviceWorker.register('/sw.js').then(function(reg) {
                      console.log('SW registered:', reg.scope);
                    }).catch(function(err) {
                      console.log('SW registration failed:', err);
                    });
                  });
                }
              })();
            `,
                    }}
                />
            </head>
            <body className={inter.className}>
                <LanguageProvider>
                    {children}
                </LanguageProvider>
            </body>
        </html>
    )
}
