def main(ctx):
    versions = [
        "latest",
    ]

    arches = [
        "amd64",
        "arm64v8",
    ]

    # https://github.com/golang/go/blob/master/src/go/build/syslist.go
    binaryTargets = {
        "linux": [
            "amd64",
            "arm64",
        ],
    }

    config = {
        "version": None,
        "arch": None,
        "repo": ctx.repo.name,
        "description": "Wait-for services in ownCloud CI",
    }

    stages = []

    for version in versions:
        config["version"] = version

        if config["version"] == "latest":
            config["path"] = "latest"
        else:
            config["path"] = "v%s" % config["version"]

        m = manifest(config)
        inner = []

        for arch in arches:
            config["arch"] = arch

            if config["version"] == "latest":
                config["tag"] = arch
            else:
                config["tag"] = "%s-%s" % (config["version"], arch)

            if config["arch"] == "amd64":
                config["platform"] = "amd64"

            if config["arch"] == "arm64v8":
                config["platform"] = "arm64"

            config["internal"] = "%s-%s" % (ctx.build.commit, config["tag"])

            d = docker(config)
            m["depends_on"].append(d["name"])

            inner.append(d)

        inner.append(m)
        stages.extend(inner)

    stages = stages + [binaryReleases(ctx, binaryTargets)]

    after = [
        documentation(config),
        notification(config),
    ]

    for s in stages:
        for a in after:
            a["depends_on"].append(s["name"])

    return stages + after

def docker(config):
    return {
        "kind": "pipeline",
        "type": "docker",
        "name": "%s-%s" % (config["arch"], config["path"]),
        "platform": {
            "os": "linux",
            "arch": config["platform"],
        },
        "steps": steps(config),
        "depends_on": [],
        "trigger": {
            "ref": [
                "refs/heads/master",
                "refs/tags/**",
                "refs/pull/**",
            ],
        },
    }

def manifest(config):
    return {
        "kind": "pipeline",
        "type": "docker",
        "name": "manifest-%s" % config["path"],
        "platform": {
            "os": "linux",
            "arch": "amd64",
        },
        "steps": [
            {
                "name": "manifest",
                "image": "plugins/manifest",
                "settings": {
                    "username": {
                        "from_secret": "public_username",
                    },
                    "password": {
                        "from_secret": "public_password",
                    },
                    "spec": "%s/manifest.tmpl" % config["path"],
                    "ignore_missing": "true",
                },
            },
        ],
        "depends_on": [],
        "trigger": {
            "ref": [
                "refs/heads/master",
                "refs/tags/**",
            ],
        },
    }

def documentation(config):
    return {
        "kind": "pipeline",
        "type": "docker",
        "name": "documentation",
        "platform": {
            "os": "linux",
            "arch": "amd64",
        },
        "steps": [
            {
                "name": "link-check",
                "image": "ghcr.io/tcort/markdown-link-check:3.11.0",
                "commands": [
                    "/src/markdown-link-check README.md",
                ],
            },
            {
                "name": "publish",
                "image": "chko/docker-pushrm:1",
                "environment": {
                    "DOCKER_PASS": {
                        "from_secret": "public_password",
                    },
                    "DOCKER_USER": {
                        "from_secret": "public_username",
                    },
                    "PUSHRM_FILE": "README.md",
                    "PUSHRM_TARGET": "owncloudci/${DRONE_REPO_NAME}",
                    "PUSHRM_SHORT": config["description"],
                },
                "when": {
                    "ref": [
                        "refs/heads/master",
                    ],
                },
            },
        ],
        "depends_on": [],
        "trigger": {
            "ref": [
                "refs/heads/master",
                "refs/tags/**",
                "refs/pull/**",
            ],
        },
    }

def notification(config):
    steps = [{
        "name": "notify",
        "image": "plugins/slack",
        "settings": {
            "webhook": {
                "from_secret": "rocketchat_chat_webhook",
            },
            "channel": "builds",
        },
        "when": {
            "status": [
                "success",
                "failure",
            ],
        },
    }]

    return {
        "kind": "pipeline",
        "type": "docker",
        "name": "notification",
        "platform": {
            "os": "linux",
            "arch": "amd64",
        },
        "clone": {
            "disable": True,
        },
        "steps": steps,
        "depends_on": [],
        "trigger": {
            "ref": [
                "refs/heads/master",
                "refs/tags/**",
            ],
            "status": [
                "success",
                "failure",
            ],
        },
    }

def copysrc(config):
    return [{
        "name": "copy source",
        "image": "owncloudci/alpine",
        "commands": [
            "mkdir -p %s/src" % (config["path"]),
            "cp wait-for.go %s/src" % (config["path"]),
            "cp go.mod %s/src" % (config["path"]),
            "cp go.sum %s/src" % (config["path"]),
        ],
    }]

def dryrun(config):
    return [{
        "name": "dryrun",
        "image": "plugins/docker",
        "settings": {
            "dry_run": True,
            "tags": config["tag"],
            "dockerfile": "%s/Dockerfile.%s" % (config["path"], config["arch"]),
            "repo": "owncloudci/%s" % config["repo"],
            "context": config["path"],
        },
        "when": {
            "ref": [
                "refs/pull/**",
            ],
        },
    }]

def publish(config):
    return [{
        "name": "publish",
        "image": "plugins/docker",
        "settings": {
            "username": {
                "from_secret": "public_username",
            },
            "password": {
                "from_secret": "public_password",
            },
            "tags": config["tag"],
            "dockerfile": "%s/Dockerfile.%s" % (config["path"], config["arch"]),
            "repo": "owncloudci/%s" % config["repo"],
            "context": config["path"],
            "pull_image": False,
        },
        "when": {
            "ref": [
                "refs/heads/master",
                "refs/tags/**",
            ],
        },
    }]

def binaryReleases(ctx, binaryTargets):
    build_steps = []
    for os in binaryTargets:
        for arch in binaryTargets[os]:
            build_steps.append(binaryReleaseStep(ctx, os, arch))

    pipeline = {
        "kind": "pipeline",
        "type": "docker",
        "name": "binaries-release",
        "platform": {
            "os": "linux",
            "arch": "amd64",
        },
        "steps": build_steps + [
            {
                "name": "release",
                "image": "plugins/github-release:1",
                "pull": "always",
                "settings": {
                    "api_key": {
                        "from_secret": "github_token",
                    },
                    "files": [
                        "bin/*",
                    ],
                    "title": ctx.build.ref.replace("refs/tags/v", ""),
                    "overwrite": True,
                    "prerelease": len(ctx.build.ref.split("-")) > 1,
                },
                "when": {
                    "ref": [
                        "refs/tags/v*",
                    ],
                },
            },
        ],
        "depends_on": [],
        "trigger": {
            "ref": [
                "refs/heads/master",
                "refs/tags/v*",
                "refs/pull/**",
            ],
        },
    }
    return pipeline

def binaryReleaseStep(ctx, os, arch):
    return {
        "name": "binaries-%s-%s" % (os, arch),
        "image": "owncloudci/golang:1.19",
        "pull": "always",
        "commands": [
            "GOOS=%s GOARCH=%s CGO_ENABLED=0 go build -o bin/wait-for-%s-%s ." % (os, arch, os, arch),
        ],
        "when": {
            "ref": [
                "refs/heads/master",
                "refs/tags/v*",
                "refs/pull/**",
            ],
        },
    }

def steps(config):
    return copysrc(config) + dryrun(config) + publish(config)
