SHELL := /usr/bin/env bash

IMAGENAME=k8s-mirror
IMAGEREPO=darkbitio/$(IMAGENAME)
IMAGEPATH=$(IMAGEREPO):latest

NDEF = $(if $(value $(1)),,$(error $(1) not set))

DOCKERBUILD=docker build -t $(IMAGEREPO):latest .

COMMAND=docker run --rm -it -p31337:8080 -v "$(PWD)/data":/data

.PHONY: build run shell
build:
	@echo "Building $(IMAGEREPO):latest"
	@$(DOCKERBUILD)

run:
	@echo "Running in $(IMAGEREPO):latest"
	@$(COMMAND) $(IMAGEPATH) || exit 0

shell:
	@echo "Running a shell inside the container"
	@$(COMMAND) $(IMAGEPATH) /bin/bash || exit 0
