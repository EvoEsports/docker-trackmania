FROM alpine:3.13.5

# environment variables
ARG TMSERVER_VERSION="2021-10-12"
ARG GLIBC_VERSION="2.33-r0"
ARG TMSERVER_URL="http://files.v04.maniaplanet.com/server/TrackmaniaServer_${TMSERVER_VERSION}.zip"
ARG GLIBC_URL="https://github.com/sgerrand/alpine-pkg-glibc/releases/download/${GLIBC_VERSION}/glibc-${GLIBC_VERSION}.apk"
ARG BUILD_DATE
ARG REVISION

# labels
LABEL org.opencontainers.image.title="Trackmania Server" \
      org.opencontainers.image.description="Server for the game Trackmania, released in 2020 by Nadeo." \
      org.opencontainers.image.version=${TMSERVER_VERSION} \
      org.opencontainers.image.created=${BUILD_DATE} \
      org.opencontainers.image.authors="Nicolas Graf <nicolas.j.graf@gmail.com>" \
      org.opencontainers.image.vendor="Evo" \
      org.opencontainers.image.licenses="Apache-2.0" \
      org.opencontainers.image.revision=${REVISION}

# user creation & base dir creation
RUN set -eux; \
    addgroup -g 9999 trackmania && \
    adduser -u 9999 -Hh /server -G trackmania -s /sbin/nologin -D trackmania && \
    install -d -o trackmania -g trackmania -m 775 /server

WORKDIR /server

# install dependencies
RUN wget -q -O /etc/apk/keys/sgerrand.rsa.pub https://alpine-pkgs.sgerrand.com/sgerrand.rsa.pub && \
    wget -q -O /etc/apk/glibc.apk ${GLIBC_URL} && \
    apk add /etc/apk/glibc.apk && \
    apk add --no-cache xmlstarlet bash unzip curl jq su-exec && \
    rm /etc/apk/glibc.apk

# install server
RUN wget ${TMSERVER_URL} -O /server/server.zip && \
    unzip -q /server/server.zip && \
    rm /server/server.zip && \
    chown trackmania:trackmania -Rf /server && \
    rm -Rf /server/RemoteControlExamples /server/TrackmaniaServer.exe

# copy entrypoint.sh
COPY entrypoint.sh /usr/local/bin/
RUN chmod +x /usr/local/bin/entrypoint.sh

EXPOSE 2350/tcp
EXPOSE 2350/udp
EXPOSE 5000/tcp

HEALTHCHECK --interval=5s --timeout=5s --start-period=20s --retries=3 \
    CMD nc -z -v 127.0.0.1 5000 || exit 1

VOLUME [ "/server/UserData" ]

# switch to non-root user
USER trackmania

# set entrypoint
ENTRYPOINT [ "entrypoint.sh" ]
CMD [ "./TrackmaniaServer" ]
