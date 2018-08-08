.PHONY: build run compile-swift

PROTO_INPUT := ./example/proto ./example/proto/debug.proto

build:
	@docker build -t protoc .

compile-go:
	@docker run \
	--rm \
	-v "$$(pwd):$$(pwd)" \
	-w "$$(pwd)" \
	protoc --go_out=plugins=grpc:./example/out -I $(PROTO_INPUT)

compile-swift:
	@docker run \
	--rm \
	-v "$$(pwd):$$(pwd)" \
	-w "$$(pwd)" \
	protoc \
	--swift_out=./example/out \
	--swiftgrpc_out=./example/out \
	-I $(PROTO_INPUT) \