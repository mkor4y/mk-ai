'use client';

import { createContext, useContext, useState, useEffect, ReactNode } from 'react';
import { translations, Language, Translations } from '@/lib/translations';

interface LanguageContextType {
    lang: Language;
    t: Translations;
    setLang: (lang: Language) => void;
    toggleLang: () => void;
}

const LanguageContext = createContext<LanguageContextType | undefined>(undefined);

export function LanguageProvider({ children }: { children: ReactNode }) {
    const [lang, setLangState] = useState<Language>('tr');

    useEffect(() => {
        const saved = localStorage.getItem('lang') as Language;
        if (saved && (saved === 'tr' || saved === 'en')) {
            setLangState(saved);
        }
    }, []);

    const setLang = (newLang: Language) => {
        setLangState(newLang);
        localStorage.setItem('lang', newLang);
    };

    const toggleLang = () => {
        const newLang = lang === 'tr' ? 'en' : 'tr';
        setLang(newLang);
    };

    const t = translations[lang];

    return (
        <LanguageContext.Provider value={{ lang, t, setLang, toggleLang }}>
            {children}
        </LanguageContext.Provider>
    );
}

export function useLanguage() {
    const context = useContext(LanguageContext);
    if (!context) {
        throw new Error('useLanguage must be used within LanguageProvider');
    }
    return context;
}
