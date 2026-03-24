#!/usr/bin/env bash
# ══════════════════════════════════════════════════════════════
#  deploy.sh – Blockpage → QNAP NAS
#  Usage:  bash deploy.sh
# ══════════════════════════════════════════════════════════════
set -euo pipefail

NAS_HOST="192.168.178.165"
NAS_USER="darkerikles"
NAS_PORT="29"
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

# ── 3. Dateien übertragen (tar via SSH, kein rsync nötig) ────
info "Übertrage Dateien…"
tar -czf - \
  --exclude='./.git' \
  --exclude='./deploy.sh' \
  --exclude='./*.md' \
  . \
| ssh -p "$NAS_PORT" "${NAS_USER}@${NAS_HOST}" \
  "mkdir -p '${NAS_DIR}' && tar -xzf - -C '${NAS_DIR}'"

# ── 4. Container auf NAS bauen und starten ───────────────────
info "Baue und starte Container auf dem NAS…"
DOCKER='/share/CE_CACHEDEV1_DATA/.qpkg/container-station/bin/docker'
DCFG='/tmp/docker-cfg-deploy'
ssh -p "$NAS_PORT" "${NAS_USER}@${NAS_HOST}" \
  "mkdir -p ${DCFG} && export DOCKER_HOST=unix:///var/run/docker.sock; cd '${NAS_DIR}' && ${DOCKER} --config ${DCFG} stop blockpage 2>/dev/null; ${DOCKER} --config ${DCFG} rm blockpage 2>/dev/null; ${DOCKER} --config ${DCFG} build -t blockpage:latest . && ${DOCKER} --config ${DCFG} run -d --name blockpage --restart always -p 8090:80 blockpage:latest"

echo ""
info "Deployment erfolgreich! 🎉"
echo -e "  Blockpage erreichbar unter: ${GREEN}http://${NAS_HOST}:8090${NC}"
