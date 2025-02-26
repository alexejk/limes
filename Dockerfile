FROM golang:1.19.4-alpine

# Build dependencies
RUN apk --no-cache add alpine-sdk protobuf
RUN go install google.golang.org/protobuf/cmd/protoc-gen-go@v1.27.1
RUN go install google.golang.org/grpc/cmd/protoc-gen-go-grpc@v1.1.0

WORKDIR /src

# Copy over dependency file and download it if files changed
# This allows build caching and faster re-builds
COPY go.mod  .
COPY go.sum  .
RUN go mod download

# Add rest of the source and build
COPY . .
RUN make all

# Copy to /opt/ so we can extract files later
RUN cp build/* /opt/

