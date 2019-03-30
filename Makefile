# Note, 'v' version prefix added in --build-arg below
VERSION = 1.7.5
DOCKER ?= $(shell which docker)
IIDFILE:= $(shell mktemp /var/tmp/XXXXXX.id)
USERID  = $(shell id -u):$(shell id -g)

default: copy

build:
	$(DOCKER) build --build-arg REF=v$(VERSION) -t build-gitea-$(USER) --iidfile $(IIDFILE) .

clean:
	rm -rf $(PWD)/dist

copy: build clean
	mkdir -p $(PWD)/dist
	$(DOCKER) run --rm -v $(PWD)/dist:/dist $$(cat $(IIDFILE)) sh -c \
		'cp ./gitea /dist && chown $(USERID) -R /dist'

