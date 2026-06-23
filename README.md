# BuddyUp

**Health & fitness social platform** — train with buddies, join live workouts, eat better, and stay accountable, all in one place.

## Architecture

```
┌──────────────────────────────────────────────────────────┐
│                      BUDDYUP STACK                        │
├──────────────────┬───────────────────────────────────────┤
│  frontend        │  React 18 + TypeScript + Vite          │
│  backend         │  Django 5 + DRF + Daphne (ASGI)        │
│  celery-worker   │  Celery worker (multi-queue)           │
│  celery-beat     │  Celery beat scheduler                 │
│  db              │  PostgreSQL 16                         │
│  redis           │  Redis 7 (cache + channels + broker)   │
│  nginx           │  Nginx reverse proxy (prod only)       │
└──────────────────┴───────────────────────────────────────┘
```

## Prerequisites

- Docker Desktop 24+
- Docker Compose v2
- Node 20 (for local frontend without Docker)
- Python 3.12 (for local backend without Docker)

## Quick Start

```bash
git clone <repo-url> buddyup
cd buddyup
cp .env.example .env
make dev
```

The platform will be running at:
- **Frontend:** http://localhost:5173
- **Backend API:** http://localhost:8000/api/v1/
- **Swagger Docs:** http://localhost:8000/api/schema/swagger/
- **Django Admin:** http://localhost:8000/admin/

## Environment Variables

See `.env.example` for the full list of environment variables. Key variables:

| Variable | Description |
|---|---|
| `SECRET_KEY` | Django secret key |
| `DB_NAME` / `DB_USER` / `DB_PASSWORD` | PostgreSQL credentials |
| `REDIS_URL` | Redis connection string |
| `AGORA_APP_ID` | Agora.io app ID for live streaming |
| `OPENAI_API_KEY` | OpenAI API key for AI features |
| `STRIPE_SECRET_KEY` | Stripe payments |
| `SENDGRID_API_KEY` | Transactional email |
| `CLOUDINARY_URL` | Media storage |

## Development Commands

All commands via `make`:

```bash
make dev          # Start all services in development mode
make dev-d        # Start detached (background)
make logs         # View all logs
make logs-backend # View backend logs only
make logs-celery  # View Celery logs
make migrate      # Run database migrations
make migrations   # Create new migrations
make seed         # Seed development data
make superuser    # Create Django superuser
make shell-backend # Open Django shell_plus
make shell-db     # Open PostgreSQL shell
make shell-redis  # Open Redis shell
```

## Testing

```bash
make test-backend  # Run backend tests (pytest)
make test-frontend # Run frontend tests (vitest)
make test-e2e      # Run E2E tests (playwright)
```

## Linting

```bash
make lint          # Run both backend and frontend linting
make lint-backend  # ruff + mypy
make lint-frontend # ESLint + TypeScript type check
```

## Database Migrations

```bash
# Create migrations after model changes
make migrations

# Apply migrations
make migrate

# Seed development data
make seed
```

## Production Deployment

### Option 1: Railway (managed)

1. Connect GitHub repo to Railway
2. Set environment variables in Railway dashboard
3. Deploy: Railway detects Dockerfile and builds automatically

### Option 2: VPS (self-hosted)

```bash
# Copy env files
cp .env.example .env.prod
# Edit .env.prod with production values

# Start production stack
make prod

# View logs
docker compose -f docker-compose.prod.yml logs -f
```

## Project Structure

```
buddyup/
├── frontend/        React + TypeScript + Vite
│   ├── src/
│   │   ├── api/     API client + per-resource modules
│   │   ├── components/ui/      Design system primitives
│   │   ├── components/layout/  AppShell, BottomNav, Sidebar
│   │   ├── components/features/ Feature composites
│   │   ├── hooks/    Custom React hooks
│   │   ├── lib/      Utilities (wsManager, agora, etc.)
│   │   ├── pages/    Route-level page components
│   │   ├── store/    Zustand stores
│   │   ├── types/    TypeScript interfaces
│   │   └── styles/   Global CSS (Tailwind)
│   └── ...config files
│
├── backend/         Django 5 + DRF
│   ├── config/      Settings, URLs, ASGI, Celery
│   ├── apps/        13 Django apps
│   │   ├── accounts/   Auth, KYC, age verification
│   │   ├── profiles/   Profiles, buddy system, follows
│   │   ├── feed/       Posts, comments, reactions
│   │   ├── gyms/       Gym communities, roles
│   │   ├── lives/      Live sessions, random drop
│   │   ├── sessions/   PT session booking, escrow
│   │   ├── messaging/  DMs, group chats, Channels
│   │   ├── marketplace/ Meal plans, supplements
│   │   ├── wallet/     Artifact economy
│   │   ├── notifications/ Push + in-app
│   │   ├── moderation/ Content moderation
│   │   ├── verification/ Badge management
│   │   └── ai/         Meal plan personalisation
│   ├── common/      Shared models, permissions, pagination
│   └── requirements/
│
├── nginx/           Reverse proxy config
├── docker-compose.yml        Dev stack
├── docker-compose.prod.yml   Production stack
├── Makefile                  Dev commands
└── .env.example              Env template
```

## Troubleshooting

**Docker port conflicts:**
```bash
# Check what's using a port
lsof -i :5432
lsof -i :6379
lsof -i :8000
lsof -i :5173
```

**Redis connection errors:**
Ensure Redis is running: `make shell-redis` then `PING` should return `PONG`.

**Database connection errors:**
```bash
make shell-db
# Verify database exists: \l
```

**Frontend build issues:**
```bash
# Clear node_modules and reinstall
rm -rf frontend/node_modules frontend/package-lock.json
docker compose build --no-cache frontend
```

## License

Copyright &copy; 2025 BuddyUp. All rights reserved.
