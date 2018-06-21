# React Native | Node gRPC protoc compiler plugins

While developing react native and nodejs I found it difficult to gather all protoc plugins from different sources. This is why I created this repository which contains
contains common gRPC protoc compiler plugins binaries which can be downloaded via npm. Currently there is only OSX binaries. PR is welcome for Linux, Windows.

## OSX

1. protoc (v3.6.9)[https://github.com/google/protobuf/releases/tag/v3.6.0]
2. grpc_node_plugin (v1.6.6)[https://www.npmjs.com/package/grpc-tools/v/1.6.6]
3. protoc-gen-swift (v0.4.1)[https://github.com/grpc/grpc-swift/tree/0.4.1]
4. protoc-gen-swiftgrpc (v0.4.1)[protoc-gen-swiftgrpc]
5. node grpc typescript (here)[https://github.com/agreatfool/grpc_tools_node_protoc_ts]

## Usage

1. Install
```
yarn add grpc-plugins --dev
```

2. My typical use

```shell
#!/bin/bash

NODE_OUTDIR=./src/proto
RN_OUTDIR=./.rn-proto-out
BINPATH=./node_modules/grpc-plugins/osx
PROTOC=${BINPATH}/protoc

# cleanup current outdir
rm -rf ${NODE_OUTDIR}
mkdir ${NODE_OUTDIR}
rm -rf ${RN_OUTDIR}
mkdir ${RN_OUTDIR}

# nodejs proto and grpc
${PROTOC} \
--js_out=import_style=commonjs,binary:${NODE_OUTDIR} \
--grpc_out=${NODE_OUTDIR} \
--plugin=protoc-gen-grpc=${BINPATH}/grpc_node_plugin \
-I ./proto \
./proto/*.proto

# typescipt d.ts typings for node
${PROTOC} \
--plugin=protoc-gen-ts=./node_modules/.bin/protoc-gen-ts \
--ts_out=${NODE_OUTDIR} \
-I ./proto \
./proto/*.proto

# swift proto
${PROTOC} \
--swift_out=${RN_OUTDIR} \
--plugin=protoc-gen-grpc=${BINPATH}/protoc-gen-swift \
-I ./proto \
./proto/*.proto

# swift gRPC
${PROTOC} \
--swiftgrpc_out=${RN_OUTDIR} \
--plugin=protoc-gen-swiftgrpc=${BINPATH}/protoc-gen-swiftgrpc \
-I ./proto \
./proto/*.proto

```