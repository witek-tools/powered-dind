# Stage 1: Final stage with Docker-in-Docker (DinD), Node, corepack, pnpm, AWS, Git and buildx support
FROM docker:latest AS runner

# Set the working directory
WORKDIR /usr/src/app

# Install Node.js and related dependencies
RUN apk add --no-cache --update \
  nodejs npm

# Install Docker CLI and related utilities
RUN apk add --no-cache --update \
  docker-cli bash curl

# Install Python and related dependencies
RUN apk add --no-cache --update \
  python3 py3-pip gcc g++ make linux-headers

# Install AWS CLI
RUN apk add --no-cache --update \
  aws-cli

# Install miscellaneous tools and utilities
RUN apk add --no-cache --update \
  ca-certificates openssl ncurses coreutils \
  git qemu groff less \
  findutils shadow libstdc++ util-linux grep binutils

# Create the docker group if it doesn't exist and add root to it
RUN if ! getent group docker > /dev/null 2>&1; then \
  addgroup docker; \
  fi && \
  adduser root docker

# Ensure corepack and npm are installed and updated
RUN npm i -g npm@latest corepack@latest

# Install pnpm
RUN corepack enable && corepack use pnpm@latest

# Enable Docker BuildKit and buildx without depending on Docker daemon
RUN mkdir -p ~/.docker/cli-plugins/ \
  && curl -L https://github.com/docker/buildx/releases/download/v0.8.2/buildx-v0.8.2.linux-amd64 -o ~/.docker/cli-plugins/docker-buildx \
  && chmod +x ~/.docker/cli-plugins/docker-buildx

# Export environment variables to enable BuildKit and buildx
ENV DOCKER_CLI_EXPERIMENTAL=enabled
ENV DOCKER_BUILDKIT=1

# Disable OpenTelemetry
ENV OTEL_SDK_DISABLED=true

# Set the entrypoint to the new entrypoint script
ENTRYPOINT ["dockerd-entrypoint.sh"]

# Default CMD Command
CMD []
