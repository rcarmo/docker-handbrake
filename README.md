# Handbrake

[![Docker Stars](https://img.shields.io/docker/stars/rcarmo/handbrake.svg)](https://hub.docker.com/r/rcarmo/handbrake)
[![Docker Pulls](https://img.shields.io/docker/pulls/rcarmo/handbrake.svg)](https://hub.docker.com/r/rcarmo/handbrake)
[![](https://images.microbadger.com/badges/image/rcarmo/handbrake.svg)](https://microbadger.com/images/rcarmo/handbrake "Get your own image badge on microbadger.com")
[![](https://images.microbadger.com/badges/version/rcarmo/handbrake.svg)](https://microbadger.com/images/rcarmo/handbrake "Get your own version badge on microbadger.com")
[![Build Status](https://travis-ci.org/rcarmo/docker-handbrake.svg?branch=master)](https://travis-ci.org/rcarmo/docker-handbrake)

This is a container for running `handbrake-cli` on non-Ubuntu systems, in order to slim down BluRay and DVD rips for iOS devices or convert MPEG transport streams to HEVC (H.265) or plain "old" H.264.


## Usage

```
docker run -it -e PUID=1001 -e PGID=1001 --cpuset-cpus 8-15 -e EXTENSION=ts -e AUDIO_CODEC=AC3 -v "$PWD:/data" rcarmo/handbrake
```

This will go over all `*.ts` files in `/tmp` and transcode them to an `.mp4` envelope with 5.1 audio, preserving subtitles (where applicable). 

The default `EXTENSION` is now `mkv` by popular demand, but see `transcode.sh` for details.
