# ---- Dependencies Stage ----
FROM node:22.15.0-alpine AS deps
RUN apk add --no-cache libc6-compat

WORKDIR /app

# Set up pnpm and corepack environment for advanced dependency management
ENV PNPM_HOME="/pnpm"
ENV PATH="$PNPM_HOME:$PATH"

# Install corepack and prepare a known PNPM version
RUN npm install -g corepack@latest && corepack enable && corepack prepare pnpm@9.15.4 --activate

# Copy dependency manifests
COPY package.json yarn.lock* package-lock.json* pnpm-lock.yaml* ./

# Install dependencies based on the available lockfile
RUN \
  if [ -f yarn.lock ]; then yarn --frozen-lockfile; \
  elif [ -f package-lock.json ]; then npm ci; \
  elif [ -f pnpm-lock.yaml ]; then pnpm install --frozen-lockfile; \
  else echo "Lockfile not found." && exit 1; \
  fi

# ---- Build Stage ----
FROM node:22.15.0-alpine AS builder
WORKDIR /app

# Copy installed node_modules and necessary files from deps stage
COPY --from=deps /app/node_modules ./node_modules
COPY --from=deps /app/package.json ./
COPY . .

# Build your Next.js app (assumes you use Yarn; use `npm run build` if using npm)
RUN yarn build || npm run build || pnpm build

# ---- Production Stage ----
FROM node:22.15.0-alpine AS runner
WORKDIR /app

ENV NODE_ENV=production
ENV PNPM_HOME="/pnpm"
ENV PATH="$PNPM_HOME:$PATH"
# Uncomment to disable Next.js telemetry
# ENV NEXT_TELEMETRY_DISABLED 1

RUN addgroup --system --gid 1001 nodejs && \
    adduser --system --uid 1001 nextjs

# Copy only production assets from builder
COPY --from=builder /app/public ./public
COPY --from=builder /app/.next/standalone ./
COPY --from=builder /app/.next/static ./.next/static

# Set correct permission for prerender cache
RUN mkdir .next && chown nextjs:nodejs .next

USER nextjs

EXPOSE 3000
ENV PORT 3000

# Use the custom server if present, otherwise fall back to Next default
CMD [ "node", "server.js" ]
