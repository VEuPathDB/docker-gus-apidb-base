CONTAINER_CMD := $(shell if command -v podman 2>&1 >/dev/null; then echo podman; else echo docker; fi)

default:
	@echo No.

build: Dockerfile
	@$(CONTAINER_CMD) build -t gus-apidb-base:latest --build-arg=GITHUB_USERNAME=${GITHUB_USERNAME} --build-arg=GITHUB_TOKEN=${GITHUB_TOKEN} .

run:
	@$(CONTAINER_CMD) run -it --rm gus-apidb-base:latest
