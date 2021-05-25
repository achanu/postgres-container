FROM quay.io/centos/centos:stream AS micro-build

RUN \
  mkdir -p /rootfs && \
  dnf install -y \
    --installroot /rootfs --releasever 8 \
    --setopt install_weak_deps=false --nodocs \
    coreutils-single \
    glibc-minimal-langpack \
    setup \
    openssl \
  && \
  cp -v /etc/yum.repos.d/*.repo /rootfs/etc/yum.repos.d/ && \
  dnf -y module enable \
    --installroot /rootfs \
    postgresql:12 \
  && \
  dnf install -y \
    --installroot /rootfs \
    --setopt install_weak_deps=false --nodocs \
    postgresql-server \
    postgresql-contrib \
    glibc-langpack-en \
  && \
  dnf clean all && \
  rm -rf /rootfs/var/cache/* && \
  mkdir /rootfs/run/nginx


FROM scratch AS postgres-micro
LABEL maintainer="Alexandre Chanu <alexandre.chanu@gmail.com>"

COPY --from=micro-build /rootfs/ /

USER postgres
CMD ["/usr/bin/postgres", "-D", "/var/lib/pgsql/data"]

VOLUME /var/lib/pgsql/data
EXPOSE 5432/tcp
