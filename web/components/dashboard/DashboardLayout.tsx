'use client';

import { ReactNode } from 'react';
import { LanguageProvider } from '@/lib/LanguageContext';

interface DashboardLayoutProps {
    children: ReactNode;
}

export default function DashboardLayout({ children }: DashboardLayoutProps) {
    return (
        <LanguageProvider>
            {children}
        </LanguageProvider>
    );
}
