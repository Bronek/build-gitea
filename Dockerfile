ARG GO_REL
FROM golang:${GO_REL}-stretch AS builder

ARG COMMIT=master
RUN go get -d -u code.gitea.io/gitea
WORKDIR ${GOPATH}/src/code.gitea.io/gitea
RUN git checkout ${COMMIT}
RUN TAGS="bindata" make generate build
