"""
MK AI Web API - Telegram botunun aynı fonksiyonlarını kullanır
"""
from fastapi import FastAPI, HTTPException
from fastapi.middleware.cors import CORSMiddleware
from pydantic import BaseModel
from typing import List, Optional
from datetime import datetime
import sys
import os

# Parent directory'yi path'e ekle
sys.path.insert(0, os.path.dirname(os.path.dirname(os.path.abspath(__file__))))

from bist_analyzer import BISTAnalyzer
from news_helper import NewsHelper
from chatgpt_helper import ChatGPTHelper
from config import Config

app = FastAPI(
    title="MK AI Web API",
    description="BIST Analiz - Telegram Bot Backend (Aynı çıktı)",
    version="1.0.0"
)

# CORS
# Prod'da web genellikle ayrı bir domain/subdomain'den gelir.
# CORS_ORIGINS="https://web.example.com,https://example.com" şeklinde verilebilir.
cors_origins_env = os.getenv("CORS_ORIGINS", "")
cors_origins = [o.strip() for o in cors_origins_env.split(",") if o.strip()] or [
    "http://localhost:3000",
    "http://127.0.0.1:3000",
]

app.add_middleware(
    CORSMiddleware,
    allow_origins=cors_origins,
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

# Modülleri başlat
config = Config()
analyzer = BISTAnalyzer()
news_helper = NewsHelper()
chatgpt_helper = ChatGPTHelper()


class ChatRequest(BaseModel):
    message: str
    stock_code: Optional[str] = None


class ChatResponse(BaseModel):
    success: bool
    response: str
    provider: str = "telegram-bot"


@app.get("/")
async def root():
    return {"message": "MK AI Web API", "status": "running"}


@app.post("/api/chat", response_model=ChatResponse)
async def chat(request: ChatRequest):
    """Telegram botunun AI analiz fonksiyonlarını çağırır"""
    try:
        message = request.message.lower()
        
        # Hisse kodu çıkar
        stock_code = request.stock_code
        if not stock_code:
            for code in config.SUPPORTED_BIST_STOCKS:
                if code.lower() in message:
                    stock_code = code
                    break
        
        # Hisse analizi
        if stock_code or 'analiz' in message or 'hisse' in message:
            if stock_code:
                response = perform_stock_analysis(stock_code.upper())
            else:
                response = "📊 Hangi hisseyi analiz etmemi istersiniz?\n\n" + \
                          "Desteklenen hisseler:\n" + \
                          ", ".join(config.SUPPORTED_BIST_STOCKS[:12])
            return ChatResponse(success=True, response=response, provider="bist-analyzer")
        
        # Eğitim içeriği
        education_keywords = ['rsi', 'macd', 'bollinger', 'teknik', 'temel', 
                             'destek', 'direnç', 'trend', 'gösterge', 'risk']
        for keyword in education_keywords:
            if keyword in message:
                response = chatgpt_helper.get_educational_content(keyword)
                return ChatResponse(success=True, response=response, provider="chatgpt-education")
        
        # Piyasa duyarlılığı
        if 'piyasa' in message or 'bist' in message or 'genel' in message:
            response = chatgpt_helper.get_market_sentiment(config.SUPPORTED_BIST_STOCKS[:10])
            return ChatResponse(success=True, response=response, provider="chatgpt-sentiment")
        
        # Yardım
        if 'yardım' in message or 'help' in message:
            response = chatgpt_helper.get_help_content()
            return ChatResponse(success=True, response=response, provider="chatgpt-help")
        
        # Genel sohbet
        from openai import OpenAI
        
        if config.AI_PROVIDER == 'groq':
            client = OpenAI(base_url=config.GROQ_BASE_URL, api_key=config.GROQ_API_KEY)
            model = config.GROQ_MODEL
        else:
            client = OpenAI(base_url=config.OPENROUTER_BASE_URL, api_key=config.OPENROUTER_API_KEY)
            model = config.OPENROUTER_MODEL
        
        ai_response = client.chat.completions.create(
            model=model,
            messages=[
                {"role": "system", "content": """Sen MK AI, Mustafa Koray Kök tarafından geliştirilen bir yapay zeka asistanısın.
                BIST hisseleri, teknik analiz, yatırım stratejileri konusunda uzmanlaşmış bir finansal asistansın.
                Seni kim yaptı veya kim geliştirdi diye sorulduğunda "Mustafa Koray Kök tarafından geliştirildim" de.
                Türkçe cevap ver, emoji kullan.
                Yatırım tavsiyesi verirken mutlaka risk uyarısı ekle.
                
                DİL KURALLARI (ÇOK ÖNEMLİ):
                - SADECE Türkçe yaz. ASLA Çince (中文), Japonca, Korece veya başka Asya dili karakterleri KULLANMA.
                - Yanıtlarında sadece Türkçe alfabesi (a-z, ç, ğ, ı, ö, ş, ü) ve standart ASCII karakterleri kullan.
                - Bu kural kesindir ve her durumda geçerlidir."""},
                {"role": "user", "content": message}
            ],
            max_tokens=2000,
            temperature=0.7
        )
        
        response = ai_response.choices[0].message.content
        return ChatResponse(success=True, response=response, provider="groq-chat")
        
    except Exception as e:
        import traceback
        raise HTTPException(status_code=500, detail=f"{str(e)}\n{traceback.format_exc()}")


@app.get("/api/analyze/{stock_code}")
async def analyze_stock(stock_code: str):
    """Telegram botunun tam hisse analizi (JSON formatında)"""
    try:
        stock_code = stock_code.upper()
        
        if stock_code not in config.SUPPORTED_BIST_STOCKS:
            return {
                "success": False,
                "error": f"Desteklenmeyen hisse: {stock_code}",
                "supported": config.SUPPORTED_BIST_STOCKS
            }
        
        analysis_data = get_stock_analysis_data(stock_code)
        
        if not analysis_data.get('success', False):
             return {
                "success": False,
                "error": analysis_data.get('error', 'Analiz hatası')
            }
            
        return {
            "success": True,
            "stock": stock_code,
            "data": analysis_data,
            "provider": "bist-analyzer"
        }
        
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))


