ARG BASE=ubuntu:20.04
FROM ${BASE} as base

MAINTAINER Rui Carmo https://github.com/rcarmo

ADD init.sh /init
ADD transcode.sh /transcode
ADD h265aac.json /h265aac.json 
ADD h265aac_hdr.json /h265aac_hdr.json 
ADD h265ac3.json /h265ac3.json 
ADD h265ac3_hdr.json /h265ac3_hdr.json

ENV DEBIAN_FRONTEND noninteractive

RUN apt-get update \
 && apt-get dist-upgrade -y \
 && apt-get install -y \
    software-properties-common \
 && add-apt-repository ppa:stebbins/handbrake-releases \
 && apt-get update \
 && apt-get install -y \
     handbrake-cli \
     libdvd-pkg \
     ffmpeg \
     sudo \
 && dpkg-reconfigure libdvd-pkg \
 && apt-get remove -y \
    software-properties-common \
 && apt-get autoremove -y \
 && apt-get clean \
 && rm -rf /var/lib/apt/lists/* \
 && chmod +x /init /transcode

# Allow user to set uid/gid for Docker process
ENV PGID=1000
ENV PUID=1000
ENV EXTENSION=mkv
ENV PAUSES="false"
ENV VIDEO_CODEC="H.265"
ENV AUDIO_CODEC="AAC"
ENV SCRATCH_FOLDER=""
ENV RANDOM_PICK="false"
ENV HOSTNAME="handbrake"

WORKDIR /data
VOLUME /data
CMD ["/init"]

ARG VCS_REF
ARG VCS_URL
ARG BUILD_DATE
LABEL org.label-schema.vcs-ref=$VCS_REF \
      org.label-schema.vcs-url=$VCS_URL \
      org.label-schema.build-date=$BUILD_DATE
