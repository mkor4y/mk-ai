'use client';

import { useState, useRef, useEffect } from 'react';
import DashboardLayout from '@/components/dashboard/DashboardLayout';
import Sidebar from '@/components/dashboard/Sidebar';
import Header from '@/components/dashboard/Header';
import { useLanguage } from '@/lib/LanguageContext';
import styles from './chat.module.css';

interface Message {
    id: string;
    role: 'user' | 'assistant';
    content: string;
    timestamp: Date;
}

// Telegram tarzı komutlar
const COMMANDS = [
    { cmd: '/menu', icon: '🏠', label: 'Ana Menü', desc: 'Tüm seçenekleri göster' },
    { cmd: '/analyze', icon: '📊', label: 'Hisse Analizi', desc: 'Kapsamlı teknik analiz' },
    { cmd: '/price', icon: '💰', label: 'Fiyat Sorgula', desc: 'Anlık fiyat bilgisi' },
    { cmd: '/education', icon: '📚', label: 'Eğitim', desc: 'Yatırım eğitimi' },
    { cmd: '/help', icon: '❓', label: 'Yardım', desc: 'Komutlar ve kullanım' },
];

const STOCKS = ['THYAO', 'GARAN', 'ASELS', 'AKBNK', 'TUPRS', 'KCHOL', 'SAHOL', 'EREGL', 'BIMAS', 'SISE', 'FROTO', 'TOASO'];

const QUICK_PROMPTS = [
    { emoji: '📊', text: 'THYAO teknik analizi yap' },
    { emoji: '📈', text: 'BIST 100 bugün nasıl?' },
    { emoji: '🎯', text: 'RSI göstergesini açıkla' },
    { emoji: '💰', text: 'Altın/Dolar son durum' },
    { emoji: '⚠️', text: 'Risk yönetimi nedir?' },
    { emoji: '🏦', text: 'Bankacılık hisseleri' },
];

