# Name of the service used in Docker Compose
SERVICE_NAME=powered-dind

# Centralized command to run Docker Compose with BuildKit enabled
DOCKER_COMPOSE=DOCKER_BUILDKIT=1 docker compose -f docker-compose.yml

# Command to bring up the container and rebuild the image
up:
	$(DOCKER_COMPOSE) up --remove-orphans --build -d

# Command to stop the containers
down:
	$(DOCKER_COMPOSE) down

# Command to restart the containers (stop and start with build)
restart:
	$(DOCKER_COMPOSE) down && $(DOCKER_COMPOSE) up --remove-orphans --build -d

# Command to enter the container directly, with wait logic
shell:
	@echo "Waiting for container to be running..."
	@while [ "$$($(DOCKER_COMPOSE) ps -q $(SERVICE_NAME) | xargs docker inspect -f '{{.State.Status}}')" != "running" ]; do \
		echo "Container is not ready, waiting..."; \
		sleep 1; \
	done
	$(DOCKER_COMPOSE) exec $(SERVICE_NAME) /bin/bash

.PHONY: up down restart shell
