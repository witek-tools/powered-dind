# Stage 1: Use the base image with Go 1.22 to build the ECR Credential Helper
FROM golang:latest AS deps

# Set the working directory inside the container
WORKDIR /usr/src/app

# Install the Amazon ECR Credential Helper
RUN go install github.com/awslabs/amazon-ecr-credential-helper/ecr-login/cli/docker-credential-ecr-login@latest

# Stage 2: Final stage with Docker-in-Docker (DinD), Node, corepack, pnpm, ECR Helper, Git and buildx support
FROM docker:latest AS runner

# Set the working directory
WORKDIR /usr/src/app

# Install packages
RUN apk update && apk add --no-cache \
  # Utilities and buildx
  bash docker-cli git qemu curl \
  # Node.JS Environment
  nodejs npm \
  # Dependencies
  ca-certificates openssl ncurses coreutils python3 make gcc g++ libgcc linux-headers grep util-linux binutils findutils shadow libstdc++

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

# Copy the ECR Credential Helper binary from the deps stage
COPY --from=deps /go/bin/docker-credential-ecr-login /usr/local/bin/

# Ensure the ECR Credential Helper binary is executable
RUN chmod +x /usr/local/bin/docker-credential-ecr-login

# Copy the entrypoint script
COPY dockerd-entrypoint.sh /usr/local/bin/dockerd-entrypoint.sh
RUN chmod +x /usr/local/bin/dockerd-entrypoint.sh

# Set the entrypoint to the new entrypoint script, and pass 'dockerd' as the default command
ENTRYPOINT ["/usr/local/bin/dockerd-entrypoint.sh", "dockerd"]

# Default CMD Command
CMD []