export default function ChatPage() {
    const { lang } = useLanguage();
    const [messages, setMessages] = useState<Message[]>([]);
    const [input, setInput] = useState('');
    const [loading, setLoading] = useState(false);
    const [showCommandMenu, setShowCommandMenu] = useState(false);
    const [showStockPicker, setShowStockPicker] = useState<'analyze' | 'price' | null>(null);
    const [sidebarOpen, setSidebarOpen] = useState(false);
    const messagesEndRef = useRef<HTMLDivElement>(null);
    const inputRef = useRef<HTMLTextAreaElement>(null);

    // Initial welcome message
    useEffect(() => {
        if (messages.length === 0) {
            setMessages([{
                id: 'welcome',
                role: 'assistant',
                content: `🤖 **Merhaba! Ben MK AI, BIST uzmanı yapay zeka asistanınızım.**

**Kullanılabilir Komutlar:**
• \`/menu\` - Ana menüyü göster
• \`/analyze THYAO\` - Hisse analizi yap
• \`/price GARAN\` - Fiyat sorgula
• \`/education\` - Eğitim içerikleri
• \`/help\` - Yardım

📊 **Hızlı Başlangıç:** Aşağıdaki menüden bir komut seçin veya doğrudan yazın!`,
                timestamp: new Date()
            }]);
        }
    }, []);

    const scrollToBottom = () => {
        messagesEndRef.current?.scrollIntoView({ behavior: 'smooth' });
    };

    useEffect(() => {
        scrollToBottom();
    }, [messages]);

    // Input değiştiğinde / ile başlıyorsa menüyü göster
    useEffect(() => {
        if (input.startsWith('/') && input.length < 10) {
            setShowCommandMenu(true);
        } else {
            setShowCommandMenu(false);
        }
    }, [input]);

    const handleCommand = (command: string) => {
        if (command === '/analyze') {
            setShowStockPicker('analyze');
            setShowCommandMenu(false);
            setInput('');
        } else if (command === '/price') {
            setShowStockPicker('price');
            setShowCommandMenu(false);
            setInput('');
        } else if (command === '/menu') {
            showMenuMessage();
            setShowCommandMenu(false);
            setInput('');
        } else if (command === '/education') {
            sendMessage('Yatırım eğitimi konularını göster');
            setShowCommandMenu(false);
            setInput('');
        } else if (command === '/help') {
            sendMessage('yardım');
            setShowCommandMenu(false);
            setInput('');
        }
    };

    const showMenuMessage = () => {
        const menuContent = `🏠 **ANA MENÜ**

Aşağıdaki seçeneklerden birini seçin:

📊 **Hisse Analizi** - \`/analyze [HİSSE]\`
• Kapsamlı teknik + temel analiz
• AI destekli yorum
• Haber analizi

💰 **Fiyat Sorgula** - \`/price [HİSSE]\`
• Anlık fiyat bilgisi
• 24 saatlik değişim
• Hacim bilgisi

📚 **Eğitim** - \`/education\`
• RSI, MACD, Bollinger
• Risk yönetimi
• Temel analiz

❓ **Yardım** - \`/help\`
• Komut listesi
• Kullanım kılavuzu`;

        setMessages(prev => [...prev, {
            id: Date.now().toString(),
            role: 'assistant',
            content: menuContent,
            timestamp: new Date()
        }]);
    };

    const handleStockSelect = (stock: string) => {
        if (showStockPicker === 'analyze') {
            sendMessage(`${stock} analiz et`);
        } else if (showStockPicker === 'price') {
            sendMessage(`${stock} fiyat`);
        }
        setShowStockPicker(null);
    };

    const sendMessage = async (text: string) => {
        if (!text.trim() || loading) return;

        const userMessage: Message = {
            id: Date.now().toString(),
            role: 'user',
            content: text.trim(),
            timestamp: new Date()
        };

        setMessages(prev => [...prev, userMessage]);
        setInput('');
        setLoading(true);

        try {
            const response = await fetch('/api/chat', {
                method: 'POST',
                headers: { 'Content-Type': 'application/json' },
                body: JSON.stringify({
                    messages: [...messages.filter(m => m.id !== 'welcome'), userMessage].map(m => ({
                        role: m.role,
                        content: m.content
                    }))
                })
            });

            const data = await response.json();

            if (data.success) {
                setMessages(prev => [...prev, {
                    id: (Date.now() + 1).toString(),
                    role: 'assistant',
                    content: data.response || data.message,
                    timestamp: new Date()
                }]);
            } else {
                setMessages(prev => [...prev, {
                    id: (Date.now() + 1).toString(),
                    role: 'assistant',
                    content: `❌ Hata: ${data.error || data.message || 'Yanıt alınamadı'}`,
                    timestamp: new Date()
                }]);
            }
        } catch (error) {
            setMessages(prev => [...prev, {
                id: (Date.now() + 1).toString(),
                role: 'assistant',
                content: '❌ Bağlantı hatası. Python backend çalışıyor mu?\n\nBaşlatmak için:\n```\ncd c:\\mymodel\n.\\venv\\Scripts\\activate\npython -m uvicorn api.main:app --reload --port 8000\n```',
                timestamp: new Date()
            }]);
        } finally {
            setLoading(false);
        }
    };

    const handleSubmit = (e: React.FormEvent) => {
        e.preventDefault();

        // Slash komut kontrolü
        if (input.startsWith('/')) {
            const parts = input.split(' ');
            const cmd = parts[0].toLowerCase();
            const arg = parts[1]?.toUpperCase();

            if (cmd === '/analyze' && arg) {
                sendMessage(`${arg} analiz et`);
            } else if (cmd === '/price' && arg) {
                sendMessage(`${arg} fiyat`);
            } else if (cmd === '/analyze' || cmd === '/price') {
                handleCommand(cmd);
            } else if (cmd === '/menu') {
                showMenuMessage();
                setInput('');
            } else if (cmd === '/education') {
                sendMessage('Yatırım eğitimi konularını göster');
                setInput('');
            } else if (cmd === '/help') {
                sendMessage('yardım');
                setInput('');
            } else {
                sendMessage(input);
            }
        } else {
            sendMessage(input);
        }
    };

    const handleKeyDown = (e: React.KeyboardEvent) => {
        if (e.key === 'Enter' && !e.shiftKey) {
            e.preventDefault();
            handleSubmit(e);
        }
    };

    const clearChat = () => {
        setMessages([{
            id: 'welcome',
            role: 'assistant',
            content: '🔄 Sohbet temizlendi. `/menu` yazarak başlayabilirsiniz.',
            timestamp: new Date()
        }]);
    };

    return (
        <DashboardLayout>
            <div className={styles.page}>
                <Sidebar isOpen={sidebarOpen} onClose={() => setSidebarOpen(false)} />
                <main className={styles.main}>
                    <Header onMenuToggle={() => setSidebarOpen(true)} />
                    <div className={styles.chatContainer}>
                        {/* Header */}
                        <div className={styles.header}>
                            <div className={styles.headerInfo}>
                                <div className={styles.avatar}>🤖</div>
                                <div>
                                    <h1>MK AI Asistan</h1>
                                    <span className={styles.status}>
                                        <span className={styles.statusDot}></span>
                                        {loading ? 'Yazıyor...' : 'Çevrimiçi'}
                                    </span>
                                </div>
                            </div>
                            <button onClick={clearChat} className={styles.clearBtn}>
                                🗑️ Temizle
                            </button>
                        </div>

                        {/* Command Menu Bar */}
                        <div className={styles.commandBar}>
                            {COMMANDS.map((cmd) => (
                                <button
                                    key={cmd.cmd}
                                    onClick={() => handleCommand(cmd.cmd)}
                                    className={styles.commandBtn}
                                    title={cmd.desc}
                                >
                                    <span>{cmd.icon}</span>
                                    <span>{cmd.label}</span>
                                </button>
                            ))}
                        </div>

                        {/* Stock Picker Modal */}
                        {showStockPicker && (
                            <div className={styles.stockPickerOverlay} onClick={() => setShowStockPicker(null)}>
                                <div className={styles.stockPicker} onClick={e => e.stopPropagation()}>
                                    <h3>{showStockPicker === 'analyze' ? '📊 Analiz Edilecek Hisse' : '💰 Fiyat Sorgulanacak Hisse'}</h3>
                                    <div className={styles.stockGrid}>
                                        {STOCKS.map(stock => (
                                            <button
                                                key={stock}
                                                onClick={() => handleStockSelect(stock)}
                                                className={styles.stockBtn}
                                            >
                                                {stock}
                                            </button>
                                        ))}
                                    </div>
                                    <button onClick={() => setShowStockPicker(null)} className={styles.cancelBtn}>
                                        ❌ İptal
                                    </button>
                                </div>
                            </div>
                        )}

                        {/* Messages */}
                        <div className={styles.messages}>
                            {messages.map((message) => (
                                <div
                                    key={message.id}
                                    className={`${styles.message} ${styles[message.role]}`}
                                >
                                    <div className={styles.messageContent}>
                                        {message.role === 'assistant' && (
                                            <span className={styles.messageAvatar}>🤖</span>
                                        )}
                                        <div className={styles.messageBubble}>
                                            <div
                                                className={styles.messageText}
                                                dangerouslySetInnerHTML={{
                                                    __html: formatMessage(message.content)
                                                }}
                                            />
                                            <span className={styles.messageTime}>
                                                {message.timestamp.toLocaleTimeString('tr-TR', {
                                                    hour: '2-digit',
                                                    minute: '2-digit'
                                                })}
                                            </span>
                                        </div>
                                    </div>
                                </div>
                            ))}

                            {loading && (
                                <div className={`${styles.message} ${styles.assistant}`}>
                                    <div className={styles.messageContent}>
                                        <span className={styles.messageAvatar}>🤖</span>
                                        <div className={styles.messageBubble}>
                                            <div className={styles.typing}>
                                                <span></span>
                                                <span></span>
                                                <span></span>
                                            </div>
                                        </div>
                                    </div>
                                </div>
                            )}

                            <div ref={messagesEndRef} />
                        </div>

                        {/* Quick Prompts */}
                        {messages.length <= 1 && (
                            <div className={styles.quickPrompts}>
                                {QUICK_PROMPTS.map((prompt, i) => (
                                    <button
                                        key={i}
                                        onClick={() => sendMessage(prompt.text)}
                                        className={styles.quickPrompt}
                                    >
                                        <span>{prompt.emoji}</span>
                                        {prompt.text}
                                    </button>
                                ))}
                            </div>
                        )}

                        {/* Command Suggestions Dropdown */}
                        {showCommandMenu && (
                            <div className={styles.commandDropdown}>
                                {COMMANDS.filter(c => c.cmd.includes(input.toLowerCase())).map(cmd => (
                                    <button
                                        key={cmd.cmd}
                                        onClick={() => handleCommand(cmd.cmd)}
                                        className={styles.commandOption}
                                    >
                                        <span className={styles.cmdIcon}>{cmd.icon}</span>
                                        <div>
                                            <strong>{cmd.cmd}</strong>
                                            <span>{cmd.desc}</span>
                                        </div>
                                    </button>
                                ))}
                            </div>
                        )}

                        {/* Input */}
                        <form onSubmit={handleSubmit} className={styles.inputContainer}>
                            <textarea
                                ref={inputRef}
                                value={input}
                                onChange={(e) => setInput(e.target.value)}
                                onKeyDown={handleKeyDown}
                                placeholder="/ yazarak komutları görün veya soru sorun..."
                                className={styles.input}
                                rows={1}
                                disabled={loading}
                            />
                            <button
                                type="submit"
                                className={styles.sendBtn}
                                disabled={!input.trim() || loading}
                            >
                                {loading ? '⏳' : '📤'}
                            </button>
                        </form>


                    </div>
                </main>
            </div >
        </DashboardLayout >
    );
}

// Format markdown-like content
function formatMessage(content: string): string {
    return content
        .replace(/\*\*(.*?)\*\*/g, '<strong>$1</strong>')
        .replace(/\*(.*?)\*/g, '<em>$1</em>')
        .replace(/`([^`]+)`/g, '<code>$1</code>')
        .replace(/```([\s\S]*?)```/g, '<pre><code>$1</code></pre>')
        .replace(/\n/g, '<br/>');
}
