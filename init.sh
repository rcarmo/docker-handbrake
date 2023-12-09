#!/bin/sh

# This is already baked into our base image, no point in setting up another
USER=www-data

# Follow the linuxserver.io approach to setting UIDs
PUID=${PUID:-911}
PGID=${PGID:-911}

echo "UID:GID - $PUID:$PGID"

groupmod -o -g "$PGID" $USER
usermod -o -u "$PUID" $USER

chown $USER /dev/dri/*
chown $USER /*.json

# CMD
sudo -H -E -u $USER /transcode
