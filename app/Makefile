include .env

SERVICE_NAME := chatgpt-app
SERVER_IMAGE_NAME := app
PROJECT_ID := $(shell gcloud config get-value project)
IMAGE_URL := $(GAR_HOST)/$(PROJECT_ID)/$(SERVICE_NAME)/$(SERVER_IMAGE_NAME)
COMMIT_HASH := $(shell git rev-parse --short HEAD)
.DEFAULT_GOAL   := help


.PHONY: lint
lint:
	@flake8 src/

.PHONY: fmt
fmt:
	@black src/
	@flake8 src/

.PHONY: build
build:
	docker build \
		-f .docker/Dockerfile \
		-t $(SERVICE_NAME) \
		-t $(IMAGE_URL):latest \
		-t $(IMAGE_URL):$(COMMIT_HASH) \
		.

.PHONY: push
push:
	@docker push $(IMAGE_URL):latest
	@docker push $(IMAGE_URL):$(COMMIT_HASH)

.PHONY: prune
prune:
	gcloud artifacts docker images list "$(GAR_HOST)/$(PROJECT_ID)/$(SERVICE_NAME)" --include-tags --filter="NOT tags~latest" \
	| awk '{print $$1 ":" $$3}' \
	| xargs -I {} gcloud artifacts docker images delete {} 2>/dev/null

.PHONY: deploy
deploy:
	gcloud run deploy $(SERVICE_NAME) --image $(IMAGE_URL) --region $(LOCATION)

.PHONY: release
release: build push deploy

.PHONY: describe
describe:
	gcloud run services describe $(SERVICE_NAME)  --region=$(LOCATION)

.PHONY: login-gcloud
login-gcloud:
	gcloud auth application-default login

.PHONY: up
up:
	docker compose -f .docker/docker-compose.yml up -d

.PHONY: down
down:
	docker compose -f .docker/docker-compose.yml down

.PHONY: clean
clean: down up

.PHONY: logs
logs:
	docker compose -f .docker/docker-compose.yml logs -f || true

.PHONY: login-app
login-app:
	docker compose -f .docker/docker-compose.yml exec app /bin/bash

.PHONY: help
help:
	@echo "Usage: make [target]"
