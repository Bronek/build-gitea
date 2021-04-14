ARG GO_REL
FROM golang:${GO_REL}-buster AS builder

RUN DEBIAN_FRONTEND=noninteractive \
    curl -sL https://deb.nodesource.com/setup_12.x -o nodesource_setup.sh && \
    bash nodesource_setup.sh && \
    rm nodesource_setup.sh && \
    apt-get install -y nodejs && \
    rm -rf /var/lib/apt/lists/*

WORKDIR /work
ARG RELEASE
RUN curl -fsSL https://github.com/go-gitea/gitea/archive/refs/tags/${RELEASE}.tar.gz | tar -xz --strip-components=1
RUN DRONE_TAG="${RELEASE}" TAGS="bindata" make build
