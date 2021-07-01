# This file is used by CI pipeline when testing this action
FROM alpine:latest

# these two are passed as build args and stored as env variables
ARG BUILD_DATE
ARG GITHUB_SHA

RUN env | sort
