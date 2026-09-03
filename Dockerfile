# syntax=docker/dockerfile:1.7
ARG ALPINE_VERSION=3.22

FROM alpine:${ALPINE_VERSION} AS nmap-builder
ARG NMAP_VERSION=7.991
RUN apk add --no-cache \
        build-base ca-certificates curl linux-headers libpcap-dev libssh2-dev \
        openssl-dev pcre2-dev zlib-dev \
    && curl --fail --location --proto '=https' --tlsv1.2 \
        "https://nmap.org/dist/nmap-${NMAP_VERSION}.tar.bz2" -o /tmp/nmap.tar.bz2 \
    && tar -xjf /tmp/nmap.tar.bz2 -C /tmp \
    && cd "/tmp/nmap-${NMAP_VERSION}" \
    && ./configure --prefix=/usr/local --with-liblua=included \
        --without-zenmap --without-ndiff \
    && make -j"$(getconf _NPROCESSORS_ONLN)" \
    && make install DESTDIR=/out \
    && strip /out/usr/local/bin/nmap /out/usr/local/bin/ncat /out/usr/local/bin/nping

FROM alpine:${ALPINE_VERSION}
ARG NMAP_VERSION=7.991
ARG ZENMAP_WHEEL_SHA256=""

LABEL org.opencontainers.image.title="Nmap + Zenmap Web" \
      org.opencontainers.image.description="Official Nmap and Zenmap exposed through a browser" \
      org.opencontainers.image.source="https://github.com/Ploos-AS/nmap-zenmap" \
      org.opencontainers.image.documentation="https://github.com/Ploos-AS/nmap-zenmap#readme" \
      org.opencontainers.image.vendor="Per Gustav Ousdal" \
      org.opencontainers.image.licenses="NPSL"

RUN apk add --no-cache \
        adwaita-icon-theme ca-certificates curl dbus dbus-x11 font-dejavu gtk+3.0 \
        libcap libpcap libssh2 openbox openssl pcre2 py3-gobject3 py3-pip \
        novnc python3 shared-mime-info su-exec websockify x11vnc xvfb zlib \
    && addgroup -g 1000 zenmap \
    && adduser -D -u 1000 -G zenmap -h /config zenmap \
    && mkdir -p /config/scans /run/dbus \
    && curl --fail --location --proto '=https' --tlsv1.2 \
        "https://nmap.org/dist/zenmap-${NMAP_VERSION}-py3-none-any.whl" \
        -o "/tmp/zenmap-${NMAP_VERSION}-py3-none-any.whl" \
    && if [ -n "$ZENMAP_WHEEL_SHA256" ]; then \
         echo "$ZENMAP_WHEEL_SHA256  /tmp/zenmap-${NMAP_VERSION}-py3-none-any.whl" | sha256sum -c -; \
       fi \
    && pip3 install --break-system-packages --no-cache-dir --no-deps \
        "/tmp/zenmap-${NMAP_VERSION}-py3-none-any.whl" \
    && rm -f "/tmp/zenmap-${NMAP_VERSION}-py3-none-any.whl" \
    && ln -sf vnc.html /usr/share/novnc/index.html

COPY --from=nmap-builder /out/ /
COPY rootfs/ /
RUN setcap cap_net_raw,cap_net_admin+eip /usr/local/bin/nmap \
    && setcap cap_net_raw+eip /usr/local/bin/nping

ENV DISPLAY=:99 \
    WEB_PORT=6080 \
    VNC_PORT=5900 \
    GEOMETRY=1440x900 \
    DEPTH=24 \
    PUID=1000 \
    PGID=1000

VOLUME ["/config"]
EXPOSE 6080
HEALTHCHECK --interval=30s --timeout=5s --start-period=20s --retries=3 \
    CMD wget -q -O /dev/null "http://127.0.0.1:${WEB_PORT}/" || exit 1

ENTRYPOINT ["/usr/local/bin/container-entrypoint"]
