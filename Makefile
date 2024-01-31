SHELL := /bin/bash

.PHONY: help
help:
	@cat $(MAKEFILE_LIST) | grep -E "^[^[:space:]]*: *.*## *" | awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m%-30s\033[0m %s\n", $$1, $$2}'

init: ## Run this initially to setup the project
	flutter packages pub global activate webdev

local-run: ## Run the flutter app locally
	webdev serve --auto restart

docker-build: ## Create topics required for KSQL tables
	docker build . -t flutter_docker

docker-run: ## Run on docker
	docker run -i -p 8080:9000 -td --name flutter_docker flutter_docker

docker-stop: ## Stop run on docker
	docker stop flutter_docker

docker-clean: ## Clean the image on docker 
	docker rm flutter_docker
