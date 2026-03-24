#!/usr/bin/env bash
# ══════════════════════════════════════════════════════════════
#  deploy.sh – Blockpage → QNAP NAS
#  Usage:  bash deploy.sh
# ══════════════════════════════════════════════════════════════
set -euo pipefail

NAS_HOST="192.168.178.16"
NAS_USER="darkerikles"
NAS_PORT="22"
NAS_DIR="/share/Public/Docker/Websites/onepager_social-ban"

# ── Farben ────────────────────────────────────────────────────
GREEN='\033[0;32m'; YELLOW='\033[1;33m'; RED='\033[0;31m'; NC='\033[0m'
info()    { echo -e "${GREEN}▶ $*${NC}"; }
warning() { echo -e "${YELLOW}⚠ $*${NC}"; }
error()   { echo -e "${RED}✗ $*${NC}"; exit 1; }

# ── 1. Verbindung prüfen ──────────────────────────────────────
info "Verbinde mit ${NAS_USER}@${NAS_HOST}…"
ssh -q -p "$NAS_PORT" -o ConnectTimeout=5 -o BatchMode=yes \
    "${NAS_USER}@${NAS_HOST}" exit 2>/dev/null \
  || error "SSH-Verbindung fehlgeschlagen. Tipp: SSH-Key einrichten (siehe README)."

# ── 2. Verzeichnis auf NAS anlegen ───────────────────────────
info "Stelle Zielverzeichnis sicher: ${NAS_DIR}"
ssh -p "$NAS_PORT" "${NAS_USER}@${NAS_HOST}" "mkdir -p '${NAS_DIR}'"

# ── 3. Dateien synchronisieren ───────────────────────────────
info "Synchronisiere Dateien…"
rsync -avz --delete \
  -e "ssh -p ${NAS_PORT}" \
  --exclude='.git' \
  --exclude='deploy.sh' \
  --exclude='*.md' \
  . "${NAS_USER}@${NAS_HOST}:${NAS_DIR}/"

# ── 4. Docker Compose auf NAS starten ────────────────────────
info "Baue und starte Container auf dem NAS…"
ssh -p "$NAS_PORT" "${NAS_USER}@${NAS_HOST}" "
  set -e
  cd '${NAS_DIR}'
  # QNAP: docker compose (v2) oder docker-compose (v1)
  if command -v docker &>/dev/null && docker compose version &>/dev/null 2>&1; then
    docker compose up -d --build
  elif command -v docker-compose &>/dev/null; then
    docker-compose up -d --build
  else
    echo 'Docker Compose nicht gefunden!' && exit 1
  fi
"

echo ""
info "Deployment erfolgreich! 🎉"
echo -e "  Blockpage erreichbar unter: ${GREEN}http://${NAS_HOST}:8090${NC}"
