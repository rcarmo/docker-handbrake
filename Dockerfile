ARG BASE
FROM ${BASE} as base

MAINTAINER Rui Carmo https://github.com/rcarmo

ADD init.sh /init
ADD transcode.sh /transcode

RUN apt-get update \
 && apt-get dist-upgrade -y \
 && apt-get install -y \
    software-properties-common \
 && add-apt-repository ppa:stebbins/handbrake-releases \
 && apt-get update \
 && apt-get install -y \
     handbrake-cli \
     sudo \
 && apt-get remove -y \
    software-properties-common \
 && apt-get autoremove -y \
 && apt-get clean \
 && rm -rf /var/lib/apt/lists/* \
 && chmod +x /init /transcode

ENV EXTENSION=mkv
# Allow user to set uid/gid for Docker process
ENV PGID=1000
ENV PUID=1000
ENV PAUSES="false"
ENV VIDEO_CODEC="H.264"
ENV AUDIO_CODEC="AC3"
ENV SCRATCH_FOLDER=""

WORKDIR /data
VOLUME /data
CMD ["/init"]

ARG VCS_REF
ARG VCS_URL
ARG BUILD_DATE
LABEL org.label-schema.vcs-ref=$VCS_REF \
      org.label-schema.vcs-url=$VCS_URL \
      org.label-schema.build-date=$BUILD_DATE
