FROM node:20-alpine AS base

# Install dependencies only when needed
FROM base AS deps
RUN apk add --no-cache libc6-compat
WORKDIR /app

COPY package.json package-lock.json* ./
RUN npm ci --legacy-peer-deps

# Rebuild the source code only when needed
FROM base AS builder
WORKDIR /app
COPY --from=deps /app/node_modules ./node_modules
COPY . .

ENV NEXT_TELEMETRY_DISABLED 1

# Set NEXT_PUBLIC_* env vars at build time (required for client-side bundle)
# These will be provided via --build-arg during deployment
# Default values are provided as fallback (should be overridden)
ARG NEXT_PUBLIC_SUPABASE_URL=https://spzcjpvtikyoykbgnlgr.supabase.co
ARG NEXT_PUBLIC_SUPABASE_ANON_KEY=eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InNwemNqcHZ0aWt5b3lrYmdubGdyIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NjQzNTY2NzgsImV4cCI6MjA3OTkzMjY3OH0.m06J6IujRB6dX0Cqw00Y6NnGgGUCo6yU7CdnqSIWVzc
ENV NEXT_PUBLIC_SUPABASE_URL=$NEXT_PUBLIC_SUPABASE_URL
ENV NEXT_PUBLIC_SUPABASE_ANON_KEY=$NEXT_PUBLIC_SUPABASE_ANON_KEY

RUN npm run build

# Production image, copy all the files and run next
FROM base AS runner
WORKDIR /app

ENV NODE_ENV production
ENV NEXT_TELEMETRY_DISABLED 1

RUN addgroup --system --gid 1001 nodejs
RUN adduser --system --uid 1001 nextjs

# Copy public assets
COPY --from=builder /app/public ./public

# Copy standalone build (includes server.js)
COPY --from=builder --chown=nextjs:nodejs /app/.next/standalone ./
COPY --from=builder --chown=nextjs:nodejs /app/.next/static ./.next/static

USER nextjs

# Cloud Run provides PORT env var, default to 8080
ENV PORT=8080
ENV HOSTNAME="0.0.0.0"

EXPOSE 8080

# Next.js standalone creates server.js in the standalone directory root
CMD ["node", "server.js"]

