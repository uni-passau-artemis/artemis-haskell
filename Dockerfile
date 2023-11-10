FROM docker.io/library/debian:stable

ENV STACK_ROOT /stack_cache

RUN mkdir -p $STACK_ROOT

COPY stack-config/config.yaml $STACK_ROOT/config.yaml
COPY stack-config/global-project/stack.yaml $STACK_ROOT/global-project/stack.yaml

RUN apt-get update \
  && apt-get -y install curl perl tar llvm libnuma-dev \
  && bash -c "curl -sSL https://get.haskellstack.org/ | sh" \
  && apt-get clean \
  && rm -rf /var/lib/apt/lists/*

RUN stack setup \
  && stack ghc \
  --package QuickCheck \
  --package quickcheck-assertions \
  --package smallcheck \
  --package tasty \
  --package tasty-ant-xml \
  --package tasty-hunit \
  --package tasty-quickcheck \
  --package tasty-smallcheck \
  --package unordered-containers \
  -- --version \
  # Jenkins runs the builds not as root, but with a system dependent user id.
  # Therefore, we allow all users to access the stack cache.
  && chmod -R a+rw $STACK_ROOT
