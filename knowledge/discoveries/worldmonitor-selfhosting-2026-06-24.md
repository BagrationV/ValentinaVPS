# WorldMonitor — Self-Hosting Deployment
## Deployed: 24 Ιουνίου 2026

### Status
- **Repo**: `koala73/worldmonitor` (AGPL-3.0)
- **Clone**: ✅ `/home/vitalios/worldmonitor/` — 3551 files
- **npm install**: ✅ 1617 packages
- **Secrets**: ✅ Generated (REDIS_TOKEN, REDIS_PASSWORD, RELAY_SHARED_SECRET)
- **Docker Compose Build**: ✅ Completed
- **Docker Compose Up**: ✅ Running (4 containers)
- **Dashboard**: ✅ LIVE at http://localhost:3000
- **Health**: UNHEALTHY (196 checks, 10 OK — seeders need API keys to complete)
- **Symlink Fix**: `index.html → dashboard.html` (Vite build produces dashboard.html)
- **Stack**: 4 services (worldmonitor, redis, redis-rest, ais-relay)

### Deployment Commands
```bash
# Clone
git clone https://github.com/koala73/worldmonitor.git

# Host deps
npm install

# Secrets
echo "RELAY_SHARED_SECRET=$(openssl rand -hex 32)" >> .env
echo "REDIS_PASSWORD=$(openssl rand -hex 32)" >> .env
echo "REDIS_TOKEN=$(openssl rand -hex 32)" >> .env

# Start stack
docker compose up -d --build

# Seed data
./scripts/run-seeders.sh
```

### VPS Readiness
- Node.js v22.23.1 ✅
- npm 10.9.8 ✅
- Docker 29.1.3 + Compose v5 ✅
- Docker daemon accessible ✅
- RAM: 2066/7941 MB (26%)
- Disk: 32G/290G (11%)

### Secrets Protection
- `.env` is gitignored
- File tool blocks direct reading of .env files (defense-in-depth)
- Docker secrets available for production use

### Key Architecture
| Container | Purpose | Port |
|-----------|---------|------|
| worldmonitor | nginx + Node.js API (supervisord) | 3000 → 8080 |
| worldmonitor-redis | Data store | 6379 (internal) |
| worldmonitor-redis-rest | Upstash-compatible REST proxy | 8079 (127.0.0.1 only) |
| worldmonitor-ais-relay | Live vessel tracking WebSocket | 3004 (internal) |

### Required Secrets
1. `RELAY_SHARED_SECRET` — auth for AIS relay requests
2. `REDIS_PASSWORD` — Redis AUTH password
3. `REDIS_TOKEN` — Bearer token for REST proxy

### Next Steps
- [ ] Docker build completes
- [ ] `docker compose up -d`
- [ ] `./scripts/run-seeders.sh`
- [ ] Verify health at http://localhost:3000
- [ ] Optional: Nginx reverse proxy with subdomain
- [ ] Optional: API keys for data sources
- [ ] Optional: Cron job for daily briefings
