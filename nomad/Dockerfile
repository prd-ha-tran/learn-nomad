ARG NOMAD_VERSION=1.1.2
ARG CONSUL_VERSION=1.10.0

FROM golang:alpine AS builder

ARG NOMAD_VERSION
ENV NOMAD_VERSION=$NOMAD_VERSION

RUN apk --no-cache add \
    bash \
    g++ \
    git \
    linux-headers \
    musl-dev

# Hashicorp Build
RUN mkdir -p /src/github.com/hashicorp/nomad && \
    cd /src/github.com/hashicorp/nomad || return 1 && \
# Get source and apply any patches.
    git clone -b "release-${NOMAD_VERSION}" https://github.com/hashicorp/nomad.git . && \
    echo "Building..." && \
    go build -x \
       -o bin/nomad \
       -tags "nonvidia release ui" \
       --ldflags '-linkmode external -extldflags "-static"' \
       .

FROM hashicorp/consul:${CONSUL_VERSION}

LABEL org.opencontainers.image.version=$CONSUL_VERSION-$NOMAD_VERSION

COPY --from=builder /src/github.com/hashicorp/nomad/bin/nomad /bin/nomad

# tiny smoke test to ensure the binary we downloaded runs
RUN consul version && \
    nomad version

RUN mkdir -p /nomad/data && \
    mkdir -p /nomad/config

VOLUME /nomad/data

EXPOSE 4646

EXPOSE 4647 4647/udp 4648 4648/udp

COPY docker-entrypoint.sh /usr/local/bin/docker-entrypoint.sh
ENTRYPOINT ["docker-entrypoint.sh"]

# By default you'll get an insecure single-node development server that stores
# everything in RAM, exposes a web UI and HTTP endpoints, and bootstraps itself.
# Don't use this configuration for production.
CMD ["agent", "-dev", "-client", "0.0.0.0"]