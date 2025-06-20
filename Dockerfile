# syntax=docker.io/docker/dockerfile:1

# FROM node:24.2.0-alpine3.21 AS base
FROM node:18-alpine AS base
# FROM node:latest AS base

RUN apk add --no-cache openssl libressl

# Installation
FROM base AS deps
WORKDIR /app

RUN apk add --no-cache libc6-compat


COPY package.json yarn.lock* package-lock.json* pnpm-lock.yaml* .npmrc* ./
RUN \
  if [ -f yarn.lock ]; then yarn --frozen-lockfile; \
  elif [ -f package-lock.json ]; then npm ci; \
  elif [ -f pnpm-lock.yaml ]; then corepack enable pnpm && pnpm i --frozen-lockfile; \
  else echo "Lockfile not found." && exit 1; \
  fi

# Build
FROM base AS builder
WORKDIR /app
COPY --from=deps /app/node_modules ./node_modules
COPY . .

# Generate prisma
RUN npx prisma generate

ENV UPSTASH_REDIS_REST_URL=http://fake
ENV UPSTASH_REDIS_REST_TOKEN=123456
ENV SKIP_ENV_VALIDATION=true

RUN \
  if [ -f yarn.lock ]; then yarn run build; \
  elif [ -f package-lock.json ]; then npm run build; \
  elif [ -f pnpm-lock.yaml ]; then corepack enable pnpm && pnpm run build; \
  else echo "Lockfile not found." && exit 1; \
  fi


# Create image
FROM base AS runner
WORKDIR /app

ENV NODE_ENV=production

RUN addgroup --system --gid 1001 nodejs
RUN adduser --system --uid 1001 nextjs

COPY --from=builder --chown=nextjs:nodejs /app/.next/standalone ./
COPY --from=builder --chown=nextjs:nodejs /app/.next/static ./.next/static

USER nextjs

EXPOSE 3000

ENV PORT=3000

# Start server
ENV HOSTNAME="0.0.0.0"
CMD ["node", "server.js"]