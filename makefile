default:
	@echo No.

build: Dockerfile
	@docker build -t gus-apidb-base:latest .

run:
	@docker run -it --rm gus-apidb-base:latest
