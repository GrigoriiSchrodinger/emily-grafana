# Thanks: https://gist.github.com/mpneuried/0594963ad38e68917ef189b4e6a269db
.PHONY: help

help: ## This help.
	@awk 'BEGIN {FS = ":.*?## "} /^[a-zA-Z_-]+:.*?## / {printf "\033[36m%-30s\033[0m %s\n", $$1, $$2}' $(MAKEFILE_LIST)

.DEFAULT_GOAL := help

# Determine whether to use "docker-compose" or "docker compose"
DOCKER_COMPOSE := $(shell which docker-compose 2>/dev/null)
ifeq ($(DOCKER_COMPOSE),)
	DOCKER_COMPOSE := $(shell which docker 2>/dev/null)
	DOCKER_COMPOSE_CMD := compose
else
	DOCKER_COMPOSE_CMD := compose
endif

# DOCKER TASKS
up: ## Runs the containers in detached mode
	$(DOCKER_COMPOSE) $(DOCKER_COMPOSE_CMD) up -d

clean: ## Stops and removes all containers
	$(DOCKER_COMPOSE) $(DOCKER_COMPOSE_CMD) down

logs: ## View the logs from the containers
	$(DOCKER_COMPOSE) $(DOCKER_COMPOSE_CMD) logs -f

open: ## Opens tabs in container
	open http://localhost:3000/

build: ## Build Docker image
	docker build -t $(shell basename $(CURDIR)):latest .

deploy: ## Deploy to remote server
	docker save $(shell basename $(CURDIR)):latest | bzip2 | ssh -o StrictHostKeyChecking=no ${REMOTE_USER}@${REMOTE_HOST} 'bunzip2 | docker load'
	ssh -o StrictHostKeyChecking=no ${REMOTE_USER}@${REMOTE_HOST} '\
		REPO_NAME=$(shell basename $(CURDIR)); \
		docker volume create $$REPO_NAME_data || true; \
		docker stop $$REPO_NAME-container || true; \
		docker rm $$REPO_NAME-container || true; \
		docker run -d \
			--name $$REPO_NAME-container \
			-p 3000:3000 \
			-v $$REPO_NAME_data:/app/data \
			$$REPO_NAME:latest'
