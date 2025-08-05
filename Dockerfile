# syntax=docker.io/docker/dockerfile:1

FROM node:18-alpine AS base

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


# Create runner 
FROM base AS runner
WORKDIR /app

ENV NODE_ENV=production
ENV OTEL_SERVICE_NAME='jiraclone'
ENV OTEL_EXPORTER_OTLP_ENDPOINT='http://localhost:4318'
ENV SPLUNK_METRICS_ENABLED='true'
ENV SPLUNK_AUTOMATIC_LOG_COLLECTION='true'


RUN addgroup --system --gid 1001 nodejs
RUN adduser --system --uid 1001 nextjs

COPY --from=builder --chown=nextjs:nodejs /app/.next/standalone ./
COPY --from=builder --chown=nextjs:nodejs /app/.next/static ./.next/static

COPY otel.yml /etc/otel/config.yaml

RUN apk add --no-cache curl tar && \
    curl -L https://github.com/signalfx/splunk-otel-collector/releases/download/v0.130.0/splunk-otel-collector_0.130.0_amd64.tar.gz -o /tmp/otelcol.tar.gz && \
    mkdir -p /tmp/otelcol-dir && \
    tar -xzf /tmp/otelcol.tar.gz -C /tmp/otelcol-dir && \
    mv /tmp/otelcol-dir/splunk-otel-collector/bin/otelcol /usr/local/bin/otelcol && \
    chmod +x /usr/local/bin/otelcol && \
    rm -rf /tmp/otelcol* 

COPY entrypoint.sh /entrypoint.sh

RUN chmod +x /entrypoint.sh

USER nextjs

EXPOSE 3000

ENV PORT=3000

# Start server
ENV HOSTNAME="0.0.0.0"
# CMD ["node", "server.js"]
CMD [ "/entrypoint.sh" ]