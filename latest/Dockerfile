FROM --platform=$BUILDPLATFORM golang:1.25-alpine AS builder

ARG TARGETARCH
WORKDIR /app
COPY go.mod go.sum wait-for.go ./
RUN CGO_ENABLED=0 GOOS=linux GOARCH=${TARGETARCH} go build -o wait-for .

FROM alpine:3.23@sha256:25109184c71bdad752c8312a8623239686a9a2071e8825f20acb8f2198c3f659

LABEL maintainer="ownCloud GmbH <devops@owncloud.com>"
LABEL org.opencontainers.image.authors="ownCloud DevOps <devops@owncloud.com>"
LABEL org.opencontainers.image.title="ownCloud CI wait-for"
LABEL org.opencontainers.image.url="https://hub.docker.com/r/owncloudci/wait-for"
LABEL org.opencontainers.image.source="https://github.com/owncloud-ci/wait-for"
LABEL org.opencontainers.image.documentation="https://github.com/owncloud-ci/wait-for"

COPY --from=builder /app/wait-for /usr/bin/wait-for
ENTRYPOINT ["wait-for"]
