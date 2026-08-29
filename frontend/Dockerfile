# ── Base ──────────────────────────────────────────────────────────────
FROM node:24-alpine AS base

WORKDIR /app
ENV NODE_ENV=development

# ── Development ────────────────────────────────────────────────────────
FROM base AS development

COPY package*.json ./
RUN npm ci
COPY . .
EXPOSE 3002

# ── Build ─────────────────────────────────────────────────────────────
FROM base AS builder

# vite + typescript live in devDependencies — a production-only install
# strips them and `npm run build` fails. Install everything here; the
# production stage only copies /app/dist, so the extra weight never ships.
ENV NODE_ENV=development

COPY package*.json ./
RUN npm ci

COPY . .

# Vite inlines VITE_* vars at build time from the environment, so promote
# build args to env vars before the build runs.
ARG VITE_API_BASE_URL
ARG VITE_WS_BASE_URL
ARG VITE_AGORA_APP_ID
ARG VITE_LIVEKIT_URL
ARG VITE_GOOGLE_CLIENT_ID
ARG VITE_GOOGLE_MAPS_KEY
ARG VITE_CLOUDINARY_CLOUD_NAME
ARG VITE_FIREBASE_CONFIG

ENV VITE_API_BASE_URL=$VITE_API_BASE_URL \
    VITE_WS_BASE_URL=$VITE_WS_BASE_URL \
    VITE_AGORA_APP_ID=$VITE_AGORA_APP_ID \
    VITE_LIVEKIT_URL=$VITE_LIVEKIT_URL \
    VITE_GOOGLE_CLIENT_ID=$VITE_GOOGLE_CLIENT_ID \
    VITE_GOOGLE_MAPS_KEY=$VITE_GOOGLE_MAPS_KEY \
    VITE_CLOUDINARY_CLOUD_NAME=$VITE_CLOUDINARY_CLOUD_NAME \
    VITE_FIREBASE_CONFIG=$VITE_FIREBASE_CONFIG

RUN npm run build

# ── Production (Nginx serves static files) ────────────────────────────
FROM nginx:1.25-alpine AS production

COPY --from=builder /app/dist /var/www/frontend
COPY nginx.frontend.conf /etc/nginx/conf.d/default.conf

EXPOSE 80
