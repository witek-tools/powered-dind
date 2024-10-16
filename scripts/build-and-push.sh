#! /bin/bash

VERSION=1.0.6

docker buildx build \
  --platform linux/amd64,linux/arm64 \
  --tag witektools/powered-dind:latest \
  --tag witektools/powered-dind:$VERSION \
  --label org.opencontainers.image.title="Witek Tools - Powered DinD" \
  --label org.opencontainers.image.description="A Docker image with Node.js, pnpm, Docker Buildx, and Amazon ECR Credential Helper for CI/CD." \
  --label org.opencontainers.image.url="https://www.witek.com.br" \
  --label org.opencontainers.image.source="https://github.com/witek-tools/powered-dind" \
  --label org.opencontainers.image.licenses="MIT" \
  --label org.opencontainers.image.vendor="Witek" \
  --label org.opencontainers.image.version="$VERSION" \
  --push .
