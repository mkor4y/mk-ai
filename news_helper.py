import feedparser
import requests
from datetime import datetime, timedelta, timezone
import logging
from typing import List, Dict, Optional
from config import Config
import json
import os

class NewsHelper:
    """
    Haber Analizi Yardımcı Sınıfı.

    Görevleri:
    - RSS feed'lerden haberleri çekmek
    - Haberleri hisse sembolleriyle (THYAO, AKBNK vb.) eşleştirmek
    - Basit bir kelime listesi ile haber duyarlılığını (pozitif/negatif/nötr) hesaplamak
    - NewsAPI üzerinden hisse/şirket bazlı haberleri almak ve JSON'a kaydetmek
    """
    
    def __init__(self):
        """Sınıf başlatma - config ve logger ayarları"""
        self.config = Config()
        self.logger = logging.getLogger(__name__)
        self.session = requests.Session()
        # User-Agent ekle (bazı RSS feed'ler bot'ları engelleyebilir)
        self.session.headers.update({
            'User-Agent': 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36'
        })
    
    def fetch_all_news(self) -> List[Dict]:
        """
        Tüm RSS feed'lerden haberleri al.

        RSS_FEED_URLS içindeki tüm kaynakları dolaşır, her biri için
        `_fetch_news_from_source` çağırır ve sonuçları tek listede toplar.
        Returns:
            List[Dict]: Tüm haberlerin listesi
        """
        all_news = []
        
        for source_name, feed_url in self.config.RSS_FEED_URLS.items():
            try:
                self.logger.info(f"Haber alınıyor: {source_name}")
                news_from_source = self._fetch_news_from_source(source_name, feed_url)
                all_news.extend(news_from_source)
                
            except Exception as e:
                self.logger.error(f"Haber alma hatası {source_name}: {e}")
                continue
        
        # Haberleri tarihe göre sırala (en yeni önce)
        all_news.sort(key=lambda x: x.get('published', datetime.min), reverse=True)
        
        self.logger.info(f"Toplam {len(all_news)} haber alındı")
        return all_news
    
    def _fetch_news_from_source(self, source_name: str, feed_url: str) -> List[Dict]:
        """
        Tek bir RSS feed'den haberleri al.

        Args:
            source_name (str): Haber kaynağı adı
            feed_url (str): RSS feed URL'i
        Returns:
            List[Dict]: Haber listesi
        """
        try:
            # RSS feed'i HTTP isteği ile çek ve parse et
            response = self.session.get(feed_url, timeout=10)
            response.raise_for_status()
            
            feed = feedparser.parse(response.content)
            
            news_list = []
            # Karşılaştırmalar için UTC (aware) datetime kullan
            cutoff_time = datetime.now(timezone.utc) - timedelta(hours=self.config.NEWS_HOURS_BACK)
            
            for entry in feed.entries[:self.config.MAX_NEWS_COUNT]:
                try:
                    # Haber tarihini güvenli şekilde al (UTC aware)
                    published = self._get_published_datetime(entry)
                    
                    # Sadece son X saatlik haberleri al
                    if published and published >= cutoff_time:
                        news_item = {
                            'title': entry.get('title', ''),
                            'description': entry.get('summary', ''),
                            'link': entry.get('link', ''),
                            'published': published,
                            'source': source_name,
                            'content': self._extract_content(entry)
                        }
                        news_list.append(news_item)
                        
                except Exception as e:
                    self.logger.warning(f"Haber parse hatası: {e}")
                    continue
            
            self.logger.info(f"{source_name}: {len(news_list)} haber alındı")
            return news_list
            
        except Exception as e:
            self.logger.error(f"RSS feed hatası {source_name}: {e}")
            return []
    
    def _parse_news_date(self, date_str: str) -> Optional[datetime]:
        """
        Haber tarihini string formattan datetime objesine çevir.
        Args:
            date_str (str): Tarih string'i
        Returns:
            datetime: Parse edilmiş tarih veya None
        """
        if not date_str:
            return None
        
        # Farklı tarih formatlarını dene
        date_formats = [
            '%a, %d %b %Y %H:%M:%S %z',  # RFC 822
            '%Y-%m-%dT%H:%M:%S%z',       # ISO 8601
            '%Y-%m-%d %H:%M:%S',         # Basit format
            '%d.%m.%Y %H:%M',            # Türk formatı
            '%Y-%m-%d'                   # Sadece tarih
        ]
        
        for fmt in date_formats:
            try:
                dt = datetime.strptime(date_str, fmt)
                return self._ensure_aware(dt)
            except ValueError:
                continue
        
        # Eğer hiçbiri çalışmazsa, şu anki zamanı kullan
        self.logger.warning(f"Tarih parse edilemedi: {date_str}")
        return datetime.now(timezone.utc)

    def _get_published_datetime(self, entry) -> Optional[datetime]:
        """
        RSS entry içinden yayın tarihini güvenli şekilde (UTC aware) çıkar.
        """
        try:
            published_parsed = getattr(entry, 'published_parsed', None)
            if published_parsed:
                # struct_time -> datetime (UTC kabul edilir)
                dt = datetime(
                    published_parsed.tm_year,
                    published_parsed.tm_mon,
                    published_parsed.tm_mday,
                    published_parsed.tm_hour,
                    published_parsed.tm_min,
                    published_parsed.tm_sec,
                    tzinfo=timezone.utc,
                )
                return dt
            updated_parsed = getattr(entry, 'updated_parsed', None)
            if updated_parsed:
                dt = datetime(
                    updated_parsed.tm_year,
                    updated_parsed.tm_mon,
                    updated_parsed.tm_mday,
                    updated_parsed.tm_hour,
                    updated_parsed.tm_min,
                    updated_parsed.tm_sec,
                    tzinfo=timezone.utc,
                )
                return dt
        except Exception:
            pass

        # String alanlardan dene
        date_str = getattr(entry, 'published', '') or getattr(entry, 'updated', '') or ''
        if date_str:
            return self._parse_news_date(date_str)
        return None

    def _ensure_aware(self, dt: datetime) -> datetime:
        """Datetime'i UTC aware hale getir."""
        if dt.tzinfo is None or dt.tzinfo.utcoffset(dt) is None:
            return dt.replace(tzinfo=timezone.utc)
        return dt.astimezone(timezone.utc)
    
    def _extract_content(self, entry) -> str:
        """
        Haber içeriğini çıkar.

        Öncelik sırası: content > summary > description.
        Args:
            entry: RSS entry objesi
        Returns:
            str: Haber içeriği
        """
        # Önce content alanını dene
        if hasattr(entry, 'content') and entry.content:
            return entry.content[0].value
        
        # Sonra summary alanını dene
        if hasattr(entry, 'summary'):
            return entry.summary
        
        # Son olarak description alanını dene
        if hasattr(entry, 'description'):
            return entry.description
        
        return ""
    
    def filter_news_by_stock(self, news_list: List[Dict], stock_symbol: str) -> List[Dict]:
        """
        Belirli bir hisse ile ilgili haberleri filtrele.
        Args:
            news_list (List[Dict]): Tüm haberler
            stock_symbol (str): Hisse kodu (örn: THYAO)
        Returns:
            List[Dict]: Filtrelenmiş haberler
        """
        # Hisse anahtar kelimeleri
        keywords = []
        # Config'ten anahtar kelimeleri al
        if stock_symbol in self.config.STOCK_KEYWORDS:
            keywords.extend(self.config.STOCK_KEYWORDS[stock_symbol])
        # Şirket kodu ve (varsa) şirket adını da ekle
        keywords.append(stock_symbol)
        # Şirket adı varsa ekle
        company_name = None
        if hasattr(self.config, 'STOCK_NAMES') and stock_symbol in getattr(self.config, 'STOCK_NAMES', {}):
            company_name = self.config.STOCK_NAMES[stock_symbol]
            if company_name:
                keywords.append(company_name)
        # Büyük/küçük harf duyarsız, boşlukları normalize et
        keywords = [k.lower().strip() for k in keywords if k]
        filtered_news = []
        for news in news_list:
            title_lower = news['title'].lower()
            content_lower = news['content'].lower()
            for keyword in keywords:
                if keyword in title_lower or keyword in content_lower:
                    news['matched_keyword'] = keyword
                    news['sentiment_score'] = self._calculate_sentiment(news['title'] + " " + news['content'])
                    filtered_news.append(news)
                    break
        self.logger.info(f"{stock_symbol} için {len(filtered_news)} haber bulundu (esnek filtre)")
        return filtered_news
    
    def _calculate_sentiment(self, text: str) -> float:
        """
        Metin duyarlılık skorunu hesapla.

        Çok basit bir kelime sayma yaklaşımı kullanır:
        - POZİTİF kelimeler: +1
        - NEGATİF kelimeler: -1
        Sonuç: (-1 ile 1 arası normalize edilmiş skor)
        Args:
            text (str): Analiz edilecek metin
        Returns:
            float: Duyarlılık skoru (-1 ile 1 arası)
        """
        text_lower = text.lower()
        
        positive_count = 0
        negative_count = 0
        
        # Pozitif kelimeleri say
        for word in self.config.POSITIVE_WORDS:
            positive_count += text_lower.count(word.lower())
        
        # Negatif kelimeleri say
        for word in self.config.NEGATIVE_WORDS:
            negative_count += text_lower.count(word.lower())
        
        # Toplam kelime sayısı
        total_words = len(text.split())
        
        if total_words == 0:
            return 0.0
        
        # Duyarlılık skoru hesapla (-1 ile 1 arası)
        sentiment_score = (positive_count - negative_count) / total_words
        
        # Skoru sınırla
        sentiment_score = max(-1.0, min(1.0, sentiment_score))
        
        return round(sentiment_score, 3)
    
    def get_stock_news_summary(self, stock_symbol: str) -> Dict:
        """
        Bir hisse için haber özeti oluştur.

        Adımlar:
        1) Tüm RSS haberlerini topla
        2) İlgili hisseyle eşleşenleri filtrele
        3) Duyarlılık skorunu hesapla
        4) Son birkaç haberi ve genel özet bilgisini döndür
        Args:
            stock_symbol (str): Hisse kodu
        Returns:
            Dict: Haber özeti
        """
        try:
            # Tüm haberleri al
            all_news = self.fetch_all_news()
            
            # Hisse ile ilgili haberleri filtrele
            stock_news = self.filter_news_by_stock(all_news, stock_symbol)
            
            if not stock_news:
                return {
                    'stock_symbol': stock_symbol,
                    'news_count': 0,
                    'latest_news': [],
                    'overall_sentiment': 0.0,
                    'sentiment_label': 'NÖTR',
                    'summary': f"{stock_symbol} için son 3 günde haber bulunamadı."
                }
            
            # En son 5 haberi al
            latest_news = stock_news[:5]
            
            # Genel duyarlılık skorunu hesapla
            sentiment_scores = [news['sentiment_score'] for news in stock_news]
            overall_sentiment = sum(sentiment_scores) / len(sentiment_scores)
            
            # Duyarlılık etiketi belirle
            if overall_sentiment > 0.1:
                sentiment_label = 'POZİTİF'
            elif overall_sentiment < -0.1:
                sentiment_label = 'NEGATİF'
            else:
                sentiment_label = 'NÖTR'
            
            # Haber özeti metnini oluştur
            summary = f"{stock_symbol} için son 3 günde {len(stock_news)} haber bulundu. "
            summary += f"Genel duyarlılık: {sentiment_label} ({overall_sentiment:.3f})"
            
            return {
                'stock_symbol': stock_symbol,
                'news_count': len(stock_news),
                'latest_news': latest_news,
                'overall_sentiment': round(overall_sentiment, 3),
                'sentiment_label': sentiment_label,
                'summary': summary
            }
            
        except Exception as e:
            self.logger.error(f"Haber özeti oluşturma hatası {stock_symbol}: {e}")
            return {
                'stock_symbol': stock_symbol,
                'news_count': 0,
                'latest_news': [],
                'overall_sentiment': 0.0,
                'sentiment_label': 'NÖTR',
                'summary': f"Haber analizi sırasında hata oluştu: {e}"
            }
    
    def format_news_for_ai(self, news_summary: Dict) -> str:
        """
        AI analizi için haber verilerini formatla.
        Args:
            news_summary (Dict): Haber özeti
        Returns:
            str: AI için formatlanmış haber metni
        """
        if not news_summary['latest_news']:
            return "Haber bulunamadı."
        
        formatted_text = f"📰 {news_summary['stock_symbol']} HABER ANALİZİ\n\n"
        formatted_text += f"📊 Genel Duyarlılık: {news_summary['sentiment_label']} ({news_summary['overall_sentiment']})\n"
        formatted_text += f"📈 Toplam Haber: {news_summary['news_count']}\n\n"
        
        formatted_text += "🔍 SON HABERLER:\n"
        for i, news in enumerate(news_summary['latest_news'], 1):
            formatted_text += f"{i}. {news['title']}\n"
            formatted_text += f"   📅 {news['published'].strftime('%d.%m.%Y %H:%M')}\n"
            formatted_text += f"   📰 {news['source']}\n"
            formatted_text += f"   🎯 Duyarlılık: {news['sentiment_score']}\n\n"
        
        return formatted_text

    def fetch_newsapi_news(self, stock_symbol: str, api_key: str, language: str = 'tr', max_results: int = 10) -> List[Dict]:
        """
        NewsAPI.org üzerinden ilgili hisse/şirket hakkında mümkün olduğunca fazla haber çeker.

        Arama mantığı:
        - Hisse kodu (örn: THYAO)
        - Şirket adı (örn: "Türk Hava Yolları"), varsa
        Bu terimleri `q` parametresinde OR ile birleştirerek; başlık, açıklama ve içerik
        alanlarında arama yapar.
        """
        import requests

        # Sorguyu oluştur: sembol + şirket adı (varsa)
        query_parts = [stock_symbol]
        if hasattr(self.config, 'STOCK_NAMES') and stock_symbol in getattr(self.config, 'STOCK_NAMES', {}):
            company_name = self.config.STOCK_NAMES[stock_symbol]
            if company_name:
                query_parts.append(company_name)

        # Tek bir OR'lu query string oluştur
        # Örn: THYAO OR "Türk Hava Yolları"
        formatted_parts = []
        for q in query_parts:
            q = (q or "").strip()
            if not q:
                continue
            if " " in q:
                formatted_parts.append(f"\"{q}\"")
            else:
                formatted_parts.append(q)
        query = " OR ".join(formatted_parts) if formatted_parts else stock_symbol

        url = "https://newsapi.org/v2/everything"
        params = {
            "q": query,
            # Başlık + açıklama + içerik içinden ara (daha geniş sonuç)
            "searchIn": "title,description,content",
            "language": language,
            "sortBy": "publishedAt",
            "pageSize": max_results,
            "apiKey": api_key,
        }

        try:
            resp = requests.get(url, params=params, timeout=10)
            resp.raise_for_status()
            data = resp.json()
            news_list = []
            for article in data.get('articles', []):
                news_item = {
                    'title': article.get('title', ''),
                    'description': article.get('description', ''),
                    'link': article.get('url', ''),
                    'published': article.get('publishedAt', ''),
                    'source': article.get('source', {}).get('name', ''),
                    'content': article.get('content', '')
                }
                news_list.append(news_item)

            self.logger.info(f"NewsAPI {stock_symbol}: {len(news_list)} haber döndü (sorgu: {query})")
            return news_list
        except Exception as e:
            self.logger.error(f"NewsAPI'den haber çekilemedi: {e}")
            return []

    def save_news_to_json(self, news_list: List[Dict], filename: str):
        """
        Haber listesini JSON dosyasına kaydeder.
        """
        try:
            with open(filename, 'w', encoding='utf-8') as f:
                json.dump(news_list, f, ensure_ascii=False, indent=2)
        except Exception as e:
            self.logger.error(f"Haberler JSON'a kaydedilemedi: {e}")

    def load_news_from_json(self, filename: str) -> List[Dict]:
        """
        JSON dosyasından haber listesini okur.
        """
        if not os.path.exists(filename):
            return []
        try:
            with open(filename, 'r', encoding='utf-8') as f:
                return json.load(f)
        except Exception as e:
            self.logger.error(f"JSON'dan haber okunamadı: {e}")
            return []

    def print_newsapi_news(self, stock_symbol: str, api_key: str, json_file: str = None):
        """
        Komut satırında test/debug amaçlı NewsAPI haberlerini yazdırır.

        Adımlar:
        1) Varsa daha önce kaydedilmiş JSON dosyasını okur ve ekrana basar
        2) NewsAPI'den yeni haberleri çeker ve ekrana basar
        3) Yeni haberleri JSON dosyasına kaydeder
        """
        if json_file is None:
            json_file = f"newsapi_{stock_symbol}.json"
        # Önce JSON'dan haberleri göster
        old_news = self.load_news_from_json(json_file)
        if old_news:
            print(f"\n{stock_symbol} için KAYITLI haberler (JSON):")
            for i, news in enumerate(old_news, 1):
                print(f"{i}. {news.get('title','')}")
                print(f"   Kaynak: {news.get('source','')}")
                print(f"   Tarih: {news.get('published','')}")
                print(f"   Link: {news.get('link','')}")
                print(f"   Açıklama: {news.get('description','')}")
                print()
        else:
            print(f"{stock_symbol} için kayıtlı haber bulunamadı.")
        # Şimdi yeni haberleri çek
        news_list = self.fetch_newsapi_news(stock_symbol, api_key)
        if not news_list:
            print(f"{stock_symbol} için NewsAPI'den yeni haber bulunamadı.")
            return
        print(f"\n{stock_symbol} için NewsAPI'den gelen yeni haberler:")
        for i, news in enumerate(news_list, 1):
            print(f"{i}. {news['title']}")
            print(f"   Kaynak: {news['source']}")
            print(f"   Tarih: {news['published']}")
            print(f"   Link: {news['link']}")
            print(f"   Açıklama: {news['description']}")
            print()
        # Yeni haberleri JSON'a kaydet
        self.save_news_to_json(news_list, json_file)
