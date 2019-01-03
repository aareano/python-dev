# Builds the dependencies packaged as a docker image
# Assumes docker is installed.  If not, go to: https://www.docker.com/products/overview

#                         #
# * * * environment * * * #
#                         #

DOCKER  := $(shell command -v docker 2> /dev/null)
VERSION := $(shell git rev-parse HEAD | tr -d '\n'; git diff-index -w --quiet HEAD -- || echo "-SNAPSHOT")

DOCKER_REGISTRY   := hub.docker.com
DOCKER_REPO       := repo
DOCKER_NAME       := app
DOCKER_TAG        := $(DOCKER_REGISTRY)/$(DOCKER_REPO)/$(DOCKER_NAME):$(VERSION)
DOCKER_TAG_LATEST := $(DOCKER_REGISTRY)/$(DOCKER_REPO)/$(DOCKER_NAME):latest

.PHONY: deps
deps:
ifndef DOCKER
	$(error 'docker' binary is not found; please install Docker, as the app is containerized for portability)
endif

.PHONY: envvars
envvars:
ifndef DOCKER_NAME
	$(error 'DOCKER_NAME' environment variable is undefined)
endif
ifndef DOCKER_REGISTRY
	$(error 'DOCKER_REGISTRY' environment variable is undefined)
endif
ifndef DOCKER_REPO
	$(error 'DOCKER_REPO' environment variable is undefined)
endif
ifndef VERSION
	$(error 'VERSION' environment variable is undefined)
endif

#                  #
# * * * help * * * #
#                  #

.PHONY: help
help:
	@echo
	@echo '  make build - build the docker image tagged with the latest commit hash'
	@echo '  make shell - open a shell in the container locally'
	@echo

#                     #
# * * * targets * * * #
#                     #

.PHONY: build
build: deps envvars
	docker build \
		-t $(DOCKER_TAG) \
		-t $(DOCKER_TAG_LATEST) \
		-f docker/Dockerfile .

.PHONY: notebook
notebook: deps envvars stop build
	docker run \
		-p 8888:8888 \
		-v $(PWD)/src:/app/src \
		-it $(DOCKER_TAG_LATEST) \
		jupyter notebook --ip=0.0.0.0 --port=8888

.PHONY: shell
shell: deps envvars stop build
	docker run \
		-v $(PWD)/src:/app/src \
		-it $(DOCKER_TAG_LATEST) \
		/bin/bash

.PHONY: stop
stop: deps envvars
	docker stop $(DOCKER_NAME) 2> /dev/null || true
	docker rm   $(DOCKER_NAME) 2> /dev/null || true
