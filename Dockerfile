ARG GO_REL
FROM golang:${GO_REL}-bullseye AS builder

ENV NODE_MAJOR=20
ENV DEBIAN_FRONTEND=noninteractive
RUN apt-get update &&\
    apt-get install -y ca-certificates curl gnupg &&\
    mkdir -p /etc/apt/keyrings &&\
    curl -fsSL https://deb.nodesource.com/gpgkey/nodesource-repo.gpg.key | gpg --dearmor -o /etc/apt/keyrings/nodesource.gpg &&\
    echo "deb [signed-by=/etc/apt/keyrings/nodesource.gpg] https://deb.nodesource.com/node_$NODE_MAJOR.x nodistro main" > /etc/apt/sources.list.d/nodesource.list &&\
    apt-get update &&\
    apt-get install -y nodejs &&\
    rm -rf /var/lib/apt/lists/*

WORKDIR /work
ARG RELEASE
RUN curl -fsSL https://github.com/go-gitea/gitea/archive/refs/tags/${RELEASE}.tar.gz | tar -xz --strip-components=1
RUN GITHUB_REF_TYPE="explicit" GITHUB_REF_NAME="${RELEASE}" TAGS="bindata" make build
