# Use a Node.js image as the base.
# This image comes with Node.js and npm/pnpm ready to use.
FROM node:22.5.1-alpine

# Set the working directory inside the container.
WORKDIR /app

# Enable corepack to use pnpm.
RUN corepack enable && corepack prepare pnpm@9.15.4 --activate

# Copy the dependency files first.
# This allows Docker to cache the 'pnpm install' step if your package.json doesn't change.
COPY package.json pnpm-lock.yaml ./

# Copy the rest of your application's source code.
COPY . .

# Install project dependencies.
RUN pnpm install

# Build the Next.js application for production.
RUN pnpm build

# Set the port that the application will listen on.
EXPOSE 3000

# Set the command to start the Next.js server in production mode.
CMD ["pnpm", "start"]