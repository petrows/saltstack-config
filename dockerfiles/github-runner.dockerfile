ARG version
FROM mgoltzsche/podman:$version

RUN <<PKG
  set -e
  apk add --update --no-cache \
      bash \
      python3 \
      py3-pip
PKG
