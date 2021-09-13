# This file is used by CI pipeline when testing this action
FROM alpine:latest

RUN apk update \
  && apk -a info curl \
  && apk add curl

# these two are passed as build args
ARG BUILD_DATE
ARG GITHUB_SHA

ENV GITHUB_SHA=$GITHUB_SHA

RUN env | sort
