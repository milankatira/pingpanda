# ---- Base Stage ----
# Use a specific Node.js version for consistency.
FROM node:22.5.1-alpine AS base
WORKDIR /app
COPY package.json yarn.lock ./
COPY prisma ./prisma

# ---- Dependencies Stage ----
# Install all dependencies, including devDependencies, for building the app.
FROM base AS deps
RUN yarn install --frozen-lockfile

# ---- Builder Stage ----
# Build the Next.js application.
FROM deps AS builder
COPY . .
# Set build-time environment variables
ARG DATABASE_URL
ARG NEXT_PUBLIC_APP_URL
ARG NEXT_PUBLIC_CLERK_PUBLISHABLE_KEY
ARG CLERK_SECRET_KEY
ARG STRIPE_SECRET_KEY
ARG STRIPE_WEBHOOK_SECRET

ENV DATABASE_URL=${DATABASE_URL}
ENV NEXT_PUBLIC_APP_URL=${NEXT_PUBLIC_APP_URL}
ENV NEXT_PUBLIC_CLERK_PUBLISHABLE_KEY=${NEXT_PUBLIC_CLERK_PUBLISHABLE_KEY}
ENV CLERK_SECRET_KEY=${CLERK_SECRET_KEY}
ENV STRIPE_SECRET_KEY=${STRIPE_SECRET_KEY}
ENV STRIPE_WEBHOOK_SECRET=${STRIPE_WEBHOOK_SECRET}
RUN yarn build

# ---- Runner Stage ----
# Create the final, smaller production image.
FROM base AS runner
WORKDIR /app
COPY --from=builder /app/.next ./.next
COPY --from=builder /app/node_modules ./node_modules
COPY --from=builder /app/package.json ./package.json
COPY --from=builder /app/public ./public
# Set the command to start the app
CMD ["yarn", "start"]
