FROM swift:latest

ENV PROTOC_VERSION=3.5.1

RUN apt-get -q update \
    && apt-get -q install -y unzip \
    && rm -r /var/lib/apt/lists/*

# Build and install the swiftgrpc plugin
RUN git clone https://github.com/grpc/grpc-swift \
    && cd grpc-swift \
    && make \
    && cp protoc-gen-swift protoc-gen-swiftgrpc /usr/bin/ \
    && cd / \
    && rm -rf grpc-swift

RUN apt-get -q update \
    && apt-get -q install -y unzip curl git \
    && rm -r /var/lib/apt/lists/*


# Install protoc
RUN curl -O -L https://github.com/google/protobuf/releases/download/v${PROTOC_VERSION}/protoc-${PROTOC_VERSION}-linux-x86_64.zip \
    && unzip protoc-${PROTOC_VERSION}-linux-x86_64.zip -d /usr \
    && rm -rf protoc-${PROTOC_VERSION}-linux-x86_64.zip

# Install go
RUN curl -L https://dl.google.com/go/go1.10.3.linux-amd64.tar.gz --output go.tar.gz && \
    tar -xvzf go.tar.gz

ENV GOPATH=/root/go \
    PATH=/go/bin:/root/go/bin:$PATH

# Install go protoc
RUN go get -u github.com/golang/protobuf/protoc-gen-go

RUN mkdir -p /protobuf/google/protobuf && \
        for f in any duration descriptor empty struct timestamp wrappers; do \
            curl -L -o /protobuf/google/protobuf/${f}.proto https://raw.githubusercontent.com/google/protobuf/master/src/google/protobuf/${f}.proto; \
        done && \
    mkdir -p /protobuf/google/api && \
        for f in annotations http; do \
            curl -L -o /protobuf/google/api/${f}.proto https://raw.githubusercontent.com/grpc-ecosystem/grpc-gateway/master/third_party/googleapis/google/api/${f}.proto; \
        done && \
    mkdir -p /protobuf/github.com/gogo/protobuf/gogoproto && \
        curl -L -o /protobuf/github.com/gogo/protobuf/gogoproto/gogo.proto https://raw.githubusercontent.com/gogo/protobuf/master/gogoproto/gogo.proto

ENTRYPOINT ["/usr/bin/protoc", "-I/protobuf"]