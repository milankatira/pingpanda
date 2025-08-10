# Use a Node.js image as the base.
# This image comes with Node.js, npm, and yarn ready to use.
FROM node:22.5.1-alpine

# Set the working directory inside the container.
WORKDIR /app

# Copy the dependency files first.
# This allows Docker to cache the 'yarn install' step if your package.json and yarn.lock don't change.
COPY package.json yarn.lock ./

# Copy the rest of your application's source code.
COPY . .

# Install project dependencies.
RUN yarn install

# Build the Next.js application for production.
RUN yarn build

# Set the port that the application will listen on.
EXPOSE 3000

# Set the command to start the Next.js server in production mode.
CMD ["yarn", "start"]