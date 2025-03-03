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

up: ## Runs the containers in detached mode
	$(DOCKER_COMPOSE) $(DOCKER_COMPOSE_CMD) up -d

clean: ## Stops and removes all containers
	$(DOCKER_COMPOSE) $(DOCKER_COMPOSE_CMD) down

logs: ## View the logs from the containers
	$(DOCKER_COMPOSE) $(DOCKER_COMPOSE_CMD) logs -f

open: ## Opens tabs in container
	open http://localhost:3000/
