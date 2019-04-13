FROM golang:1.12.2-stretch AS builder
ENV DEBIAN_FRONTEND noninteractive
RUN apt-get update \
    && apt-get install -y --no-install-recommends git make \
    && rm -rf /var/lib/apt/lists/*

ARG COMMIT=master
RUN go get -d -u code.gitea.io/gitea
WORKDIR ${GOPATH}/src/code.gitea.io/gitea
RUN git checkout ${COMMIT}
RUN TAGS="bindata" make generate build
