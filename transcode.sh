#!/bin/bash
if [ -z "${EXTENSION}" ]; then 
   EXTENSION=mkv
fi

# Pause before enumeration
sleep $((RANDOM % 9))

FILES=*.${EXTENSION}
for FILE in $FILES
do
    export TARGET="${FILE%.$EXTENSION}.mp4"
    # Pause before check
    sleep $((RANDOM % 9))
    if [ ! -e "$TARGET" ]
    then
        echo "$FILE -> $TARGET"
        # AAC Stereo
        #HandBrakeCLI -i "$FILE" -o "$TARGET" -E faac -B 96k -6 stereo -R 44.1 -e x264 -q 27 -x cabac=1:ref=5:analyse=0x133:me=umh:subme=9:chroma-me=1:deadzone-inter=21:deadzone-intra=11:b-adapt=2:rc-lookahead=60:vbv-maxrate=10000:vbv-bufsize=10000:qpmax=69:bframes=5:b-adapt=2:direct=auto:crf-max=51:weightp=2:merange=24:chroma-qp-offset=-1:sync-lookahead=2:psy-rd=1.00,0.15:trellis=2:min-keyint=23:partitions=all -s "1,2,3,4,5,6" 
        # AC3 surround
        HandBrakeCLI -i "$FILE" -o "$TARGET" -E ac3 -B 448k -6 5point1 -R 48 -e x264 -q 27 -x cabac=1:ref=5:analyse=0x133:me=umh:subme=9:chroma-me=1:deadzone-inter=21:deadzone-intra=11:b-adapt=2:rc-lookahead=60:vbv-maxrate=10000:vbv-bufsize=10000:qpmax=69:bframes=5:b-adapt=2:direct=auto:crf-max=51:weightp=2:merange=24:chroma-qp-offset=-1:sync-lookahead=2:psy-rd=1.00,0.15:trellis=2:min-keyint=23:partitions=all -s "1,2,3,4,5,6"
        if [ $? -eq 0 ]
        then
          rm "$FILE"
        fi
    fi
done
