ARG PROJECT_PATH=apps/hono-kysely
ARG BUILD_ENTRYPOINT=src/index.ts
ARG RUNTIME_ENTRYPOINT=dist/index.js

FROM oven/bun:latest AS builder
ARG PROJECT_PATH
ARG BUILD_ENTRYPOINT
ARG RUNTIME_ENTRYPOINT

ENV BUILD_ENTRYPOINT=${BUILD_ENTRYPOINT}

WORKDIR /usr/local/src/app-workspace/
COPY . .
WORKDIR /usr/local/src/app-workspace/${PROJECT_PATH}
RUN bun install --production
RUN bun ./build.ts

FROM oven/bun:latest 
ARG PROJECT_PATH
ARG BUILD_ENTRYPOINT
ARG RUNTIME_ENTRYPOINT

ENV RUNTIME_ENTRYPOINT=${RUNTIME_ENTRYPOINT}

WORKDIR /usr/local/src/app
COPY --from=builder /usr/local/src/app-workspace/${PROJECT_PATH}/dist ./dist
ENTRYPOINT [ "sh", "-c" ]
CMD [ "bun $RUNTIME_ENTRYPOINT" ]