@app.get("/api/market/summary")
async def get_market_summary():
    """Dashboard için piyasa özeti ve popüler hisseler"""
    try:
        # BIST Endeksleri
        indices_to_fetch = [
            {"symbol": "XU100", "name": "BIST 100"},
            {"symbol": "XU030", "name": "BIST 30"}
        ]
        
        indices_data = []
        for index in indices_to_fetch:
            info = analyzer.get_stock_info(index["symbol"])
            if info:
                indices_data.append({
                    "name": index["name"],
                    "value": f"{info.get('current_price', 0):,.2f}",
                    "change": f"{info.get('price_change_24h', 0):+.2f}%",
                    "up": info.get('price_change_24h', 0) >= 0
                })
        
        # Popüler Hisseler (Watchlist)
        # config.SUPPORTED_BIST_STOCKS listesinden ilk 6 tanesi
        watchlist_symbols = config.SUPPORTED_BIST_STOCKS[:6]
        watchlist_data = []
        
        for symbol in watchlist_symbols:
            info = analyzer.get_stock_info(symbol)
            if info:
                watchlist_data.append({
                    "symbol": symbol,
                    "name": info.get('name', symbol),
                    "price": f"{info.get('current_price', 0):.2f}",
                    "change": f"{info.get('price_change_24h', 0):+.2f}%",
                    "up": info.get('price_change_24h', 0) >= 0
                })
                
        return {
            "success": True,
            "indices": indices_data,
            "watchlist": watchlist_data,
            "timestamp": datetime.now().isoformat()
        }
        
    except Exception as e:
        import traceback
        print(traceback.format_exc())
        return {
            "success": False,
            "error": str(e),
            "indices": [],
            "watchlist": []
        }


# ============= TELEGRAM BOTU İLE AYNI FONKSİYONLAR =============

def get_stock_analysis_data(stock_symbol: str) -> dict:
    """
    Hisse analizi için tüm verileri toplayıp yapılandırılmış veri (dict) döndürür.
    Hem API (JSON) hem de Bot (Text) tarafından kullanılır.
    """
    try:
        # 1) Fiyat + teknik veri + sinyaller
        stock_info, technical_data, signals = _prepare_price_and_technical(stock_symbol)
        if stock_info is None:
            return {"success": False, "error": f"{stock_symbol} için hisse bilgisi alınamadı."}
        if technical_data is None or signals is None:
            return {"success": False, "error": f"{stock_symbol} için teknik analiz yapılamadı."}

        # 2) Haber verisi
        news_summary, newsapi_text = _prepare_news_data(stock_symbol)

        # 3) AI analizi
        ai_analysis = chatgpt_helper.get_stock_analysis(stock_info, technical_data, signals, news_summary)

        return {
            "success": True,
            "stock_symbol": stock_symbol,
            "stock_info": stock_info,
            "technical_data": technical_data,
            "signals": signals,
            "news_summary": news_summary,
            "newsapi_text": newsapi_text,
            "ai_analysis": ai_analysis
        }
    except Exception as e:
        import traceback
        return {"success": False, "error": f"Analiz hatası: {str(e)}"}


