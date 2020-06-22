ARG GO_REL
FROM golang:${GO_REL}-stretch AS builder

RUN DEBIAN_FRONTEND=noninteractive \
    curl -sL https://deb.nodesource.com/setup_12.x -o nodesource_setup.sh && \
    bash nodesource_setup.sh && \
    rm nodesource_setup.sh && \
    apt-get install -y nodejs && \
    rm -rf /var/lib/apt/lists/*

ARG COMMIT=master
RUN go get -d -u code.gitea.io/gitea
WORKDIR ${GOPATH}/src/code.gitea.io/gitea
RUN git checkout ${COMMIT}
RUN TAGS="bindata" make build
