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

ENV NODE_ENV=production

COPY package*.json ./
RUN npm ci --only=production

COPY . .

ARG VITE_API_BASE_URL
ARG VITE_WS_BASE_URL
ARG VITE_AGORA_APP_ID
ARG VITE_LIVEKIT_URL
ARG VITE_GOOGLE_MAPS_KEY
ARG VITE_CLOUDINARY_CLOUD_NAME

RUN npm run build

# ── Production (Nginx serves static files) ────────────────────────────
FROM nginx:1.25-alpine AS production

COPY --from=builder /app/dist /var/www/frontend
COPY nginx.frontend.conf /etc/nginx/conf.d/default.conf

EXPOSE 80
