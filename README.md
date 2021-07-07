# push-to-ghcr
This action simplifies pushes of Docker images to [the GitHub Containers Registry at ghcr.io](https://docs.github.com/en/packages/working-with-a-github-packages-registry/working-with-the-container-registry).

`Dockerfile` from your repository is build and published on:

* `release` event (releases named `vx.y.z`) your image will be tagged with `x.y.z`
* `push` event your image will be tagged with `latest`

### Private containers

Images built for private repositories will be published as private containers to ghcr.io. Please refer to https://docs.github.com/en/packages/working-with-a-github-packages-registry/working-with-the-container-registry#authenticating-to-the-container-registry on how to set up access to them.

## How to use it?

Create a new GitHub Actions workflow as follows:

```yaml
name: Build and publish a Docker image to ghcr.io
on:

  # publish on releases, e.g. v2.1.13 (tagged as "2.1.13" - "v" prefix is removed)
  release:
    types: [ published ]

  # publish on pushes to the main branch (tagged as "latest")
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
        uses: macbre/push-to-ghcr@v2
        with:
          image_name: ${{ github.repository }}
          github_token: ${{ secrets.GITHUB_TOKEN }}
```

This action assumes that your `Dockerfile` is in the root directory of your repository.

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

Additonally, `BUILD_DATE` and `GITHUB_SHA` build args are set resulting with these env variables being present in the container:

```
BUILD_DATE=2021-07-01T12:52:03Z
GITHUB_SHA=26b095f37cdf56a632aa2235345d4174b26e1d66
```
