import { NextResponse } from 'next/server';

// Python backend URL
const PYTHON_API_URL = process.env.PYTHON_API_URL || 'http://localhost:8000';

interface Message {
    role: 'user' | 'assistant';
    content: string;
}

export async function POST(request: Request) {
    try {
        const { messages } = await request.json();

        if (!messages || !Array.isArray(messages)) {
            return NextResponse.json({ error: 'Messages required' }, { status: 400 });
        }

        // Get the last user message
        const lastMessage = messages[messages.length - 1];
        if (!lastMessage || lastMessage.role !== 'user') {
            return NextResponse.json({ error: 'No user message' }, { status: 400 });
        }

        // Extract stock code if mentioned
        const stockMatch = lastMessage.content.match(/\b(THYAO|GARAN|AKBNK|ASELS|TUPRS|KCHOL|SAHOL|EREGL|BIMAS|SISE|FROTO|TOASO|ISCTR|VAKBN|HALKB|KRDMD)\b/i);
        const stockCode = stockMatch ? stockMatch[1].toUpperCase() : null;

        try {
            // Call Python backend (Telegram bot's actual logic)
            const response = await fetch(`${PYTHON_API_URL}/api/chat`, {
                method: 'POST',
                headers: { 'Content-Type': 'application/json' },
                body: JSON.stringify({
                    message: lastMessage.content,
                    stock_code: stockCode
                })
            });

            if (response.ok) {
                const data = await response.json();

                if (data.success) {
                    return NextResponse.json({
                        success: true,
                        message: data.response,
                        provider: data.provider || 'telegram-bot'
                    });
                }
            }

            // Python backend hatası - hata mesajı döndür
            const errorText = await response.text();
            console.error('Python backend error:', errorText);

            return NextResponse.json({
                success: false,
                message: `❌ Python backend hatası. Lütfen backend'in çalıştığından emin olun.\n\nBackend başlatmak için:\n\`\`\`\ncd c:\\mymodel\npython -m uvicorn api.main:app --reload --port 8000\n\`\`\``,
                provider: 'error'
            });

        } catch (fetchError) {
            // Python backend'e bağlanılamadı
            console.error('Cannot connect to Python backend:', fetchError);

            return NextResponse.json({
                success: false,
                message: `⚠️ Python backend'e bağlanılamıyor.\n\n**Çözüm:**\nAşağıdaki komutu çalıştırın:\n\`\`\`\ncd c:\\mymodel\npython -m uvicorn api.main:app --reload --port 8000\n\`\`\`\n\nSonra bu sayfayı yenileyin.`,
                provider: 'error'
            });
        }

    } catch (error) {
        console.error('Chat API error:', error);
        return NextResponse.json({
            error: 'Bir hata oluştu',
            success: false
        }, { status: 500 });
    }
}
