# Stage 1: Build stage using Alpine as the base image
FROM alpine:latest as builder

RUN apk update \
 && apk add --no-cache \
    librtlsdr-dev \
    rtl-sdr \
    git \
    cmake \
    make \
    g++ \
    soapy-sdr-dev \
    hackrf-dev \
    hackrf-libs

# Build SoapyRTLSDR module
RUN git clone https://github.com/pothosware/SoapyRTLSDR.git /SoapyRTLSDR \
 && cd /SoapyRTLSDR \
 && mkdir build \
 && pwd \
 && cd build \
 && cmake .. \
 && make \
 && make install

# Build SoapyHackRF module
RUN  git clone https://github.com/pothosware/SoapyHackRF.git /SoapyHackRF \
 && cd SoapyHackRF \
 && mkdir build \
 && cd build \
 && cmake .. \
 && make \
 && make install

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
    librtlsdr-dev \
    hackrf-libs \
 && rm -rf /lib/apk/db/* \
 && mkdir -p /var/run/dbus \
 && addgroup -S soapysdr && adduser -S -G soapysdr soapysdr

#Copy from builder
COPY --from=builder /usr/local/lib/SoapySDR/modules0.8/* /usr/local/lib/SoapySDR/modules0.8/

# Prepare your service scripts
COPY ./s6-overlay/s6-rc.d /etc/s6-overlay/s6-rc.d
RUN chmod +x /etc/s6-overlay/s6-rc.d/01-startup/script.sh

COPY start-soapysdr.sh /usr/local/bin/start-soapysdr.sh
RUN chmod +x /usr/local/bin/start-soapysdr.sh

RUN mkdir -p /var/run/dbus/

# Set the entry point to use S6
ENTRYPOINT ["/init"]