# Note, 'v' version prefix added below
VERSION = 1.11.3
COMMIT := v$(VERSION)
GO_REL  = 1.13.9
ifeq ($(origin DRIVER), undefined)
  ifneq ($(shell which podman 2>/dev/null || echo 0), 0)
    DRIVER := $(shell which podman)
  else ifneq ($(shell which docker 2>/dev/null || echo 0), 0)
    DRIVER := $(shell which docker)
  else
    $(error Could not find podman nor docker, please set DRIVER or install the necessary packages)
  endif
endif
IIDFILE:= $(shell mktemp /var/tmp/XXXXXX.id)
USERID := $(shell id -u):$(shell id -g)

default: build

.PHONY: build
build:
	$(DRIVER) build --build-arg GO_REL=$(GO_REL) -t build-gitea-$(USER) --iidfile $(IIDFILE) build
	$(DRIVER) run --rm -v $(PWD)/gitea:/gitea:Z -v $(PWD)/go:/go:Z -v $(PWD)/cache:/.cache:Z -v $(PWD)/npm:/.npm:Z --user=$(USERID) $$(cat $(IIDFILE)) /bin/sh -c \
		'cd /gitea && TAGS="bindata sqlite sqlite_unlock_notify" make generate build'
	cp $(IIDFILE) .iid

.PHONY: clean
clean:
	rm -f .iid

.PHONY: run
run:
	$(DRIVER) run --rm -v $(PWD)/gitea/gitea:/gitea:ro -v $(PWD)/gitea/options:/conf:ro -v $(PWD)/conf:/custom/custom/conf:rw -v $(PWD)/data:/data:rw -v $(PWD)/repos:/repos:rw -w=/ -p=127.0.0.1:3000:3000 $$(cat .iid) /bin/sh -c \
		'exec /gitea'

.PHONY: shell
shell:
	$(DRIVER) run -it --rm -v $(PWD)/gitea/gitea:/gitea:ro -v $(PWD)/gitea/options:/conf:ro -v $(PWD)/conf:/custom/custom/conf:rw -v $(PWD)/data:/data:rw -v $(PWD)/repos:/repos:rw -w=/ -p=127.0.0.1:3000:3000 $$(cat .iid) /bin/bash

.PHONY: copy
copy:
	rm -rf $(PWD)/dist
	mkdir -p $(PWD)/dist
	$(DRIVER) run --rm -v $(PWD)/gitea:/gitea:ro -v $(PWD)/dist:/dist:Z --user=$(USERID) $$(cat .iid) /bin/sh -c \
		'cp /gitea/gitea /dist && chown $(USERID) /dist/gitea'
