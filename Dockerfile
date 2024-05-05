# syntax=docker/dockerfile:1
FROM dunglas/frankenphp:latest-builder AS builder

# Install xcaddy from the official Caddy builder image
COPY --from=caddy:builder /usr/bin/xcaddy /usr/bin/xcaddy

# Enable CGO for building with native extensions
ENV CGO_ENABLED=1 \
    XCADDY_SETCAP=1 \
    XCADDY_GO_BUILD_FLAGS="-ldflags '-w -s'"

# Build FrankenPHP with custom modules including Cloudflare DNS module
RUN xcaddy build \
    --output /usr/bin/frankenphp \
    --with github.com/dunglas/frankenphp=./ \
    --with github.com/dunglas/frankenphp/caddy=./caddy/ \
    --with github.com/dunglas/mercure/caddy \
    --with github.com/dunglas/vulcain/caddy \
    --with github.com/caddy-dns/cloudflare

# Find and copy dependencies
RUN mkdir /deps
RUN ldd /usr/bin/frankenphp | tr -s '[:blank:]' '\n' | grep '^/' | xargs -I % sh -c 'cp % /deps'
