FROM oven/bun:latest AS builder
COPY ./ /usr/local/src/database-seeder
WORKDIR /usr/local/src/database-seeder
RUN bun install --production
RUN bun ./build.ts

FROM oven/bun:latest 
WORKDIR /usr/local/src/database-seeder
COPY --from=builder /usr/local/src/database-seeder/dist /usr/local/src/database-seeder/dist
CMD ["bun", "./dist/index.js"]