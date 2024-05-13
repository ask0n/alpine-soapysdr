FROM alpine:latest
LABEL maintainer="ask0n <6883355+ask0n@users.noreply.github.com>"

ENV SOAPY_REMOTE_IP_ADDRESS=[::] \
    SOAPY_REMOTE_PORT=55132

# Install necessary packages
RUN echo "@testing http://dl-cdn.alpinelinux.org/alpine/edge/testing" >> /etc/apk/repositories \
 && apk update \
 && apk add --no-cache \
    avahi \
    dbus \
    s6-overlay \
    gosu@testing \
    soapy-sdr@testing \
    soapy-sdr-remote@testing \
    supervisor@testing \
 && rm -rf /lib/apk/db/* \
 && mkdir -p /var/run/dbus \
 && addgroup -S soapysdr && adduser -S -G soapysdr soapysdr

# Prepare your service scripts
COPY ./s6-overlay/s6-rc.d /etc/s6-overlay/s6-rc.d
RUN chmod +x /etc/s6-overlay/s6-rc.d/01-startup/script.sh

COPY start-soapysdr.sh /usr/local/bin/start-soapysdr.sh
RUN chmod +x /usr/local/bin/start-soapysdr.sh

RUN mkdir -p /var/run/dbus/

# Set the entry point to use S6
ENTRYPOINT ["/init"]