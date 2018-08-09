# GRPC protoc compiler tools in Docker

This package contains Docker image with Go, [Node React Native GRPC Bridge](https://github.com/anjmao/rn-grpc-bridge), Swift GRPC protoc plugins.

### Docker

https://hub.docker.com/r/anjmao/grpc-tools/

### Local usage

See Makefile and example folder

```sh
make compile-go
make compile-swift
make compile-rn-bridge
```

### Docker image

Go

```sh
docker run \
    --rm \
    -v $(pwd)/proto:/proto \
    -v $(pwd)/.out:/.out \
    -w / \
    anjmao/grpc-tools \
    --proto_path /proto \
    --go_out=plugins=grpc:/.out myproto.proto
```

Swift

```sh
docker run \
    --rm \
    -v $(pwd)/proto:/proto \
    -v $(pwd)/.out:/.out \
    -w / \
    anjmao/grpc-tools \
    --proto_path /proto \
    --swift_out=/.out \
    --swiftgrpc_out=/.out \
    myproto.proto
```

React Native Swift Grpc Bridge
```sh
docker run \
    --rm \
    -v $(pwd)/proto:/proto \
    -v $(pwd)/.out:/.out \
    -w / \
    anjmao/grpc-tools \
    --proto_path /proto \
    --rn_out=/.out \
    --plugin=protoc-gen-rn=/node_modules/rn-grpc-bridge/bin/rn-grpc-bridge \
    myproto.proto
```

