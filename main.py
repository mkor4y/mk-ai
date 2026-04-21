import logging
from telegram import (
    Update,
    InlineKeyboardButton,
    InlineKeyboardMarkup,
    ReplyKeyboardMarkup,
    KeyboardButton,
)
from telegram.ext import (
    Application,
    CommandHandler,
    CallbackQueryHandler,
    ContextTypes,
    MessageHandler,
    filters,
)
from datetime import datetime
import traceback

from config import Config
from bist_analyzer import BISTAnalyzer
from news_helper import NewsHelper
from chatgpt_helper import ChatGPTHelper

class BISTBot:
    """
    BIST Analiz Telegram Botu.

    Ana bot sınıfı; şu modülleri bir araya getirir:
    - `BISTAnalyzer`: Fiyat verisi ve teknik analiz
    - `NewsHelper`: RSS + NewsAPI haberleri ve duyarlılık
    - `ChatGPTHelper`: AI tabanlı hisse ve eğitim analizleri

    Telegram tarafında komutları ve buton etkileşimlerini yönetir.
    """
    
    def __init__(self):
        """Bot başlatma - config ve modül ayarları"""
        self.config = Config()
        self.setup_logging()
        
        # Modülleri başlat
        self.analyzer = BISTAnalyzer()
        self.news_helper = NewsHelper()
        self.ai_helper = ChatGPTHelper()
        
        # Bot uygulamasını başlat
        self.application = Application.builder().token(self.config.TELEGRAM_TOKEN).build()
        self.setup_handlers()
        
        self.logger.info("BIST Bot başlatıldı")
    
    def setup_logging(self):
        """Loglama ayarlarını yapılandır."""
        logging.basicConfig(
            format='%(asctime)s - %(name)s - %(levelname)s - %(message)s',
            level=getattr(logging, self.config.LOG_LEVEL),
            handlers=[
                logging.FileHandler(self.config.LOG_FILE),
                logging.StreamHandler()
            ]
        )
        self.logger = logging.getLogger(__name__)
    
    def setup_handlers(self):
        """Bot komut işleyicilerini ve callback handler'larını kaydeder."""
        # Ana komutlar
        self.application.add_handler(CommandHandler("start", self.start_command))
        self.application.add_handler(CommandHandler("help", self.help_command))
        self.application.add_handler(CommandHandler("menu", self.menu_command))
        
        # Hisse analizi komutları
        self.application.add_handler(CommandHandler("analyze", self.analyze_stock_command))
        self.application.add_handler(CommandHandler("price", self.price_query_command))
        
        # Eğitim komutları
        self.application.add_handler(CommandHandler("education", self.education_command))
        
        # Callback query handler (inline buton tıklamaları)
        self.application.add_handler(CallbackQueryHandler(self.button_callback))

        # Metin tabanlı hızlı menü (reply keyboard) için handler
        self.application.add_handler(
            MessageHandler(
                filters.TEXT & ~filters.COMMAND,
                self.text_menu_handler,
            )
        )
        
        # Hata işleyici
        self.application.add_error_handler(self.error_handler)
    
    def _split_message(self, text: str, limit: int = None):
        """
        Mesajı Telegram limitini aşmayacak parçalara böler.

        - Telegram limitine (4096) yaklaşmadan, güvenli bir tamponla (≈3500)
          parçalama yapar.
        - Parçalamada önce paragraf, sonra satır, en son kelime sınırını dener.
        """
        if limit is None:
            # Güvenli tampon: emoji/UTF-8 byte farkları için 3500 kullan
            limit = min(self.config.MAX_MESSAGE_LENGTH, 3500)
        if not text:
            return [""]
        if len(text) <= limit:
            return [text]
        chunks = []
        remaining = text
        while len(remaining) > limit:
            # Önce iki yeni satıra göre bölmeyi dene
            cut = remaining.rfind("\n\n", 0, limit)
            if cut == -1:
                # Tek newline'a göre dene
                cut = remaining.rfind("\n", 0, limit)
            if cut == -1:
                # Kelime sınırına göre dene
                cut = remaining.rfind(" ", 0, limit)
            if cut == -1:
                # Hiçbiri olmazsa sert kes
                cut = limit
            chunks.append(remaining[:cut].strip())
            remaining = remaining[cut:].lstrip()
        if remaining:
            chunks.append(remaining)
        return chunks

    def _get_persistent_keyboard(self) -> ReplyKeyboardMarkup:
        """
        Alt kısımda sabit duran (reply) ana menü klavyesini oluşturur.

        Kullanıcı bu klavye sayesinde komut yazmak zorunda kalmadan
        ana özelliklere tek dokunuşla erişebilir.
        """
        keyboard = [
            [KeyboardButton("📊 Hisse Analizi"), KeyboardButton("💰 Fiyat Sorgula")],
            [KeyboardButton("📚 Eğitim"), KeyboardButton("❓ Yardım")],
            [KeyboardButton("🏠 Ana Menü")],
        ]
        return ReplyKeyboardMarkup(keyboard, resize_keyboard=True)

    async def _send_long_message(self, update: Update, context: ContextTypes.DEFAULT_TYPE, text: str):
        """
        Uzun mesajları güvenle gönderir.

        `reply_text` yerine doğrudan `send_message` kullanarak, çok parçalı
        analiz metinlerinin sorunsuz iletilmesini sağlar.
        """
        chat_id = update.effective_chat.id
        for part in self._split_message(text):
            await context.bot.send_message(chat_id=chat_id, text=part)

    async def _edit_or_send_long(self, query, context: ContextTypes.DEFAULT_TYPE, text: str):
        """
        Callback için: kısa bir durum mesajı ile mevcut mesajı günceller,
        ardından içeriği parça parça yeni mesajlar olarak gönderir.
        """
        parts = self._split_message(text)
        if not parts:
            return
        status_text = "📩 Uzun içerik, parçalara bölünüp gönderiliyor..."
        try:
            await query.edit_message_text(status_text)
        except Exception:
            await context.bot.send_message(chat_id=query.message.chat_id, text=status_text)
        for p in parts:
            await context.bot.send_message(chat_id=query.message.chat_id, text=p)
    
    async def start_command(self, update: Update, context: ContextTypes.DEFAULT_TYPE):
        """`/start` komutu: karşılama ve hızlı erişim menü butonlarını gösterir."""
        try:
            user = update.effective_user
            welcome_message = f"""
🤖 Hoş geldin {user.first_name}! 

Ben BIST Analiz Botu - Borsa İstanbul hisse senetleri için kapsamlı analiz yapan akıllı asistanım.

📊 Özelliklerim:
• Hisse Analizi (Teknik + Temel)
• Fiyat Sorgulama
• Haber Analizi
• AI Destekli Yorumlar
• Eğitim İçerikleri

Başlamak için alttaki menü tuşlarını veya aşağıdaki butonlardan birini kullan:
"""
            
            keyboard = [
                [InlineKeyboardButton("📊 Hisse Analizi", callback_data="analyze")],
                [InlineKeyboardButton("💰 Fiyat Sorgula", callback_data="price")],
                [InlineKeyboardButton("📚 Eğitim", callback_data="education")],
                [InlineKeyboardButton("❓ Yardım", callback_data="help")]
            ]
            reply_markup = InlineKeyboardMarkup(keyboard)
            
            # Karşılama + inline menü
            await update.message.reply_text(welcome_message, reply_markup=reply_markup)

            # Alt kısımda kalıcı reply klavye
            await update.message.reply_text(
                "⬇️ Aşağıdaki menü tuşlarını kullanarak hızlıca işlem seçebilirsin.",
                reply_markup=self._get_persistent_keyboard(),
            )
            
        except Exception as e:
            self.logger.error(f"Start komutu hatası: {e}")
            await update.message.reply_text("❌ Bir hata oluştu. Lütfen daha sonra tekrar deneyin.")
    
    async def menu_command(self, update: Update, context: ContextTypes.DEFAULT_TYPE):
        """`/menu` komutu: botun ana menü seçeneklerini gösterir."""
        try:
            chat = update.effective_chat
            if not chat:
                return

            menu_message = """
🎯 BIST ANALİZ BOTU - ANA MENÜ

Aşağıdaki seçeneklerden birini seçin:

📊 **Hisse Analizi**: Kapsamlı teknik ve temel analiz
💰 **Fiyat Sorgula**: Anlık fiyat ve değişim bilgileri
📚 **Eğitim**: Yatırım eğitimi ve ipuçları
❓ **Yardım**: Bot kullanımı ve özellikler
"""
            
            keyboard = [
                [InlineKeyboardButton("📊 Hisse Analizi", callback_data="analyze")],
                [InlineKeyboardButton("💰 Fiyat Sorgula", callback_data="price")],
                [InlineKeyboardButton("📚 Eğitim", callback_data="education")],
                [InlineKeyboardButton("❓ Yardım", callback_data="help")]
            ]
            reply_markup = InlineKeyboardMarkup(keyboard)
            
            await context.bot.send_message(
                chat_id=chat.id,
                text=menu_message,
                reply_markup=reply_markup,
            )

            # Kullanıcıya alt menü klavyesini de yeniden hatırlat
            await context.bot.send_message(
                chat_id=chat.id,
                text="⬇️ Aşağıdaki menü tuşlarını kullanarak hızlıca işlem seçebilirsin.",
                reply_markup=self._get_persistent_keyboard(),
            )
            
        except Exception as e:
            self.logger.error(f"Menu komutu hatası: {e}")
            chat = update.effective_chat
            if chat:
                await context.bot.send_message(
                    chat_id=chat.id,
                    text="❌ Bir hata oluştu. Lütfen daha sonra tekrar deneyin.",
                )
    
    async def analyze_stock_command(self, update: Update, context: ContextTypes.DEFAULT_TYPE):
        """`/analyze` komutu: verilen hisse kodu için kapsamlı analiz başlatır."""
        try:
            # Kullanıcıdan hisse kodu al
            if not context.args:
                await update.message.reply_text(
                    "📊 Hisse analizi için hisse kodunu girin:\n"
                    "Örnek: /analyze THYAO\n\n"
                    "Desteklenen hisseler:\n" + 
                    "\n".join([f"• {stock}" for stock in self.config.SUPPORTED_BIST_STOCKS])
                )
                return
            
            stock_symbol = context.args[0].upper()
            
            if stock_symbol not in self.config.SUPPORTED_BIST_STOCKS:
                await update.message.reply_text(
                    f"❌ {stock_symbol} desteklenmiyor.\n\n"
                    "Desteklenen hisseler:\n" + 
                    "\n".join([f"• {stock}" for stock in self.config.SUPPORTED_BIST_STOCKS])
                )
                return
            
            # Analiz mesajı gönder
            await update.message.reply_text(f"🔍 {stock_symbol} analizi yapılıyor... Lütfen bekleyin.")
            
            # Kapsamlı analiz yap
            analysis_result = await self.perform_stock_analysis(stock_symbol)
            
            # Sonucu gönder (uzun olabilir)
            await self._send_long_message(update, context, analysis_result)
            
        except Exception as e:
            self.logger.error(f"Analiz komutu hatası: {e}")
            await update.message.reply_text("❌ Analiz sırasında hata oluştu. Lütfen daha sonra tekrar deneyin.")
    
    async def price_query_command(self, update: Update, context: ContextTypes.DEFAULT_TYPE):
        """`/price` komutu: verilen hisse için özet fiyat/fundamental bilgilerini gösterir."""
        try:
            # Kullanıcıdan hisse kodu al
            if not context.args:
                await update.message.reply_text(
                    "💰 Fiyat sorgulama için hisse kodunu girin:\n"
                    "Örnek: /price THYAO\n\n"
                    "Desteklenen hisseler:\n" + 
                    "\n".join([f"• {stock}" for stock in self.config.SUPPORTED_BIST_STOCKS])
                )
                return
            
            stock_symbol = context.args[0].upper()
            
            if stock_symbol not in self.config.SUPPORTED_BIST_STOCKS:
                await update.message.reply_text(
                    f"❌ {stock_symbol} desteklenmiyor.\n\n"
                    "Desteklenen hisseler:\n" + 
                    "\n".join([f"• {stock}" for stock in self.config.SUPPORTED_BIST_STOCKS])
                )
                return
            
            # Fiyat bilgilerini al
            stock_info = self.analyzer.get_stock_info(stock_symbol)
            
            if not stock_info:
                await update.message.reply_text(f"❌ {stock_symbol} için fiyat bilgisi alınamadı.")
                return
            
            # Fundamental alanları güvenli formatla
            market_cap = stock_info.get('market_cap', 0) or 0
            pe_ratio = stock_info.get('pe_ratio', 0) or 0
            dividend_yield = stock_info.get('dividend_yield', 0) or 0

            market_cap_str = f"{market_cap:,.0f} TL" if market_cap > 0 else "Veri yok"
            pe_str = f"{pe_ratio:.2f}" if pe_ratio > 0 else "Veri yok"
            div_str = f"{dividend_yield:.2f}%" if dividend_yield > 0 else "Veri yok"

            # Fiyat mesajını oluştur
            price_message = f"""
💰 **{stock_info['name']} ({stock_symbol}) FİYAT BİLGİLERİ**

📊 **Güncel Fiyat:** {stock_info['current_price']:.2f} TL
📈 **24 Saatlik Değişim:** {stock_info['price_change_24h']:.2f}%
📊 **Piyasa Değeri:** {market_cap_str}
📈 **Günlük Hacim:** {stock_info['volume_24h']:,.0f}

📊 **Teknik Bilgiler:**
• P/E Oranı: {pe_str}
• Temettü Getirisi: {div_str}
• 52 Hafta En Yüksek: {stock_info['high_52w']:.2f} TL
• 52 Hafta En Düşük: {stock_info['low_52w']:.2f} TL

⏰ **Güncelleme:** {datetime.now().strftime('%d.%m.%Y %H:%M')}
"""
            
            await update.message.reply_text(price_message)
            
        except Exception as e:
            self.logger.error(f"Fiyat sorgulama hatası: {e}")
            await update.message.reply_text("❌ Fiyat sorgulama sırasında hata oluştu.")
    
    async def education_command(self, update: Update, context: ContextTypes.DEFAULT_TYPE):
        """`/education` komutu: yatırım eğitimi konuları menüsünü açar."""
        try:
            chat = update.effective_chat
            if not chat:
                return

            education_topics = [
                "Teknik Analiz Temelleri",
                "RSI Göstergesi",
                "MACD Göstergesi", 
                "Bollinger Bands",
                "Moving Average",
                "Risk Yönetimi",
                "Temel Analiz",
                "BIST'te Yatırım"
            ]
            
            keyboard = []
            for topic in education_topics:
                keyboard.append([InlineKeyboardButton(topic, callback_data=f"edu_{topic}")])
            
            keyboard.append([InlineKeyboardButton("🔙 Ana Menü", callback_data="menu")])
            reply_markup = InlineKeyboardMarkup(keyboard)
            
            await context.bot.send_message(
                chat_id=chat.id,
                text="📚 **BIST YATIRIM EĞİTİMİ**\n\n"
                     "Aşağıdaki konulardan birini seçin:",
                reply_markup=reply_markup,
            )
            
        except Exception as e:
            self.logger.error(f"Eğitim komutu hatası: {e}")
            chat = update.effective_chat
            if chat:
                await context.bot.send_message(
                    chat_id=chat.id,
                    text="❌ Eğitim menüsü yüklenirken hata oluştu.",
                )
    
    async def help_command(self, update: Update, context: ContextTypes.DEFAULT_TYPE):
        """`/help` komutu: AI destekli veya fallback yardım içeriğini gösterir."""
        try:
            # ChatGPTHelper senkron çalışıyor; await kullanma
            help_content = self.ai_helper.get_help_content()
            await self._send_long_message(update, context, help_content)
            
        except Exception as e:
            self.logger.error(f"Yardım komutu hatası: {e}")
            # Varsayılan yardım mesajı
            default_help = """
🤖 **BIST ANALİZ BOTU YARDIM**

📋 **Komutlar:**
• /start - Bot'u başlat
• /menu - Ana menü
• /analyze [HİSSE] - Hisse analizi (örn: /analyze THYAO)
• /price [HİSSE] - Fiyat sorgulama (örn: /price GARAN)
• /education - Eğitim içerikleri
• /help - Bu yardım mesajı

📊 **Desteklenen Hisse Kodları:**
• THYAO, GARAN, AKBNK, ASELS, KRDMD, TUPRS

⚠️ **Önemli Notlar:**
• Bu bot sadece bilgilendirme amaçlıdır
• Yatırım tavsiyesi değildir
• Kendi araştırmanızı yapın
• Risk yönetimi uygulayın
"""
            chat = update.effective_chat
            if chat:
                await context.bot.send_message(chat_id=chat.id, text=default_help)
    
    async def button_callback(self, update: Update, context: ContextTypes.DEFAULT_TYPE):
        """Inline buton tıklamalarını yöneten callback handler."""
        try:
            query = update.callback_query
            await query.answer()
            
            data = query.data
            
            if data == "menu":
                await self.menu_command(update, context)
                
            elif data == "analyze":
                # Hisse seçim menüsü (inline)
                keyboard = []
                for stock in self.config.SUPPORTED_BIST_STOCKS:
                    keyboard.append([InlineKeyboardButton(stock, callback_data=f"analyze_{stock}")])
                keyboard.append([InlineKeyboardButton("🔙 Ana Menü", callback_data="menu")])
                reply_markup = InlineKeyboardMarkup(keyboard)
                
                await query.edit_message_text(
                    "📊 **HİSSE ANALİZİ**\n\n"
                    "Analiz etmek istediğiniz hisseyi seçin:",
                    reply_markup=reply_markup
                )
                
            elif data.startswith("analyze_"):
                stock_symbol = data.split("_")[1]
                await query.edit_message_text(f"🔍 {stock_symbol} analizi yapılıyor... Lütfen bekleyin.")
                
                analysis_result = await self.perform_stock_analysis(stock_symbol)
                await self._edit_or_send_long(query, context, analysis_result)
                
            elif data == "price":
                # Fiyat sorgulama menüsü (inline)
                keyboard = []
                for stock in self.config.SUPPORTED_BIST_STOCKS:
                    keyboard.append([InlineKeyboardButton(stock, callback_data=f"price_{stock}")])
                keyboard.append([InlineKeyboardButton("🔙 Ana Menü", callback_data="menu")])
                reply_markup = InlineKeyboardMarkup(keyboard)
                
                await query.edit_message_text(
                    "💰 **FİYAT SORGULAMA**\n\n"
                    "Fiyat bilgisi almak istediğiniz hisseyi seçin:",
                    reply_markup=reply_markup
                )
                
            elif data.startswith("price_"):
                stock_symbol = data.split("_")[1]
                stock_info = self.analyzer.get_stock_info(stock_symbol)
                
                if stock_info:
                    # Fundamental alanları güvenli formatla (inline fiyat sorgu için de aynı mantık)
                    market_cap = stock_info.get('market_cap', 0) or 0
                    pe_ratio = stock_info.get('pe_ratio', 0) or 0
                    dividend_yield = stock_info.get('dividend_yield', 0) or 0

                    market_cap_str = f"{market_cap:,.0f} TL" if market_cap > 0 else "Veri yok"
                    pe_str = f"{pe_ratio:.2f}" if pe_ratio > 0 else "Veri yok"
                    div_str = f"{dividend_yield:.2f}%" if dividend_yield > 0 else "Veri yok"

                    price_message = f"""
💰 **{stock_info['name']} ({stock_symbol}) FİYAT BİLGİLERİ**

📊 **Güncel Fiyat:** {stock_info['current_price']:.2f} TL
📈 **24 Saatlik Değişim:** {stock_info['price_change_24h']:.2f}%
📊 **Piyasa Değeri:** {market_cap_str}
📈 **Günlük Hacim:** {stock_info['volume_24h']:,.0f}

📊 **Teknik Bilgiler:**
• P/E Oranı: {pe_str}
• Temettü Getirisi: {div_str}

⏰ **Güncelleme:** {datetime.now().strftime('%d.%m.%Y %H:%M')}
"""
                    await query.edit_message_text(price_message)
                else:
                    await query.edit_message_text(f"❌ {stock_symbol} için fiyat bilgisi alınamadı.")
                    
            elif data == "education":
                await self.education_command(update, context)
                
            elif data.startswith("edu_"):
                topic = data.split("edu_")[1]
                await query.edit_message_text(f"📚 {topic} eğitimi hazırlanıyor... Lütfen bekleyin.")
                
                # ChatGPTHelper senkron; burada await kullanma
                education_content = self.ai_helper.get_educational_content(topic)
                await self._edit_or_send_long(query, context, education_content)
                
            elif data == "help":
                await self.help_command(update, context)
                
        except Exception as e:
            self.logger.error(f"Button callback hatası: {e}")
            await query.edit_message_text("❌ Bir hata oluştu. Lütfen daha sonra tekrar deneyin.")

    async def text_menu_handler(self, update: Update, context: ContextTypes.DEFAULT_TYPE):
        """
        Reply klavye veya serbest metin ile gelen basit menü isteklerini yönetir.

        Örnek:
        - "📊 Hisse Analizi" -> hisse seçim menüsü
        - "💰 Fiyat Sorgula" -> fiyat menüsü
        - "📚 Eğitim"        -> eğitim menüsü
        - "❓ Yardım"        -> yardım içeriği
        """
        if not update.message:
            return

        text = (update.message.text or "").strip().lower()

        # Kullanıcı butonlardaki emojili metni veya sade Türkçe yazabilir
        if text in ("📊 hisse analizi", "hisse analizi", "analiz", "hisse"):
            # Inline hisse seçim menüsü (button_callback içindeki "analyze" ile aynı mantık)
            keyboard = []
            for stock in self.config.SUPPORTED_BIST_STOCKS:
                keyboard.append([InlineKeyboardButton(stock, callback_data=f"analyze_{stock}")])
            keyboard.append([InlineKeyboardButton("🔙 Ana Menü", callback_data="menu")])
            reply_markup = InlineKeyboardMarkup(keyboard)

            await update.message.reply_text(
                "📊 **HİSSE ANALİZİ**\n\n"
                "Analiz etmek istediğiniz hisseyi seçin:",
                reply_markup=reply_markup,
            )
            return

        if text in ("💰 fiyat sorgula", "fiyat sorgula", "fiyat", "price"):
            # Inline fiyat sorgulama menüsü (button_callback içindeki "price" ile aynı mantık)
            keyboard = []
            for stock in self.config.SUPPORTED_BIST_STOCKS:
                keyboard.append([InlineKeyboardButton(stock, callback_data=f"price_{stock}")])
            keyboard.append([InlineKeyboardButton("🔙 Ana Menü", callback_data="menu")])
            reply_markup = InlineKeyboardMarkup(keyboard)

            await update.message.reply_text(
                "💰 **FİYAT SORGULAMA**\n\n"
                "Fiyat bilgisi almak istediğiniz hisseyi seçin:",
                reply_markup=reply_markup,
            )
            return

        if text in ("📚 eğitim", "eğitim", "egitim"):
            await self.education_command(update, context)
            return

        if text in ("❓ yardım", "yardım", "yardim", "help"):
            await self.help_command(update, context)
            return

        if text in ("🏠 ana menü", "ana menü", "ana menu", "menu"):
            await self.menu_command(update, context)
            return

        # Tanınmayan metinler için kısa yönlendirme
        await update.message.reply_text(
            "Ne yapmak istediğini anlayamadım.\n\n"
            "Alttaki menü tuşlarını kullanabilir veya /menu komutunu yazabilirsin."
        )
    
    async def perform_stock_analysis(self, stock_symbol: str) -> str:
        """
        Kapsamlı hisse analizi yap.

        Args:
            stock_symbol (str): Hisse kodu
        Returns:
            str: Analiz sonucu
        """
        try:
            # 1) Fiyat + teknik veri + sinyaller
            stock_info, technical_data, signals = self._prepare_price_and_technical(stock_symbol)
            if stock_info is None:
                return f"❌ {stock_symbol} için hisse bilgisi alınamadı."
            if technical_data is None or signals is None:
                return f"❌ {stock_symbol} için teknik analiz yapılamadı."

            # 2) Haber verisi (RSS + NewsAPI, filtrelenmiş ve kısaltılmış)
            news_summary, newsapi_text = self._prepare_news_data(stock_symbol)

            # 3) AI analizi (yapay zeka yorumları)
            ai_analysis = self.ai_helper.get_stock_analysis(stock_info, technical_data, signals, news_summary)

            # 4) Sonuç mesajını oluştur
            result_message = self._build_analysis_message(
                stock_symbol=stock_symbol,
                stock_info=stock_info,
                technical_data=technical_data,
                signals=signals,
                news_summary=news_summary,
                newsapi_text=newsapi_text,
                ai_analysis=ai_analysis,
            )
            return result_message
        except Exception as e:
            self.logger.error(f"Hisse analizi hatası {stock_symbol}: {e}")
            return f"❌ {stock_symbol} analizi sırasında hata oluştu: {e}"

    def _prepare_price_and_technical(self, stock_symbol: str):
        """
        Fiyat, teknik göstergeler ve sinyallerin tek yerde hazırlanması.

        - `BISTAnalyzer` üzerinden:
          * `get_stock_info`  -> özet fiyat bilgileri
          * `get_stock_data`  -> OHLCV zaman serisi
          * `calculate_technical_indicators` -> indikatörler
          * `generate_trading_signals`       -> sinyal sözlüğü
        """
        try:
            # Fiyat ve temel bilgiler
            stock_info = self.analyzer.get_stock_info(stock_symbol)
            if not stock_info:
                return None, None, None

            # Grafik / OHLCV verisi
            df = self.analyzer.get_stock_data(stock_symbol, days=220)
            if df is None or df.empty:
                self.logger.error(f"{stock_symbol} için teknik veri alınamadı.")
                return stock_info, None, None

            # Teknik göstergeler
            df = self.analyzer.calculate_technical_indicators(df)
            if df is None or df.empty:
                self.logger.error(f"{stock_symbol} için teknik göstergeler hesaplanamadı.")
                return stock_info, None, None

            # Trading sinyalleri
            signals = self.analyzer.generate_trading_signals(df)

            # Son barın teknik verileri
            current_data = df.iloc[-1]
            technical_data = {
                'rsi': current_data.get('rsi', 0),
                'macd': current_data.get('macd', 0),
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
            self.logger.error(f"{stock_symbol} için fiyat/teknik hazırlama hatası: {e}")
            return None, None, None

    def _prepare_news_data(self, stock_symbol: str):
        """
        RSS ve NewsAPI haberlerini çek, filtrele ve kısa metin haline getir.

        Dönenler:
        - `news_summary`: RSS tabanlı özet + duyarlılık bilgileri
        - `newsapi_text`: NewsAPI'den gelen, filtrelenmiş ve kısaltılmış haber listesi
        """
        # RSS haber özeti
        news_summary = self.news_helper.get_stock_news_summary(stock_symbol)

        # NewsAPI'den daha fazla (maksimum 100) haber çek
        newsapi_news = self.news_helper.fetch_newsapi_news(
            stock_symbol,
            self.config.NEWSAPI_KEY,
            language='tr',
            max_results=100
        )
        json_file = f"newsapi_{stock_symbol}.json"
        self.news_helper.save_news_to_json(newsapi_news, json_file)

        # Sadece alakalı NewsAPI haberlerini filtrele
        keywords = []
        if hasattr(self.config, 'STOCK_KEYWORDS') and stock_symbol in getattr(self.config, 'STOCK_KEYWORDS', {}):
            keywords.extend(self.config.STOCK_KEYWORDS[stock_symbol])
        keywords.append(stock_symbol)
        if hasattr(self.config, 'STOCK_NAMES') and stock_symbol in getattr(self.config, 'STOCK_NAMES', {}):
            company_name = self.config.STOCK_NAMES[stock_symbol]
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

        # Kullanıcıya gösterilecek NewsAPI haberlerini kısalt (örneğin en fazla 5 tane)
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
        self,
        stock_symbol: str,
        stock_info,
        technical_data,
        signals,
        news_summary,
        newsapi_text: str,
        ai_analysis: str,
    ) -> str:
        """
        Tüm parçaları (fiyat, teknik, haber, AI) tek bir analiz metninde birleştirir.

        - Eksik fundamental verileri 'Veri yok' şeklinde gösterir.
        - RSS ve NewsAPI haberleri ile AI analizini, risk uyarısı ile birlikte sunar.
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
                # RSS tarafı datetime olarak geliyor, ama korunmak için string fallback
                try:
                    from datetime import datetime as _dt_type  # local alias
                    if isinstance(pub, _dt_type):
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
📊 **{stock_info['name']} ({stock_symbol}) KAPSAMLI ANALİZ**

💰 **TEMEL BİLGİLER:**
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

{self.config.RISK_WARNING}

⏰ **Analiz Tarihi:** {datetime.now().strftime('%d.%m.%Y %H:%M')}
"""
        return result_message
    
    async def error_handler(self, update: Update, context: ContextTypes.DEFAULT_TYPE):
        """Global hata işleyicisi: hatayı loglar ve kullanıcıya genel bir mesaj gösterir."""
        self.logger.error(f"Bot hatası: {context.error}")
        self.logger.error(traceback.format_exc())
        
        if update and update.effective_message:
            await update.effective_message.reply_text(
                "❌ Bir hata oluştu. Lütfen daha sonra tekrar deneyin."
            )
    
    def run(self):
        """Bot'u polling ile çalıştır."""
        try:
            self.logger.info("Bot başlatılıyor...")
            self.application.run_polling()
        except Exception as e:
            self.logger.error(f"Bot çalıştırma hatası: {e}")

if __name__ == "__main__":
    bot = BISTBot()
    bot.run()
