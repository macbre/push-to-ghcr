# push-to-ghcr
This action simplifies pushes of Docker images to [ghcr.io repository](https://docs.github.com/en/packages/working-with-a-github-packages-registry/working-with-the-container-registry).

* On each `release` event (releases named `vx.y.z`) your image will be tagged with `x.y.z`
* On each `push` event your image will be tagged with `latest`

## How to use it?

Create a new GitHub Actions workflow as follows:

```yaml
name: Build and publish a Docker image to ghcr.io
on:

  # publish on releases (tagged as "x.y.z" - "v" prefix is removed)
  release:
    types: [ published ]

  # publish on pushes to the main branch (tagged as "master")
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
          image_name: ${{ github.repository }}
          github_token: ${{ secrets.GITHUB_TOKEN }}
```

This action assumes that your `Dockerfile` is in the root directory of your repository.

## Labels and build args

The image that is pushed is labelled with:

```json
{
  "org.label-schema.build-date": "2021-07-01T12:52:03Z",
  "org.label-schema.vcs-ref": "26b095f37cdf56a632aa2235345d4174b26e1d66",
  "org.label-schema.vcs-url": "https://github.com/macbre/push-to-ghcr.git"
}
```

Additonally, `BUILD_DATE` and `GITHUB_SHA` build args are set resulting with these env variables being present in the container:

```
BUILD_DATE=2021-07-01T12:52:03Z
GITHUB_SHA=26b095f37cdf56a632aa2235345d4174b26e1d66
```
