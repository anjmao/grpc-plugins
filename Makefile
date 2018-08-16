.PHONY: build push compile-go compile-swift compile-rn-bridge

PROTO_INPUT := ./example/proto ./example/proto/debug.proto
DOCKER_USERNAME := anjmao
IMAGE_NAME := $(DOCKER_USERNAME)/grpc-tools
VERSION := 1.0.6

build:
	@docker build -t $(IMAGE_NAME) .

push:
	git tag $(VERSION)
	@docker tag $(IMAGE_NAME) $(IMAGE_NAME):$(VERSION)
	@docker push $(IMAGE_NAME):$(VERSION)
	@docker tag $(IMAGE_NAME) $(IMAGE_NAME):latest
	@docker push $(IMAGE_NAME):latest
	git push && git push --tags

compile-go:
	@docker run \
	--rm \
	-v "$$(pwd):$$(pwd)" \
	-w "$$(pwd)" \
	$(IMAGE_NAME) \
	--go_out=plugins=grpc:./example/out \
	-I $(PROTO_INPUT)

compile-swift:
	@docker run \
	--rm \
	-v "$$(pwd):$$(pwd)" \
	-w "$$(pwd)" \
	$(IMAGE_NAME) \
	--swift_out=./example/out \
	--swiftgrpc_out=./example/out \
	-I $(PROTO_INPUT)

compile-rn-bridge:
	@docker run \
	--rm \
	-v "$$(pwd):$$(pwd)" \
	-w "$$(pwd)" \
	$(IMAGE_NAME) \
	--rn_out=./example/out \
	--plugin=protoc-gen-rn=/node_modules/rn-grpc-bridge/bin/rn-grpc-bridge \
	-I $(PROTO_INPUT)