
APP_NAME=jira-clone
TAG ?= $(git rev-parse --short HEAD)

.PHONY: build build-migrate run-migrate 

build:
	docker build -f Dockerfile -t ${APP_NAME}:latest .

build-migrate:
	docker build -f Dockerfile.migrate -t ${APP_NAME}-migrate:latest .

run-migrate:
	docker run --rm --env-file .env ${APP_NAME}-migrate:latest

ecr-build:
	docker build -f Dockerfile -t $(APP_NAME):$(TAG) .