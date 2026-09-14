# ---- build stage ----
FROM golang:1.24-bookworm AS build
ARG MINIO_RELEASE=RELEASE.2025-09-07T16-13-09Z
ARG TARGETARCH

RUN git clone --branch ${MINIO_RELEASE} \
    https://github.com/minio/minio.git /src
WORKDIR /src
RUN CGO_ENABLED=0 GOOS=linux GOARCH=${TARGETARCH} \
    go build -tags kqueue -trimpath \
    --ldflags "$(go run buildscripts/gen-ldflags.go)" \
    -o /out/minio .

# ---- runtime stage ----
FROM debian:bookworm-slim
RUN apt-get update \
 && apt-get install -y --no-install-recommends ca-certificates \
 && rm -rf /var/lib/apt/lists/*
COPY --from=build /out/minio /usr/bin/minio
ENTRYPOINT ["minio"]
