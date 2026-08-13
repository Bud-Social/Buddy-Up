# ── Base ──────────────────────────────────────────────────────────────
FROM python:3.12-slim AS base

ENV PYTHONDONTWRITEBYTECODE=1 \
    PYTHONUNBUFFERED=1 \
    PIP_NO_CACHE_DIR=1 \
    PIP_DISABLE_PIP_VERSION_CHECK=1

RUN apt-get update && apt-get install -y --no-install-recommends \
    build-essential \
    libpq-dev \
    curl \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /app

# ── Dependencies ───────────────────────────────────────────────────────
FROM base AS deps

COPY requirements/base.txt ./requirements/base.txt
RUN pip install --no-cache-dir -r requirements/base.txt

# ── Development ────────────────────────────────────────────────────────
FROM deps AS development

COPY requirements/development.txt ./requirements/development.txt
RUN pip install --no-cache-dir -r requirements/development.txt

COPY . .
EXPOSE 8002

# ── Production ─────────────────────────────────────────────────────────
FROM deps AS production

COPY requirements/production.txt ./requirements/production.txt
RUN pip install --no-cache-dir -r requirements/production.txt

COPY . .

# Collect static files at build time so whitenoise has the directory on startup.
# SECRET_KEY is only needed for the collectstatic Django init; it's not stored.
RUN DJANGO_SETTINGS_MODULE=config.settings.production \
    SECRET_KEY=build-only-placeholder \
    python manage.py collectstatic --noinput

RUN addgroup --system appgroup && \
    adduser --system --ingroup appgroup appuser && \
    chown -R appuser:appgroup /app

USER appuser
EXPOSE 8002

HEALTHCHECK --interval=30s --timeout=10s --start-period=30s --retries=3 \
    CMD curl -f "http://localhost:${PORT:-8002}/api/v1/health/" || exit 1
