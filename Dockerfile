# This file is used by CI pipeline when testing this action
FROM alpine:latest

ARG GITHUB_SHA

RUN echo "GITHUB_SHA: ${GITHUB_SHA}"
RUN env | sort
