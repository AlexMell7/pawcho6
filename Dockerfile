# syntax=docker/dockerfile:1

FROM alpine/git:latest AS source
RUN apk add --no-cache openssh-client
RUN mkdir -p -m 0700 ~/.ssh && ssh-keyscan github.com >> ~/.ssh/known_hosts

RUN --mount=type=ssh git clone git@github.com:AlexMell7/pawcho6.git /app

FROM golang:1.21-alpine AS builder
ARG VERSION
WORKDIR /app

COPY --from=source /app .

RUN CGO_ENABLED=0 GOOS=linux go build -o html-gen main.go

FROM nginx:alpine

LABEL org.opencontainers.image.source="https://github.com/AlexMell7/pawcho6"
LABEL org.opencontainers.image.description="Obraz Lab 6 - Go + Nginx z pobieraniem przez SSH"
LABEL org.opencontainers.image.licenses="MIT"

COPY --from=builder /app/html-gen /usr/local/bin/html-gen
ARG VERSION
ENV APP_VERSION=$VERSION

RUN echo '#!/bin/sh' > /entrypoint.sh && \
    echo '/usr/local/bin/html-gen > /usr/share/nginx/html/index.html' >> /entrypoint.sh && \
    echo 'nginx -g "daemon off;"' >> /entrypoint.sh && \
    chmod +x /entrypoint.sh

HEALTHCHECK --interval=10s --timeout=3s \
  CMD curl -f http://localhost/ || exit 1

CMD ["/entrypoint.sh"]