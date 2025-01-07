ARG ENVIRONMENT=production
ARG PROFILE=release
ARG PACKAGE_NAME=axum-sqlx
ARG BINARY_NAME=${PACKAGE_NAME}

FROM rust:latest AS builder-base
ARG ENVIRONMENT
ARG PROFILE
ARG PACKAGE_NAME
ARG BINARY_NAME

ENV ENVIRONMENT=${ENVIRONMENT}
ENV PROFILE=${PROFILE}
ENV PACKAGE_NAME=${PACKAGE_NAME}
ENV BINARY_NAME=${BINARY_NAME}

RUN apt update && apt upgrade -y && apt install mold -y


FROM builder-base AS builder-production
COPY ./ /usr/local/src/web-benchmarks
WORKDIR /usr/local/src/web-benchmarks
RUN cargo build --bin ${PACKAGE_NAME} --profile ${PROFILE}


FROM debian:latest AS runner-base
ARG ENVIRONMENT
ARG PROFILE
ARG PACKAGE_NAME
ARG BINARY_NAME

ENV ENVIRONMENT=${ENVIRONMENT}
ENV PROFILE=${PROFILE}
ENV PACKAGE_NAME=${PACKAGE_NAME}
ENV BINARY_NAME=${BINARY_NAME}


FROM runner-base AS runner-production
COPY --from=builder-production /usr/local/src/web-benchmarks/target/${PROFILE}/${BINARY_NAME} /usr/local/bin/${BINARY_NAME}

FROM runner-${ENVIRONMENT}

ENTRYPOINT [ "sh", "-c", "${BINARY_NAME}" ]