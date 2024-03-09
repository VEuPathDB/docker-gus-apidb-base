MAKEFLAGS += -rR --silent

# # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # #
#
#  Miscelaneous vars and targets
#
# # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # #

.PHONY: FORCE
FORCE:


# # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # #
#
#  Golang based tool compilation
#
# # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # #

GO_TOOLS = $(subst /go.mod,,$(wildcard */go.mod))
GO_BUILD_DIR = bin

.PHONY: build-go-tools
build-go-tools: $(addprefix bin/,$(GO_TOOLS))

bin/%: FORCE
	mkdir -p bin ; rm -f $@ ; echo "Building $(@F)"
	$(MAKE) -C $(@F) clean test build
	mv $(@F)/build/$(@F) bin/
