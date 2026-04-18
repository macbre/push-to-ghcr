# push-to-ghcr

This action simplifies pushes of container images to [the GitHub Containers Registry at ghcr.io](https://docs.github.com/en/packages/working-with-a-github-packages-registry/working-with-the-container-registry).

`Dockerfile` from your repository is build and published on:

* `release` event (releases named `vx.y.z`) your image will be tagged with `x.y.z`
* `push` event your image will be tagged with `latest`

Additionally, this action will also **automatically lowercase the repository name** to be able to push an image to the repository.

This action also **supports [multi-tagging](https://github.com/macbre/push-to-ghcr/issues/50) of image and [multi-platform builds](https://docs.docker.com/build/building/multi-platform/)**.

### Private containers

Images built for private repositories will be published as private containers to ghcr.io. Please refer to [GitHub's documentation on how to set up access](https://docs.github.com/en/packages/working-with-a-github-packages-registry/working-with-the-container-registry#authenticating-to-the-container-registry) to them via [personal access token (also known as PAT)](https://docs.github.com/en/github/authenticating-to-github/keeping-your-account-and-data-secure/creating-a-personal-access-token). PAT can be [created in "Developer settings" panel](https://github.com/settings/tokens).

## How to use it?

Create a new GitHub Actions workflow as follows:

```yaml
name: Build and publish a Docker image to ghcr.io
on:

  # publish on releases, e.g. v2.1.13 (image tagged as "2.1.13" - "v" prefix is removed)
  release:
    types: [ published ]

  # publish on pushes to the main branch (image tagged as "latest")
  push:
    branches:
      - master

jobs:
  docker_publish:
    runs-on: "ubuntu-20.04"

    steps:
      - uses: actions/checkout@v2

      # https://github.com/marketplace/actions/push-to-ghcr
      - name: Build and publish a Docker image for ${{ github.repository }}
        uses: macbre/push-to-ghcr@master
        with:
          image_name: ${{ github.repository }}  # it will be lowercased internally
          github_token: ${{ secrets.GITHUB_TOKEN }}
          # optionally push to the Docker Hub (docker.io)
          # docker_io_token: ${{ secrets.DOCKER_IO_ACCESS_TOKEN }}  # see https://hub.docker.com/settings/security
          # customize the username to be used when pushing to the Docker Hub
          # docker_io_user: foobar  # see https://github.com/macbre/push-to-ghcr/issues/14
```

This action assumes that your **`Dockerfile` is in the root directory of your repository**.

However, you can use `dockerfile` input to **specify a different path** (relative to the root directory of your repository). Additionaly, `context` input can also be provided. [Docker docs should provide more context on `context` ;)](https://docs.docker.com/engine/reference/commandline/build/).

## Input parameters

* `github_token` (**required**): Your `secrets.GITHUB_TOKEN`
* `image_name` (**required**): Image name, e.g. `my-user-name/my-repo` (will be lowercased internally)
* `dockerfile` (defaults to `./Dockerfile`): A path to the Dockerfile (if it's not in the repository's root directory)
* `context` (defaults to `.`): A path to the context in which the build will happen, see https://docs.docker.com/engine/reference/commandline/build/
* `repository` (defaults to `ghcr.io`): containers repository to push an image to
* `docker_io_user`: A username to use when pushing an image to `docker.io` (defaults to the `github.actor`)
* `docker_io_token`: Your `docker.io` token created via https://hub.docker.com/settings/security
* `image_tag`: Image tag or tags, e.g. `latest` or `1.0.0,latest`. Will overwrite the latest tag on a push, and have no effect on a release. Only tag names are accepted, not full image references.
* `platforms`: image will be built (and pushed) for different operating system or CPU architecture combinations (e.g. `linux/amd64,linux/arm64,linux/arm/v7`)
* `extra_args`: additional arguments to pass to `docker build`. Tags added with `extra_args` are local build tags; use `image_tag` to publish multiple tags.

### Publishing multiple tags

For non-release events, `image_tag` can be a single tag, a comma-separated list, or a newline-separated list:

```yaml
      - name: Build and publish a Docker image for ${{ github.repository }}
        uses: macbre/push-to-ghcr@master
        with:
          image_name: ${{ github.repository }}
          github_token: ${{ secrets.GITHUB_TOKEN }}
          image_tag: 1.0.0,latest
```

```yaml
      - name: Build and publish a Docker image for ${{ github.repository }}
        uses: macbre/push-to-ghcr@master
        with:
          image_name: ${{ github.repository }}
          github_token: ${{ secrets.GITHUB_TOKEN }}
          image_tag: |
            1.0.0
            latest
```

### [Multi-platform builds]([https://docs.docker.com/build/building/multi-platform/](https://docs.docker.com/build/building/multi-platform/#multiple-native-nodes))

Provide the `platforms` input parameter, e.g.:

```yaml
      - name: Build and publish a Docker image for ${{ github.repository }}
        uses: macbre/push-to-ghcr@master
        with:
          image_name: ${{ github.repository }}
          github_token: ${{ secrets.GITHUB_TOKEN }}
          platforms: "linux/amd64,linux/arm64,linux/arm/v7"
```

`buildx` / `qemu` should give you the list of available platforms:

```yaml
  {
    "supported": [
      "linux/amd64",
      "linux/amd64/v2",
      "linux/amd64/v3",
      "linux/arm64",
      "linux/riscv64",
      "linux/ppc64le",
      "linux/s390x",
      "linux/386",
      "linux/mips64le",
      "linux/mips64",
      "linux/loong64",
      "linux/arm/v7",
      "linux/arm/v6"
    ]
  }
```

## Labels and build args

The image that is pushed is labelled with `org.label-schema` [and `org.opencontainers` schema](https://github.com/opencontainers/image-spec/blob/master/annotations.md#pre-defined-annotation-keys). For instance:

```json
{
  "org.label-schema.build-date": "2021-07-01T14:28:46Z",
  "org.label-schema.vcs-ref": "6f51d3d7bb7d46959a26594cb2b807573e34c546",
  "org.label-schema.vcs-url": "https://github.com/macbre/push-to-ghcr.git",
  "org.opencontainers.image.created": "2021-07-01T14:28:46Z",
  "org.opencontainers.image.revision": "6f51d3d7bb7d46959a26594cb2b807573e34c546",
  "org.opencontainers.image.source": "https://github.com/macbre/push-to-ghcr.git"
}
```

Additonally, `BUILD_DATE` and `GITHUB_SHA` build args are passed. They can be used to set env variables:

```Dockerfile
# these two are passed as build args
ARG BUILD_DATE
ARG GITHUB_SHA

ENV BUILD_DATE=$BUILD_DATE
ENV GITHUB_SHA=$GITHUB_SHA
```

For instance:

```
BUILD_DATE=2021-07-01T12:52:03Z
GITHUB_SHA=26b095f37cdf56a632aa2235345d4174b26e1d66
```

## Optional pushes to Docker Hub (docker.io)

On 18th June 2021 [Docker Hub discontinued Autobuilds on the free tier](https://www.docker.com/blog/changes-to-docker-hub-autobuilds/). However, you can use this action to additionally push to docker.io repository.

1. You will need an access tokens created via https://hub.docker.com/settings/security.
2. Store it in your GitHub repository secrets, e.g. as `DOCKER_IO_ACCESS_TOKEN`.
3. Provide additional option in `with` section in action invocation:

```yaml
      # (...)
      - name: Build and publish a Docker image for ${{ github.repository }}
        uses: macbre/push-to-ghcr@master
        with:
          image_name: ${{ github.repository }}
          github_token: ${{ secrets.GITHUB_TOKEN }}
          docker_io_token: ${{ secrets.DOCKER_IO_ACCESS_TOKEN }}  # optionally push to the Docker Hub (docker.io)\
```

Your image will be pushed to both ghcr.io and docker.io repositories using the name provided as `image_name`.
