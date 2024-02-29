default:
	@echo No.

build: Dockerfile
	@docker build -t gus-apidb-base:latest --build-arg=GITHUB_USERNAME=${GITHUB_USERNAME} --build-arg=GITHUB_TOKEN=${GITHUB_TOKEN} .

run:
	@docker run -it --rm gus-apidb-base:latest
