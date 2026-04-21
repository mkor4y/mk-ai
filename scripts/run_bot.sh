#!/usr/bin/env bash
# =============================================================================
# BIST Telegram Bot - Basit Çalıştırma Scripti
# =============================================================================
# Tek seferlik çalıştırma için. Cron için cpanel_run.sh kullanın.
#
# Kullanım: ./scripts/run_bot.sh
# =============================================================================

set -euo pipefail

# Single-instance guard (prevents multiple bots)
LOCK_FILE="${LOCK_FILE:-/tmp/bist_bot.lock}"

# Allow overriding python binary (useful for cPanel venv)
PYTHON_BIN="${PYTHON_BIN:-python3}"

# Proje dizinine git
cd "$(dirname "$0")/.."

# flock ile tek instance garantisi ve bot'u çalıştır
exec flock -n "$LOCK_FILE" "$PYTHON_BIN" main.py

