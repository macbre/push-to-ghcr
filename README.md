# push-to-ghcr
This action simplifies pushes of Docker images ot ghcr.io repository.

* On each `release` event (releases named `vx.y.z`) your image will be tagged with `x.y.z`
* On each `push` event your image will be tagged with `latest`

## How to use it?

Create a new GitHub Actions workflow as follows:

```yaml

```
