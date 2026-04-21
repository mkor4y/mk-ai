#!/usr/bin/env bash
# =============================================================================
# BIST Telegram Bot - Durdurma Scripti
# =============================================================================
# Çalışan bot'u güvenli şekilde durdurur.
#
# Kullanım: ./scripts/stop_bot.sh
# =============================================================================

set -euo pipefail

PROJECT_DIR="${PROJECT_DIR:-$(dirname "$0")/..}"
LOCK_FILE="${LOCK_FILE:-/tmp/bist_bot.lock}"

log_message() {
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] $1"
}

cd "$PROJECT_DIR" || exit 1

if [[ ! -f "$LOCK_FILE" ]]; then
    log_message "Bot çalışmıyor (lock dosyası yok)."
    exit 0
fi

PID=$(cat "$LOCK_FILE" 2>/dev/null || echo "")

if [[ -z "$PID" ]]; then
    log_message "Lock dosyası boş, temizleniyor."
    rm -f "$LOCK_FILE"
    exit 0
fi

if kill -0 "$PID" 2>/dev/null; then
    log_message "Bot durduruluyor (PID: $PID)..."
    kill "$PID"
    sleep 2
    
    # Hala çalışıyorsa zorla kapat
    if kill -0 "$PID" 2>/dev/null; then
        log_message "Zorla kapatılıyor..."
        kill -9 "$PID" 2>/dev/null || true
    fi
    
    rm -f "$LOCK_FILE"
    log_message "Bot durduruldu."
else
    log_message "Bot zaten çalışmıyor (PID: $PID geçersiz)."
    rm -f "$LOCK_FILE"
fi

exit 0
