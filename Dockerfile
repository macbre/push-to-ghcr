# This file is used by CI pipeline when testing this action
FROM alpine:latest

ARG BUILD_DATE
ARG GITHUB_SHA

RUN echo "BUILD_DATE is ${BUILD_DATE}"
RUN echo "GITHUB_SHA is ${GITHUB_SHA}"
RUN env | sort
