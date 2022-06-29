FROM debian:stable

SHELL [ "/bin/bash", "-o", "pipefail", "-c"]

ENV STACK_ROOT /stack_cache

RUN mkdir -p $STACK_ROOT

RUN apt-get update \
    && apt-get -y install curl perl tar

RUN curl -sSL https://get.haskellstack.org/ | sh

RUN apt-get clean \
    && rm -rf /var/lib/apt/lists/*

COPY stack-config/config.yaml $STACK_ROOT/config.yaml
COPY stack-config/global-project/stack.yaml $STACK_ROOT/global-project/stack.yaml

RUN stack setup \
    && stack ghc \
            --package QuickCheck \
            --package quickcheck-assertions \
            --package smallcheck \
            --package tasty \
            --package tasty-quickcheck \
            --package tasty-smallcheck \
            --package tasty-hunit \
            --package tasty-ant-xml \
            --package unordered-containers \
            -- --version

# Jenkins runs the builds not as root, but with a system dependent user id.
# Therefore, we allow all users to access the stack cache.
RUN chmod -R a+rw $STACK_ROOT
