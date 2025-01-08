ARG DOTNET_BUILDER_IMAGE=mcr.microsoft.com/dotnet/sdk:9.0
ARG DOTNET_RUNNER_IMAGE=mcr.microsoft.com/dotnet/aspnet:9.0
ARG ENVIRONMENT=production
ARG ASSEMBLY_PATH=AspNetCoreEf.dll
ARG PROJECT_PATH=apps/aspnetcore-ef


FROM ${DOTNET_BUILDER_IMAGE} AS builder-base
ARG ENVIRONMENT
ARG ASSEMBLY_PATH

ENV ENVIRONMENT=${ENVIRONMENT}
ENV ASSEMBLY_PATH=${ASSEMBLY_PATH}

ONBUILD WORKDIR /usr/local/src/web-benchmarks/

# Copy everything
ONBUILD COPY ./ ./
# Restore as distinct layers
ONBUILD RUN dotnet restore
ONBUILD RUN dotnet publish ${PROJECT_PATH} -c Release -o out

FROM builder-base AS builder-production


# Build runtime image
FROM ${DOTNET_RUNNER_IMAGE} AS runner-base
ARG ENVIRONMENT
ARG ASSEMBLY_PATH

ENV ENVIRONMENT=${ENVIRONMENT}
ENV ASSEMBLY_PATH=${ASSEMBLY_PATH}

ONBUILD WORKDIR /usr/local/bin/web-benchmarks

ONBUILD ENTRYPOINT [ "sh", "-c", "dotnet ${ASSEMBLY_PATH}" ]


FROM runner-base AS runner-production
ONBUILD COPY --from=builder-production /usr/local/src/web-benchmarks/out/ ./


FROM runner-${ENVIRONMENT}