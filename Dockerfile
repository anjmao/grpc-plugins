FROM swift:latest as all_builder

ENV PROTOC_VERSION=3.6.1 \
    GO_VERSION=1.10.3

RUN apt-get -q update \
    && apt-get -q install -y unzip \
    && rm -r /var/lib/apt/lists/*

# Build and install the swiftgrpc plugin
RUN git clone https://github.com/grpc/grpc-swift \
    && cd grpc-swift \
    && git checkout tags/0.5.0 \
    && make \
    && cp protoc-gen-swift protoc-gen-swiftgrpc /usr/bin/ \
    && cd / \
    && rm -rf grpc-swift

# Install protoc
RUN curl -O -L https://github.com/google/protobuf/releases/download/v${PROTOC_VERSION}/protoc-${PROTOC_VERSION}-linux-x86_64.zip \
    && unzip protoc-${PROTOC_VERSION}-linux-x86_64.zip -d /usr \
    && rm -rf protoc-${PROTOC_VERSION}-linux-x86_64.zip

# Install go
RUN curl -L https://dl.google.com/go/go${GO_VERSION}.linux-amd64.tar.gz --output go.tar.gz && \
    tar -xvzf go.tar.gz && \
    rm -rf go.tar.gz

ENV GOPATH=/root/go \
    GOROOT=/go \
    PATH=/go/bin:/root/go/bin:$PATH

# Install go protoc
RUN go get -u github.com/golang/protobuf/protoc-gen-go

# Install common protobuf types
RUN mkdir -p /protobuf/google/protobuf && \
        for f in any duration descriptor empty struct timestamp wrappers; do \
            curl -L -o /protobuf/google/protobuf/${f}.proto https://raw.githubusercontent.com/google/protobuf/master/src/google/protobuf/${f}.proto; \
        done && \
    mkdir -p /protobuf/google/api && \
        for f in annotations http; do \
            curl -L -o /protobuf/google/api/${f}.proto https://raw.githubusercontent.com/grpc-ecosystem/grpc-gateway/master/third_party/googleapis/google/api/${f}.proto; \
        done

# Install rn-grpc-bridge node npm package
FROM node:8.11.3 as node_js
RUN npm install -g rn-grpc-bridge

 # Main protoc image
FROM ubuntu:16.04

RUN apt-get update && apt-get install -y curl

# Install nodejs
RUN curl -sL https://deb.nodesource.com/setup_8.x | bash - && \
    apt-get install -y nodejs

COPY --from=all_builder /usr/bin/curl /usr/bin/
COPY --from=all_builder /usr/bin/protoc* /usr/bin/
COPY --from=all_builder /root/go/bin/protoc* /usr/bin/
COPY --from=all_builder /protobuf/ /protobuf/
COPY --from=all_builder /usr/lib/swift/ /usr/lib/swift/
COPY --from=all_builder /usr/lib/x86_64-linux-gnu/ /usr/lib/x86_64-linux-gnu/
COPY --from=all_builder /lib/x86_64-linux-gnu/ /lib/x86_64-linux-gnu/
COPY --from=node_js /usr/local/lib/node_modules/rn-grpc-bridge/ /node_modules/rn-grpc-bridge/

ENV GOPATH=/root/go \
    GOROOT=/go \
    PATH=/go/bin:/root/go/bin:$PATH

ENTRYPOINT ["/usr/bin/protoc", "-I/protobuf"]