FROM --platform=$BUILDPLATFORM golang:1.26.3-alpine@sha256:91eda9776261207ea25fd06b5b7fed8d397dd2c0a283e77f2ab6e91bfa71079d AS builder

ARG TARGETARCH
WORKDIR /app
COPY go.mod go.sum wait-for.go ./
RUN CGO_ENABLED=0 GOOS=linux GOARCH=${TARGETARCH} go build -o wait-for .

FROM alpine:3.24@sha256:be2656061b536c1883c4034790e21d0a09c5aaaf51968b89368a3c0371ea2c9a

LABEL maintainer="ownCloud GmbH <devops@owncloud.com>"
LABEL org.opencontainers.image.authors="ownCloud DevOps <devops@owncloud.com>"
LABEL org.opencontainers.image.title="ownCloud CI wait-for"
LABEL org.opencontainers.image.url="https://hub.docker.com/r/owncloudci/wait-for"
LABEL org.opencontainers.image.source="https://github.com/owncloud-ci/wait-for"
LABEL org.opencontainers.image.documentation="https://github.com/owncloud-ci/wait-for"

COPY --from=builder /app/wait-for /usr/bin/wait-for
ENTRYPOINT ["wait-for"]
