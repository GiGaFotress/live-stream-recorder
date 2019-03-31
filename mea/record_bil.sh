#!/bin/bash
# General Live Stream Recorder Powered by Streamlink

if [[ ! -n "$1" ]]; then
  echo "usage: $0 live_url [format] [loop|once] [interval]"
  exit 1
fi

# Record the highest quality available by default
FORMAT="${2:-best}"
INTERVAL="${4:-10}"

while true; do
  # Monitor live streams of specific channel
  while true; do
    LOG_PREFIX=$(date +"[%Y-%m-%d %H:%M:%S]")
    echo "$LOG_PREFIX Try to get current live stream of $1"

    # Get the m3u8 or flv address with streamlink
    STREAM_URL=$(streamlink --stream-url "$1" "$FORMAT")
    (echo "$STREAM_URL" | grep -q ".m3u8") && break
    (echo "$STREAM_URL" | grep -q ".flv") && break

    echo "$LOG_PREFIX The stream is not available now."
    echo "$LOG_PREFIX Retry after $INTERVAL seconds..."
    sleep $INTERVAL
  done

  # Record using MPEG-2 TS format to avoid broken file caused by interruption
  FNAME="bilibili_$(date +"%Y%m%d_%H%M%S").ts"
  echo "$LOG_PREFIX Start recording, stream saved to \"$FNAME\"."
  echo "$LOG_PREFIX Use command \"tail -f $FNAME.log\" to track recording progress."

  # Start recording
    streamlink --hls-live-restart --loglevel trace -o "/home/centos/live-stream-recorder/savevideo/mea/$FNAME" \
    "$1" "$FORMAT" > "$FNAME" 2>&1

  # Exit if we just need to record current stream
  LOG_PREFIX=$(date +"[%Y-%m-%d %H:%M:%S]")
  echo "$LOG_PREFIX Live stream recording stopped."
  [[ "$3" == "once" ]] && break
done
