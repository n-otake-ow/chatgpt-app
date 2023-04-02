include .env

SERVICE_NAME := chatgpt-app
SERVER_IMAGE_NAME := app
IMAGE_URL := $(GAR_HOST)/$(PROJECT_ID)/$(SERVICE_NAME)/$(SERVER_IMAGE_NAME)
.DEFAULT_GOAL   := help


.PHONY: build
build:
	$(eval COMMIT_HASH := $(shell git rev-parse HEAD | cut -c 1-7))
	DOCKER_BUILDKIT=1 docker build \
		-f .docker/Dockerfile \
		-t $(SERVICE_NAME)-$(SERVER_IMAGE_NAME) \
		-t $(IMAGE_URL):latest \
		-t $(IMAGE_URL):$(COMMIT_HASH) \
		.

.PHONY: push
push:
	$(eval COMMIT_HASH := $(shell git rev-parse HEAD | cut -c 1-7))
	@docker push $(IMAGE_URL):latest
	@docker push $(IMAGE_URL):$(COMMIT_HASH)

.PHONY: deploy
deploy:
	gcloud run deploy $(SERVICE_NAME) --image $(IMAGE_URL) --region $(LOCATION)

.PHONY: describe
describe:
	gcloud run services describe $(SERVICE_NAME)  --region=$(LOCATION)

.PHONY: up
up:
	docker compose -f .docker/docker-compose.yml up -d

.PHONY: down
down:
	docker compose -f .docker/docker-compose.yml down --remove-orphans

.PHONY: clean
clean: down up

.PHONY: log
log:
	docker compose -f .docker/docker-compose.yml logs -f || true

.PHONY: start
start:
	docker compose -f .docker/docker-compose.yml start

.PHONY: stop
stop:
	docker compose -f .docker/docker-compose.yml stop

.PHONY: restart
restart: stop start

.PHONY: login-app
login-app:
	docker compose -f .docker/docker-compose.yml exec app /bin/bash

.PHONY: help
help:
	@echo "Usage: make [target]"