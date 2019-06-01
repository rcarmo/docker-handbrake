# Handbrake

This is a container for running `handbrake-cli` on non-Ubuntu systems, in order to slim down BluRay and DVD rips for iOS devices or convert MPEG transport streams to H.264.


## Usage

```
docker run -v /tmp:/data -e EXTENSION=ts rcarmo/handbrake
```

This will go over all `*.ts` files in `/tmp` and transcode them to an `.mp4` envelope with 5.1 audio, preserving the first six subtitles (where applicable).

See `transcode.sh` for details.
