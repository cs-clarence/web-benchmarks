ARG ENVIRONMENT=production
ARG PACKAGE_NAME=echo-sql
ARG BINARY_NAME=${PACKAGE_NAME}


FROM golang:alpine AS builder-base
ARG ENVIRONMENT
ARG PACKAGE_NAME
ARG BINARY_NAME

ENV ENVIRONMENT=${ENVIRONMENT}
ENV PACKAGE_NAME=${PACKAGE_NAME}
ENV BINARY_NAME=${BINARY_NAME}

ONBUILD WORKDIR /usr/local/src/web-benchmarks
ONBUILD COPY ./ ./


FROM builder-base AS builder-production
RUN go build -o bin/${BINARY_NAME} ./apps/${PACKAGE_NAME}/src/cmd/${PACKAGE_NAME}


FROM alpine:latest AS runner-base
ARG ENVIRONMENT
ARG PACKAGE_NAME
ARG BINARY_NAME

ENV ENVIRONMENT=${ENVIRONMENT}
ENV PACKAGE_NAME=${PACKAGE_NAME}
ENV BINARY_NAME=${BINARY_NAME}

ONBUILD ENTRYPOINT [ "sh", "-c", "${BINARY_NAME}" ]


FROM runner-base AS runner-production
COPY --from=builder-production /usr/local/src/web-benchmarks/bin/${BINARY_NAME} /usr/local/bin/${BINARY_NAME}


FROM runner-${ENVIRONMENT}

