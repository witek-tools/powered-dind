# Stage 1: Use the base Alpine image with Go 1.22 to build the ECR Credential Helper
FROM golang:1.22-alpine3.19 AS ecr-helper

# Set the working directory inside the container
WORKDIR /usr/src/app

# Install the Amazon ECR Credential Helper
RUN go install github.com/awslabs/amazon-ecr-credential-helper/ecr-login/cli/docker-credential-ecr-login@latest

# Stage 2: Node.js with pnpm stage
FROM node:20.15.1-alpine AS node-base

# Set the working directory for Node.js environment
WORKDIR /usr/src/app

# Enable Corepack (comes pre-installed with Node.js 20)
RUN corepack enable

# Install a specific version of pnpm globally
RUN corepack prepare pnpm@9.7.1 --activate

# Stage 3: Final stage with Docker-in-Docker (DinD), pnpm, ECR Helper, Git, and buildx support
FROM docker:23.0.6-dind-alpine3.18 AS runner

# Set the working directory
WORKDIR /usr/src/app

# Install bash, Docker CLI utilities, Git, and enable buildx
RUN apk update && apk add --no-cache bash docker-cli git qemu curl

# Enable Docker BuildKit and buildx without depending on Docker daemon
RUN mkdir -p ~/.docker/cli-plugins/ \
  && curl -L https://github.com/docker/buildx/releases/download/v0.8.2/buildx-v0.8.2.linux-amd64 -o ~/.docker/cli-plugins/docker-buildx \
  && chmod +x ~/.docker/cli-plugins/docker-buildx

# Export environment variables to enable BuildKit and buildx
ENV DOCKER_CLI_EXPERIMENTAL=enabled
ENV DOCKER_BUILDKIT=1

# Copy pnpm and Node.js setup from the node-base stage
COPY --from=node-base /usr/local/bin/ /usr/local/bin/
COPY --from=node-base /usr/lib/ /usr/lib/
COPY --from=node-base /usr/src/app/ /usr/src/app/

# Copy the ECR Credential Helper binary from the ecr-helper stage
COPY --from=ecr-helper /go/bin/docker-credential-ecr-login /usr/local/bin/

# Ensure the ECR Credential Helper binary is executable
RUN chmod +x /usr/local/bin/docker-credential-ecr-login

# Copy the entrypoint script
COPY entrypoint.sh /usr/local/bin/entrypoint.sh
RUN chmod +x /usr/local/bin/entrypoint.sh

# Set the entrypoint to the script
ENTRYPOINT ["/usr/local/bin/entrypoint.sh"]

# Set the default command to start the Docker daemon
CMD ["dockerd-entrypoint.sh"]
