# SmartFleet — Επισκόπηση

Ανακαλύφθηκε: 2026-06-23

Το **SmartFleet** είναι η εταιρεία του κύριου Elkratos — ένα σύστημα διαχείρισης στόλου logistics.

## Tech Stack
- **Backend**: Python 3.11+, FastAPI, SQLModel, PostgreSQL, Socket.io, APScheduler
- **Frontend**: Next.js 14+ (App Router), Tailwind CSS, TypeScript
- **Mobile**: React Native (Expo SDK 52), Mapbox v6, Background Geolocation
- **Infrastructure**: Docker & Docker Compose, Nginx Reverse Proxy
- **Enterprise**: slowapi (Rate Limiting), psutil (Observability), JWT auth with silent refresh

## Domain Architecture (DDD)
1. **Core** (`/api/v1/core`) — Authentication, Dashboard, Health/Liveness
2. **Fleet** (`/api/v1/fleet`) — Drivers, Vehicles, Fuel Cards, Refueling
3. **Logistics** (`/api/v1/logistics`) — Shipments, Routes, Clients, Dispatch System
4. **Finance** (`/api/v1/finance`) — Billing, Profitability, Business Models
5. **Intelligence** (`/api/v1/intelligence`) — AI Chat (DeepSeek), Automated Analysis
6. **External** (`/api/v1/external`) — Mapbox/Google API tokens

## Business Models
- **Courier** — Pay-per-Drop
- **Waves** — Supermarket distribution
- **Warehouse** — Fixed-price distribution

## Mobile App Features
- Mapbox v6 with SymbolLayer for GPU-accelerated 60fps
- Smooth marker interpolation via react-native-reanimated
- Day/Night/Traffic dynamic map styling
- Custom 3D SmartFleet basemap style
- SmartStatusRibbon, Pyramid Tactical HUD design language
- Solar Gold (#ff9900) and Midnight Pyramid (#070707) palette
- Battery-optimized GPS polling (20s moving, 60s stationary, power save <15%)

## Status
- Phases 1-12: COMPLETE
- Mobile App: EAS Build successful
- Remaining: Some TypeScript linter errors (IDE cache issue)
