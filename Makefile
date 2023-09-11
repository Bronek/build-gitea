# Note, 'v' version prefix added below
VERSION = 1.20.4
RELEASE:= v$(VERSION)
GO_REL  = 1.20.5
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

default: copy

.PHONY: build
build: iid.txt

iid.txt:
	$(DRIVER) build --build-arg GO_REL=$(GO_REL) --build-arg RELEASE=$(RELEASE) -t build-gitea-$(USER) --iidfile $(IIDFILE) .
	cp  $(IIDFILE) iid.txt

.PHONY: copy
copy: dist/gitea dist/public.tar.gz

dist/gitea dist/public.tar.gz: iid.txt
	rm -rf $(PWD)/dist
	mkdir -p $(PWD)/dist
	$(DRIVER) run --rm -v $(PWD)/dist:/dist:Z $$(cat iid.txt) sh -c \
		'cp ./gitea /dist && chown $(USERID) /dist/gitea'
	$(DRIVER) run --rm -v $(PWD)/dist:/dist:Z $$(cat iid.txt) sh -c \
		'tar -czf /dist/public.tar.gz ./public/ && chown $(USERID) /dist/public.tar.gz'
	# We do not know if DRIVER is rootless or not, so just in case try unshare.
	$(DRIVER) unshare chown 0:0 -R $(PWD)/dist/ 2>/dev/null || echo -n

.PHONY: clean
clean:
	rm -f $(PWD)/iid.txt
	rm -rf $(PWD)/dist
