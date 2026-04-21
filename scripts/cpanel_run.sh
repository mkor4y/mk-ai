#!/usr/bin/env bash
# =============================================================================
# BIST Telegram Bot - cPanel Cron Script
# =============================================================================
# Bu script cPanel cron job ile kullanılmak üzere tasarlanmıştır.
# 
# KURULUM:
# 1. Bu dosyayı sunucuya yükleyin: /home/kullaniciadi/bist-bot/scripts/cpanel_run.sh
# 2. Çalıştırılabilir yapın: chmod +x scripts/cpanel_run.sh
# 3. cPanel Cron Job ekleyin (her 2 dakikada bir):
#    */2 * * * * /home/KULLANICIADI/bist-bot/scripts/cpanel_run.sh >> /home/KULLANICIADI/bist-bot/cron.log 2>&1
#
# NOT: KULLANICIADI kısmını kendi cPanel kullanıcı adınızla değiştirin!
# =============================================================================

set -euo pipefail

# ==================== AYARLAR ====================
# Bu değerleri kendi sunucu yapınıza göre düzenleyin:

# Proje dizini (bot dosyalarının olduğu yer)
PROJECT_DIR="${PROJECT_DIR:-$(dirname "$0")/..}"

# Python virtual environment yolu
# cPanel'de genellikle: /home/kullaniciadi/virtualenv/proje-adi/3.11/bin/python
VENV_PYTHON="${VENV_PYTHON:-}"

# Lock dosyası (çift çalışmayı önler)
LOCK_FILE="${LOCK_FILE:-/tmp/bist_bot.lock}"

# Log dosyası
LOG_FILE="${LOG_FILE:-$PROJECT_DIR/bist_bot.log}"

# ==================== FONKSİYONLAR ====================

log_message() {
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] $1"
}

find_python() {
    # Öncelik sırası:
    # 1. VENV_PYTHON değişkeni tanımlı ise onu kullan
    # 2. Proje dizininde venv varsa onu kullan
    # 3. Sistem python3'ü kullan
    
    if [[ -n "$VENV_PYTHON" && -x "$VENV_PYTHON" ]]; then
        echo "$VENV_PYTHON"
        return 0
    fi
    
    # cPanel standart venv yapısını kontrol et
    local cpanel_venv
    for version in 3.11 3.10 3.9 3.8; do
        cpanel_venv="$HOME/virtualenv/$(basename "$PROJECT_DIR")/$version/bin/python"
        if [[ -x "$cpanel_venv" ]]; then
            echo "$cpanel_venv"
            return 0
        fi
    done
    
    # Proje içi venv
    if [[ -x "$PROJECT_DIR/venv/bin/python" ]]; then
        echo "$PROJECT_DIR/venv/bin/python"
        return 0
    fi
    
    # Son çare: sistem python
    if command -v python3 &> /dev/null; then
        echo "python3"
        return 0
    fi
    
    echo "python"
}

check_bot_running() {
    # Bot zaten çalışıyor mu kontrol et
    if [[ -f "$LOCK_FILE" ]]; then
        local pid
        pid=$(cat "$LOCK_FILE" 2>/dev/null || echo "")
        if [[ -n "$pid" ]] && kill -0 "$pid" 2>/dev/null; then
            return 0  # Bot çalışıyor
        else
            # Eski/geçersiz lock dosyası, temizle
            rm -f "$LOCK_FILE"
        fi
    fi
    return 1  # Bot çalışmıyor
}

# ==================== ANA SCRIPT ====================

# Proje dizinine git
cd "$PROJECT_DIR" || {
    log_message "HATA: Proje dizinine gidilemedi: $PROJECT_DIR"
    exit 1
}

# Mutlak yola çevir
PROJECT_DIR="$(pwd)"

log_message "Bot başlatılıyor..."
log_message "Proje dizini: $PROJECT_DIR"

# Bot zaten çalışıyor mu?
if check_bot_running; then
    log_message "Bot zaten çalışıyor (PID: $(cat "$LOCK_FILE")). Çıkılıyor."
    exit 0
fi

# Python yolunu bul
PYTHON_BIN=$(find_python)
log_message "Python: $PYTHON_BIN"

# Python varlığını kontrol et
if ! command -v "$PYTHON_BIN" &> /dev/null && [[ ! -x "$PYTHON_BIN" ]]; then
    log_message "HATA: Python bulunamadı: $PYTHON_BIN"
    exit 1
fi

# main.py varlığını kontrol et
if [[ ! -f "main.py" ]]; then
    log_message "HATA: main.py bulunamadı!"
    exit 1
fi

# .env dosyası var mı?
if [[ ! -f ".env" ]]; then
    log_message "UYARI: .env dosyası bulunamadı. API anahtarları eksik olabilir."
fi

# Lock dosyası oluştur ve PID kaydet
echo $$ > "$LOCK_FILE"

# Bot'u başlat
log_message "Bot başlatılıyor..."

# nohup ile arka planda çalıştır (cron bitse bile devam etsin)
nohup "$PYTHON_BIN" main.py >> "$LOG_FILE" 2>&1 &
BOT_PID=$!

# PID'i lock dosyasına kaydet
echo "$BOT_PID" > "$LOCK_FILE"

log_message "Bot başlatıldı (PID: $BOT_PID)"
log_message "Log dosyası: $LOG_FILE"

exit 0
