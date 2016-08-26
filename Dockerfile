# Dockerfile for Azure/batch-shipyard

FROM gliderlabs/alpine:3.4

WORKDIR /tmp

# set environment variables
ENV libtorrent_version=1.1.1 libtorrent_version_path=1_1_1
ENV CFLAGS=-lstdc++ PYTHON=/usr/bin/python3 PYTHON_VERSION=3.5

# add base packages, python dependencies, create script directory,
# build libtorrent-rasterbar for python3 and cleanup packaging
RUN apk update \
    && apk add --update --no-cache \
        musl build-base python3 python3-dev openssl-dev ca-certificates \
        boost boost-dev boost-python3 file curl tar pigz docker bash \
    && pip3 install --no-cache-dir --upgrade pip azure-storage==0.32.0 \
    && curl -SL https://github.com/arvidn/libtorrent/releases/download/libtorrent-${libtorrent_version_path}/libtorrent-rasterbar-${libtorrent_version}.tar.gz -o libtorrent-${libtorrent_version}.tar.gz \
    && tar zxvpf libtorrent-${libtorrent_version}.tar.gz \
    && cd libtorrent-rasterbar-${libtorrent_version} \
    && ./configure --prefix=/usr --enable-debug=no --enable-python-binding --with-boost-system=boost_system \
    && make -j4 install \
    && ldconfig /usr/lib \
    && cd .. \
    && rm -rf libtorrent-rasterbar-${libtorrent_version} \
    && rm -f zxvpf libtorrent-${libtorrent_version}.tar.gz \
    && apk del --purge \
        build-base python3-dev openssl-dev python boost-dev file curl \
    && apk add --no-cache boost-random \
    && rm /var/cache/apk/* \
    && mkdir -p /opt/batch-shipyard

# copy in files
COPY cascade.py setup_private_registry.py perf.py scripts/docker_cascade.sh /opt/batch-shipyard/

# set command
CMD ["/opt/batch-shipyard/docker_cascade.sh"]