def perform_stock_analysis(stock_symbol: str) -> str:
    """
    BISTBot.perform_stock_analysis() - Telegram botu ile birebir aynı (Wrapper)
    """
    try:
        data = get_stock_analysis_data(stock_symbol)
        
        if not data.get('success'):
            return f"❌ {data.get('error')}"
        
        # 4) Sonuç mesajını oluştur
        result_message = _build_analysis_message(
            stock_symbol=data['stock_symbol'],
            stock_info=data['stock_info'],
            technical_data=data['technical_data'],
            signals=data['signals'],
            news_summary=data['news_summary'],
            newsapi_text=data['newsapi_text'],
            ai_analysis=data['ai_analysis'],
        )
        return result_message
    except Exception as e:
        import traceback
        return f"❌ {stock_symbol} analizi sırasında hata oluştu: {e}\n\n{traceback.format_exc()}"


def _prepare_price_and_technical(stock_symbol: str):
    """
    BISTBot._prepare_price_and_technical() - Telegram botu ile birebir aynı
    """
    try:
        # Fiyat ve temel bilgiler
        stock_info = analyzer.get_stock_info(stock_symbol)
        if not stock_info:
            return None, None, None

        # Grafik / OHLCV verisi
        df = analyzer.get_stock_data(stock_symbol, days=220)
        if df is None or df.empty:
            return stock_info, None, None

        # Teknik göstergeler
        df = analyzer.calculate_technical_indicators(df)
        if df is None or df.empty:
            return stock_info, None, None

        # Trading sinyalleri
        signals = analyzer.generate_trading_signals(df)

        # Son barın teknik verileri
        current_data = df.iloc[-1]
        technical_data = {
            'rsi': current_data.get('rsi', 0),
            'macd': current_data.get('macd', 0),
            'macd_signal': current_data.get('macd_signal', 0),
            'macd_histogram': current_data.get('macd_histogram', 0),
            'ma_20': current_data.get('ma_20', 0),
            'ma_50': current_data.get('ma_50', 0),
            'ma_100': current_data.get('ma_100', 0),
            'adx': current_data.get('adx', 0),
            'bb_middle': current_data.get('bb_middle', 0),
            'bb_upper': current_data.get('bb_upper', 0),
            'bb_lower': current_data.get('bb_lower', 0),
            'gap_pct': current_data.get('gap_pct', 0)
        }

        return stock_info, technical_data, signals
    except Exception as e:
        return None, None, None


def _prepare_news_data(stock_symbol: str):
    """
    BISTBot._prepare_news_data() - Telegram botu ile birebir aynı
    """
    # RSS haber özeti
    news_summary = news_helper.get_stock_news_summary(stock_symbol)

    # NewsAPI'den daha fazla (maksimum 100) haber çek
    newsapi_news = news_helper.fetch_newsapi_news(
        stock_symbol,
        config.NEWSAPI_KEY,
        language='tr',
        max_results=100
    )
    json_file = f"newsapi_{stock_symbol}.json"
    news_helper.save_news_to_json(newsapi_news, json_file)

    # Sadece alakalı NewsAPI haberlerini filtrele
    keywords = []
    if hasattr(config, 'STOCK_KEYWORDS') and stock_symbol in getattr(config, 'STOCK_KEYWORDS', {}):
        keywords.extend(config.STOCK_KEYWORDS[stock_symbol])
    keywords.append(stock_symbol)
    if hasattr(config, 'STOCK_NAMES') and stock_symbol in getattr(config, 'STOCK_NAMES', {}):
        company_name = config.STOCK_NAMES[stock_symbol]
        if company_name:
            keywords.append(company_name)
    keywords = [k.lower().strip() for k in keywords if k]

    filtered_newsapi_news = []
    for n in newsapi_news:
        title = (n.get('title') or '').lower()
        desc = (n.get('description') or '').lower()
        content = (n.get('content') or '').lower()
        if any(kw in title or kw in desc or kw in content for kw in keywords):
            filtered_newsapi_news.append(n)

    # Kullanıcıya gösterilecek NewsAPI haberlerini kısalt (en fazla 5 tane)
    MAX_NEWSAPI_ITEMS = 5
    if filtered_newsapi_news:
        newsapi_text = '\n'.join([
            f"{i+1}. {n['title']}\n   Kaynak: {n['source']}\n   Tarih: {n['published']}\n   Link: {n['link']}"
            for i, n in enumerate(filtered_newsapi_news[:MAX_NEWSAPI_ITEMS])
        ])
    else:
        newsapi_text = "NewsAPI'den ilgili haber bulunamadı."

    return news_summary, newsapi_text


