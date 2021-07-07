# This file is used by CI pipeline when testing this action
FROM alpine:latest

RUN apk -a info curl \
  && apk add curl

# these two are passed as build args and stored as env variables
ARG BUILD_DATE
ARG GITHUB_SHA

RUN env | sort
