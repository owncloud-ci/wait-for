FROM --platform=$BUILDPLATFORM golang:1.27.1-alpine@sha256:8a5910f31396cd4d89662f56c68b3ae31d374308270a1c3bd96672ee5ed43414 AS builder

ARG TARGETARCH
WORKDIR /app
COPY go.mod go.sum wait-for.go ./
RUN CGO_ENABLED=0 GOOS=linux GOARCH=${TARGETARCH} go build -o wait-for .

FROM alpine:3.23@sha256:5b10f432ef3da1b8d4c7eb6c487f2f5a8f096bc91145e68878dd4a5019afde11

LABEL maintainer="ownCloud GmbH <devops@owncloud.com>"
LABEL org.opencontainers.image.authors="ownCloud DevOps <devops@owncloud.com>"
LABEL org.opencontainers.image.title="ownCloud CI wait-for"
LABEL org.opencontainers.image.url="https://hub.docker.com/r/owncloudci/wait-for"
LABEL org.opencontainers.image.source="https://github.com/owncloud-ci/wait-for"
LABEL org.opencontainers.image.documentation="https://github.com/owncloud-ci/wait-for"

COPY --from=builder /app/wait-for /usr/bin/wait-for
ENTRYPOINT ["wait-for"]
