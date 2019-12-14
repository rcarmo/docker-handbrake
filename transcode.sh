#!/bin/bash

if [ -z "${EXTENSION}" ]; then 
   EXTENSION=mkv
fi

if [ -z "${AUDIO_CODEC}" ]; then 
   AUDIO_CODEC=AAC
fi

if [ -z "${VIDEO_CODEC}" ]; then 
   VIDEO_CODEC=H.265
fi

export WORKDIR="$PWD"

encode_file () {
    export TARGET="${FILE%.$EXTENSION}.mp4"
    export MARKER="${FILE%.$EXTENSION}.lock"
    export LOGFILE="${FILE%.$EXTENSION}.log"
    export METADATA="${FILE%.$EXTENSION}.nfo"
    if [ "$PAUSES" != "false" ]; then 
       # Pause before check
       echo "====> Pausing" >> "$LOGFILE"  
       sleep 5
       sleep $((RANDOM % 11))
    fi
    if [ ! -e "$MARKER" ]; then
        echo `hostname` > "$MARKER"
        if [ ! -z "$SCRATCH_FOLDER" ]; then
            cp "$FILE" "$SCRATCH_FOLDER/$FILE"
            cd "$SCRATCH_FOLDER"
        fi
        echo "====> Currently in $PWD" >> "$LOGFILE"
        echo "====> $FILE -> $TARGET" >> "$LOGFILE" 
        if [ "$VIDEO_CODEC" == "H.264" ]; then
            if [ "$AUDIO_CODEC" == "AAC" ]; then
                HandBrakeCLI -i "$FILE" -o "$TARGET" -E faac -B 96k -6 stereo -R 44.1 -e x264 -q 27 -x cabac=1:ref=5:analyse=0x133:me=umh:subme=9:chroma-me=1:deadzone-inter=21:deadzone-intra=11:b-adapt=2:rc-lookahead=60:vbv-maxrate=10000:vbv-bufsize=10000:qpmax=69:bframes=5:b-adapt=2:direct=auto:crf-max=51:weightp=2:merange=24:chroma-qp-offset=-1:sync-lookahead=2:psy-rd=1.00,0.15:trellis=2:min-keyint=23:partitions=all -s "1,2,3,4,5,6" -m 2>> "$LOGFILE"  
            else
                HandBrakeCLI -i "$FILE" -o "$TARGET" -E ac3 -B 448k -6 5point1 -R 48 -e x264 -q 27 -x cabac=1:ref=5:analyse=0x133:me=umh:subme=9:chroma-me=1:deadzone-inter=21:deadzone-intra=11:b-adapt=2:rc-lookahead=60:vbv-maxrate=10000:vbv-bufsize=10000:qpmax=69:bframes=5:b-adapt=2:direct=auto:crf-max=51:weightp=2:merange=24:chroma-qp-offset=-1:sync-lookahead=2:psy-rd=1.00,0.15:trellis=2:min-keyint=23:partitions=all -s "1,2,3,4,5,6" -m 2>> "$LOGFILE"
            fi
        else
            if [ "$AUDIO_CODEC" == "AAC" ]; then
                HandBrakeCLI -i "$FILE" -o "$TARGET" --preset-import-file /h265aac.json --preset "H.265 MP4" -m 2>> "$LOGFILE"
            else
                HandBrakeCLI -i "$FILE" -o "$TARGET" --preset-import-file /h265ac3.json --preset "H.265 MP4" -m 2>> "$LOGFILE"
            fi
        fi
        if [ $? -eq 0 ]; then
            echo "====> Currently in $PWD" >> "$LOGFILE"
            rm -f "$FILE"
            rm -f "$METADATA" # remove old Plex metadata
            if [ ! -z "$SCRATCH_FOLDER" ]; then
                echo "====> Removing original file in $SCRATCH_FOLDER" >> "$LOGFILE"
                rm -f "$SCRATCH_FOLDER/$FILE"                
                echo "====> Moving new file to $WORKDIR" >> "$LOGFILE"
                mv "$SCRATCH_FOLDER/$TARGET" "$WORKDIR/$TARGET"
                cd "$WORKDIR"
                echo "====> Currently in $PWD" >> "$LOGFILE"
            fi
        fi
        echo "====> Removing lock inside $PWD" >> "$LOGFILE"
        rm -f "$MARKER"
    fi
}

if [ "$RANDOM_PICK" = true ]; then
    ls *.$EXTENSION | shuf | while read FILE; do 
        echo "====> Picked $FILE" >> "$LOGFILE"
        encode_file
        echo "====> Done encoding $FILE" >> "$LOGFILE"
    done
else
    for FILE in *.$EXTENSION; do
        echo "====> Encoding $FILE" >> "$LOGFILE"
        encode_file
        echo "====> Done encoding $FILE" >> "$LOGFILE"
    done
fi
