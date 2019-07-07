# Handbrake

[![Docker Stars](https://img.shields.io/docker/stars/rcarmo/handbrake.svg)](https://hub.docker.com/r/rcarmo/handbrake)
[![Docker Pulls](https://img.shields.io/docker/pulls/rcarmo/handbrake.svg)](https://hub.docker.com/r/rcarmo/handbrake)
[![](https://images.microbadger.com/badges/image/rcarmo/handbrake.svg)](https://microbadger.com/images/rcarmo/handbrake "Get your own image badge on microbadger.com")
[![](https://images.microbadger.com/badges/version/rcarmo/handbrake.svg)](https://microbadger.com/images/rcarmo/handbrake "Get your own version badge on microbadger.com")
[![Build Status](https://travis-ci.org/rcarmo/docker-handbrake.svg?branch=master)](https://travis-ci.org/rcarmo/docker-handbrake)

This is a container for running `handbrake-cli` on non-Ubuntu systems, in order to slim down BluRay and DVD rips for iOS devices or convert MPEG transport streams to H.264.


## Usage

```
docker run -v /tmp:/data -e EXTENSION=ts rcarmo/handbrake
```

This will go over all `*.ts` files in `/tmp` and transcode them to an `.mp4` envelope with 5.1 audio, preserving the first six subtitles (where applicable).

See `transcode.sh` for details.
