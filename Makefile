.PHONY: dev prod build logs shell-backend shell-frontend migrate seed test lint

# ── Development ───────────────────────────────────────────────────────
dev:
	docker compose up --build

dev-d:
	docker compose up --build -d

# ── Production ────────────────────────────────────────────────────────
prod:
	docker compose -f docker-compose.prod.yml up --build -d

prod-down:
	docker compose -f docker-compose.prod.yml down

# ── Build ─────────────────────────────────────────────────────────────
build:
	docker compose build --no-cache

# ── Logs ──────────────────────────────────────────────────────────────
logs:
	docker compose logs -f

logs-backend:
	docker compose logs -f backend

logs-celery:
	docker compose logs -f celery-worker celery-beat

# ── Shell access ──────────────────────────────────────────────────────
shell-backend:
	docker compose exec backend python manage.py shell_plus

shell-db:
	docker compose exec db psql -U buddyup -d buddyup_dev

shell-redis:
	docker compose exec redis redis-cli

# ── Django management ─────────────────────────────────────────────────
migrate:
	docker compose exec backend python manage.py migrate

migrations:
	docker compose exec backend python manage.py makemigrations

seed:
	docker compose exec backend python manage.py seed_dev_data

superuser:
	docker compose exec backend python manage.py createsuperuser

collectstatic:
	docker compose exec backend python manage.py collectstatic --noinput

# ── Testing ───────────────────────────────────────────────────────────
test-backend:
	docker compose exec backend pytest --reuse-db -v

test-frontend:
	docker compose exec frontend npm run test

test-e2e:
	docker compose exec frontend npm run test:e2e

# ── Linting ───────────────────────────────────────────────────────────
lint-backend:
	docker compose exec backend ruff check . && mypy .

lint-frontend:
	docker compose exec frontend npm run lint && npm run type-check

lint: lint-backend lint-frontend

# ── Cleanup ───────────────────────────────────────────────────────────
down:
	docker compose down

clean:
	docker compose down -v --remove-orphans
	docker system prune -f
