.PHONY: build
build: clean
	@mkdir -p build
	@env CGO_ENABLED=0 GOOS=linux GOARCH=amd64 go build -o build/process-nf-result .

.PHONY: clean
clean:
	@rm -rf build

.PHONY: test
test:
	@go test ./...
