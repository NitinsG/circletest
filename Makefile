# Makefile for Docker builds in CircleCI

SHELL := /bin/bash
IMAGE_NAMESPACE := quay.io

# lowercase the image owner and repo name
IMAGE_OWNER := $(shell tr '[:upper:]' '[:lower:]' <<< $(CIRCLE_PROJECT_USERNAME) | tr '-' '_')

# exclude the prefix `docker-` from the image repo name

IMAGE_REPO := $(shell tr '[:upper:]' '[:lower:]' <<< $(CIRCLE_PROJECT_REPONAME) | \
  sed s/^docker[-_]//)
# create an ENV var value with just uppercase and _ chars

IMAGE_VAR := $(shell tr '[:lower:]' '[:upper:]' <<< $(IMAGE_REPO) | \
  tr "[:punct:]" "_")
IMAGE_VERSION := $(shell cat VERSION)
IMAGE_TAG := $(IMAGE_NAMESPACE)/$(IMAGE_OWNER)/$(IMAGE_REPO):$(IMAGE_VERSION)
IMAGE_LATEST := $(IMAGE_NAMESPACE)/$(IMAGE_OWNER)/$(IMAGE_REPO):latest
DOCKER_SERVER := quay.io

.PHONY: build push

build:
        cp Dockerfile Dockerfile.tmp
        echo 'ENV "$(IMAGE_VAR)_VERSION"="$(IMAGE_VERSION)"' >> Dockerfile.tmp
        echo 'LABEL "image.tag"="$(IMAGE_TAG)" \
                "image.commit"="$(CIRCLE_SHA1)" \
                "image.build"="$(CIRCLE_SLUG)/$(CIRCLE_BUILD_NUM)"' >> Dockerfile.tmp
        cp Dockerfile.tmp dist/Dockerfile
        cd dist && \
                docker build -t $(IMAGE_TAG) .
        docker tag $(IMAGE_TAG) $(IMAGE_LATEST)
        rm Dockerfile.tmp

push:
        echo docker login
        echo "$(DOCKER_EMAIL) $(DOCKER_USER) $(DOCKER_PASS)"
        @docker login \
                --email="$(DOCKER_EMAIL)" \
                --username="$(DOCKER_USER)" \
                --password="$(DOCKER_PASS)" \
                $(DOCKER_SERVER)
        docker push $(IMAGE_TAG)
        docker push $(IMAGE_LATEST)
        git tag -f "v$(IMAGE_VERSION)"
