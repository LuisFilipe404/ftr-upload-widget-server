# Rodar o Build = docker build -t my-app:v1 .

FROM node:20.18 AS base

RUN npm i -g pnpm

FROM base AS dependencies

WORKDIR /usr/src/app
COPY package.json pnpm-lock.yaml ./
RUN pnpm install

FROM base AS build

WORKDIR /usr/src/app
COPY . .
COPY --from=dependencies /usr/src/app/node_modules ./node_modules

RUN pnpm build
RUN pnpm prune --prod

FROM node:20-alpine3.21 AS deploy

# Use a non-root user to run the application
USER 1000

WORKDIR /usr/src/app

COPY --from=build /usr/src/app/dist ./dist
COPY --from=build /usr/src/app/node_modules ./node_modules
COPY --from=build /usr/src/app/package.json ./package.json

EXPOSE 3333

CMD ["node", "dist/server.mjs"]