def _build_analysis_message(
    stock_symbol: str,
    stock_info,
    technical_data,
    signals,
    news_summary,
    newsapi_text: str,
    ai_analysis: str,
) -> str:
    """
    BISTBot._build_analysis_message() - Telegram botu ile birebir aynı
    """
    # Fundamental / ek bilgiler için güvenli formatlama
    market_cap = stock_info.get('market_cap', 0) or 0
    pe_ratio = stock_info.get('pe_ratio', 0) or 0
    dividend_yield = stock_info.get('dividend_yield', 0) or 0

    market_cap_str = f"{market_cap:,.0f} TL" if market_cap > 0 else "Veri yok"
    pe_str = f"{pe_ratio:.2f}" if pe_ratio > 0 else "Veri yok"
    div_str = f"{dividend_yield:.2f}%" if dividend_yield > 0 else "Veri yok"

    news_summary_text = news_summary.get('summary', f"{stock_symbol} için haber özeti bulunamadı.")

    # RSS haberlerini (latest_news) kullanıcıya da göster
    latest_news = news_summary.get('latest_news', []) or []
    rss_news_lines = []
    if latest_news:
        MAX_RSS_ITEMS = 5
        for i, n in enumerate(latest_news[:MAX_RSS_ITEMS], 1):
            pub = n.get('published')
            try:
                if isinstance(pub, datetime):
                    date_str = pub.strftime('%d.%m.%Y %H:%M')
                else:
                    date_str = str(pub)
            except Exception:
                date_str = str(pub)

            rss_news_lines.append(
                f"{i}. {n.get('title','')}\n"
                f"   Kaynak: {n.get('source','')}\n"
                f"   Tarih: {date_str}\n"
                f"   Link: {n.get('link','')}"
            )
        rss_news_text = "\n".join(rss_news_lines)
    else:
        rss_news_text = "RSS kaynaklarından ilgili haber bulunamadı."

    result_message = f"""
� **{stock_info['name']} ({stock_symbol}) KAPSAMLI ANALİZ**

� **TEMEL BİLGİLER:**
• Güncel Fiyat: {stock_info['current_price']:.2f} TL
• 24 Saatlik Değişim: {stock_info['price_change_24h']:.2f}%
• Piyasa Değeri: {market_cap_str}
• Günlük Hacim: {stock_info['volume_24h']:,.0f}
• P/E Oranı: {pe_str}
• Temettü Getirisi: {div_str}

📈 **TEKNİK GÖSTERGELER:**
• RSI: {technical_data['rsi']:.2f} ({signals['rsi_signal']})
• MACD: {technical_data['macd']:.4f} ({signals['macd_signal']})
• MA20: {technical_data['ma_20']:.2f} TL
• MA50: {technical_data['ma_50']:.2f} TL
• MA100: {technical_data['ma_100']:.2f} TL
• ADX: {technical_data['adx']:.2f} ({signals.get('trend_regime','-')})
• BB Üst: {technical_data['bb_upper']:.2f} TL
• BB Orta: {technical_data['bb_middle']:.2f} TL
• BB Alt: {technical_data['bb_lower']:.2f} TL
• Gap Oranı: {technical_data['gap_pct']:.2f}%

🎯 **TRADING SİNYALLERİ:**
• Genel Sinyal: {signals['overall_signal']}
• Güven Skoru: {signals['confidence']:.1f}%
• Sinyal Gücü: {signals['signal_strength']}
• Risk Seviyesi: {signals['risk_level']}
• Rejim: {signals.get('trend_regime','-')} / Yön: {signals.get('trend_direction','-')}

📰 **HABER ANALİZİ (RSS):**
{news_summary_text}

🔍 **SON RSS HABERLERİ:**
{rss_news_text}

📰 **HABERLER (NewsAPI - sadece alakalı):**
{newsapi_text}

🤖 **AI ANALİZİ:**
{ai_analysis}

{config.RISK_WARNING}

⏰ **Analiz Tarihi:** {datetime.now().strftime('%d.%m.%Y %H:%M')}
"""
    return result_message


if __name__ == "__main__":
    import uvicorn
    uvicorn.run(app, host="0.0.0.0", port=8000)
