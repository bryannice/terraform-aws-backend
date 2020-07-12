ARG BASE_IMAGE=golang:1.14.1-alpine3.11

FROM ${BASE_IMAGE}

ENV REFRESHED_AT=2019-11-13

LABEL Name="senzing/terraform-aws-backend" \
      Maintainer="support@senzing.com" \
      Version="1.0.0"

ARG TERRAFORM_VERSION=0.12.20

ENV BUILD_PACKAGES \
    wget \
    tar \
    git \
    ncurses \
    make \
    graphviz \
    tree \
    gettext \
    bash \
    py-pip \
    python3

RUN set -x \
 && apk update \
 && apk upgrade \
 && apk add --no-cache ${BUILD_PACKAGES}

# Terraform
ENV TF_DEV=true
ENV TF_RELEASE=true

WORKDIR $GOPATH/src/github.com/hashicorp/terraform
RUN git clone https://github.com/hashicorp/terraform.git ./ \
 && git checkout v${TERRAFORM_VERSION} \
 && /bin/bash scripts/build.sh

# Install aws cli
RUN pip3 install \
        awscli

WORKDIR /root
