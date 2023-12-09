#!/bin/bash

shopt -s nullglob

VAINFO_RESULT=$(vainfo)
    echo "====> vainfo output:" >> "$LOGFILE"
    echo "${VAINFO_RESULT}" >> "$LOGFILE"

if [ -z "${QSV}" ]; then     
    if [[ $VAINFO_RESULT == *"Intel iHD driver"* ]]; then
       sed -i 's/"VideoEncoder" : "x265/"VideoEncoder" : "qsv_h265/g' /presets/*.json
       sed -i 's/"VideoQSVDecode" : false,/"VideoQSVDecode" : true,/g' /presets/*.json
    fi
fi

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

detect_hdr () {
    PROBE_RESULT=$(ffprobe -show_streams -v error "${FILE}" | egrep "^color_transfer|^color_space=|^color_primaries=" | head -3)
    for C in $PROBE_RESULT; do
        if [[ "$C" = "color_space="* ]]; then
                COLOR_SPACE=${C##*=}
        elif [[ "$C" = "color_transfer="* ]]; then
                COLOR_TRANSFER=${C##*=}
        elif [[ "$C" = "color_primaries="* ]]; then
                COLOR_PRIMARIES=${C##*=}
        fi      
    done    
    if [ "${COLOR_SPACE}" = "bt2020nc" ] && [ "${COLOR_TRANSFER}" = "smpte2084" ] && [ "${COLOR_PRIMARIES}" = "bt2020" ]; then 
        echo "====> $FILE is considered to be HDR" >> "$LOGFILE"
        PRESET_SUFFIX="_hdr"
    else
        PRESET_SUFFIX=""
    fi
}

encode_file () {
    # These might be needed by sub-shells
    export TARGET="${FILE%.$EXTENSION}.mp4"
    export MARKER="${FILE%.$EXTENSION}.lock"
    export LOGFILE="$WORKDIR/${FILE%.$EXTENSION}.log"
    export METADATA="${FILE%.$EXTENSION}.nfo"
    if [ "$PAUSES" != "false" ]; then 
       # Pause before check
       sleep 5
       sleep $((RANDOM % 11))
    fi
    if [ ! -f "$MARKER" ]; then
        echo "====> Processing $FILE" >> "$LOGFILE"
        echo "$HOSTNAME" > "$MARKER"
        if [ ! -z "$SCRATCH_FOLDER" ]; then
            echo "====> Copying $FILE to $SCRATCH_FOLDER" >> "$LOGFILE"
            cp "$FILE" "$SCRATCH_FOLDER/$FILE"
            cd "$SCRATCH_FOLDER"
        fi
        echo "====> Currently in $PWD" >> "$LOGFILE"
        detect_hdr
        echo "====> Transcoding $FILE -> $TARGET" >> "$LOGFILE" 
        if [ "$VIDEO_CODEC" == "H.264" ]; then
            if [ "$AUDIO_CODEC" == "AAC" ]; then
                stdbuf -oL -eL HandBrakeCLI -i "$FILE" -o "$TARGET" -E faac -B 96k -6 stereo -R 44.1 -e x264 -q 27 -x cabac=1:ref=5:analyse=0x133:me=umh:subme=9:chroma-me=1:deadzone-inter=21:deadzone-intra=11:b-adapt=2:rc-lookahead=60:vbv-maxrate=10000:vbv-bufsize=10000:qpmax=69:bframes=5:b-adapt=2:direct=auto:crf-max=51:weightp=2:merange=24:chroma-qp-offset=-1:sync-lookahead=2:psy-rd=1.00,0.15:trellis=2:min-keyint=23:partitions=all -s "1,2,3,4,5,6" -m 2>> "$LOGFILE"  
            else
                stdbuf -oL -eL HandBrakeCLI -i "$FILE" -o "$TARGET" -E ac3 -B 448k -6 5point1 -R 48 -e x264 -q 27 -x cabac=1:ref=5:analyse=0x133:me=umh:subme=9:chroma-me=1:deadzone-inter=21:deadzone-intra=11:b-adapt=2:rc-lookahead=60:vbv-maxrate=10000:vbv-bufsize=10000:qpmax=69:bframes=5:b-adapt=2:direct=auto:crf-max=51:weightp=2:merange=24:chroma-qp-offset=-1:sync-lookahead=2:psy-rd=1.00,0.15:trellis=2:min-keyint=23:partitions=all -s "1,2,3,4,5,6" -m 2>> "$LOGFILE"
            fi
        else
            if [ "$AUDIO_CODEC" == "AAC" ]; then
                stdbuf -oL -eL HandBrakeCLI -i "$FILE" -o "$TARGET" --preset-import-file /presets/h265aac${PRESET_SUFFIX}.json --preset "H.265 MP4" -m 2>> "$LOGFILE"
            else
                stdbuf -oL -eL HandBrakeCLI -i "$FILE" -o "$TARGET" --preset-import-file /presets/h265ac3${PRESET_SUFFIX}.json --preset "H.265 MP4" -m 2>> "$LOGFILE"
            fi
        fi
        echo "====> Testing $TARGET" >> "$LOGFILE"
        stdbuf -oL -eL ffprobe "$TARGET" 2>> "$LOGFILE"
        if [ $? -eq 0 ]; then
            if [ ! -z "$SCRATCH_FOLDER" ]; then
                echo "====> Removing original file in $SCRATCH_FOLDER" >> "$LOGFILE"
                rm -f "$SCRATCH_FOLDER/$FILE"
                echo "====> Moving new file $TARGET to $WORKDIR" >> "$LOGFILE"
                mv "$SCRATCH_FOLDER/$TARGET" "$WORKDIR/$TARGET"
            fi
            echo "====> Transcoding successful, removing $FILE" >> "$LOGFILE"
            rm -f "$WORKDIR/$FILE"
            echo "====> Done encoding $FILE" >> "$LOGFILE"
        else
            if [ ! -z "$SCRATCH_FOLDER" ]; then
               echo "====> Removing entire folder $SCRATCH_FOLDER" >> "$LOGFILE"
               rm -f "$SCRATCH_FOLDER"
            fi
            rm -f "$WORKDIR/$TARGET"
            echo "====> Failed to encode $FILE" >> "$LOGFILE"
        fi
        cd "$WORKDIR"
        echo "====> Removing lock and Plex metadata inside $PWD" >> "$LOGFILE"
        rm -f "$MARKER"
        rm -f "$METADATA"
    fi
}

if [ "$RANDOM_PICK" = true ]; then
    ls *.$EXTENSION | shuf | while read FILE; do 
        encode_file
    done
else
    for FILE in *.$EXTENSION; do
        encode_file
    done
fi
