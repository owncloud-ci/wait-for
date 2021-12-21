# Wait-for services in ownCloud CI

[![Build Status](https://img.shields.io/drone/build/owncloud-ci/wait-for?logo=drone&server=https%3A%2F%2Fdrone.owncloud.com)](https://drone.owncloud.com/owncloud-ci/wait-for)
[![Docker Hub](https://img.shields.io/docker/v/owncloudci/wait-for?logo=docker&label=dockerhub&sort=semver&logoColor=white)](https://hub.docker.com/r/owncloudci/wait-for)
[![GitHub contributors](https://img.shields.io/github/contributors/owncloud-ci/wait-for)](https://github.com/owncloud-ci/wait-for/graphs/contributors)
[![Source: GitHub](https://img.shields.io/badge/source-github-blue.svg?logo=github&logoColor=white)](https://github.com/owncloud-ci/wait-for)
[![License: MIT](https://img.shields.io/github/license/owncloud-ci/wait-for)](https://github.com/owncloud-ci/wait-for/blob/master/LICENSE)

A small tool to test and wait on the availability of a TCP host and port.

## Quick reference

- **Usage:**

```bash
wait-for:
  -it value
        <host:port> [host2:port,...] comma separated list of services
  -t int
        timeout (default 20)
```

- **Where to file issues:**\
  [owncloud-ci/wait-for](https://github.com/owncloud-ci/wait-for/issues)

- **Supported architectures:**\
  `amd64`, `arm32v7`, `arm64v8`

## Docker Tags and respective Dockerfile links

- [`latest`](https://github.com/owncloud-ci/wait-for/blob/master/latest/Dockerfile.amd64) available as `owncloudci/wait-for:latest`

## Default volumes

None

## Exposed ports

None

## Environment variables

None

## License

This project is licensed under the GNU General Public License v3.0 - see the [LICENSE](https://github.com/owncloud-ci/alpine/blob/master/LICENSE) file for details.

## Copyright

```Text
Copyright (c) 2022 ownCloud GmbH
```
