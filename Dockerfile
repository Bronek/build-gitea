ARG GO_REL
FROM golang:${GO_REL}-stretch AS builder

ENV DEBIAN_FRONTEND noninteractive
RUN apt-get update \
    && apt-get install -y --no-install-recommends git make \
    && rm -rf /var/lib/apt/lists/*

ARG COMMIT=master
RUN go get -d -u code.gitea.io/gitea
WORKDIR ${GOPATH}/src/code.gitea.io/gitea
RUN git checkout ${COMMIT}
RUN TAGS="bindata" make generate build
