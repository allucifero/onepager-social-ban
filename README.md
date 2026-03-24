# Die Gesundheits-Reserve

OnePager-Blockpage für das Heimnetz. Wird angezeigt, wenn gesperrte Social-Media-Domains aufgerufen werden (via AdGuard Home).

## Stack

- **Frontend:** Statisches HTML/CSS/JS, Nunito-Font, Lucide Icons
- **Server:** nginx:alpine
- **Deployment:** GitHub Actions → GHCR → QNAP NAS (via Watchtower)

## Lokale Entwicklung

```bash
docker compose up
```

Erreichbar unter `http://localhost:8090`.

## Deployment

Jeder Push auf `main` baut automatisch ein neues Docker-Image und pusht es zu GHCR. Watchtower auf dem NAS erkennt das neue Image innerhalb von 5 Minuten und deployed es automatisch.

**Manuell** (falls nötig):

```bash
bash deploy.sh
```

## NAS-Setup

Einmalig auf dem NAS einzurichten – siehe `docker-compose.nas.yml`.
