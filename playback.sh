#!/usr/bin/env bash
set -euo pipefail

read -rp "YouTube URL: " URL

yt-dlp -f "ba[ext=m4a]/ba" -o "%(title)s.%(ext)s" "$URL"

IN="$(ls -t *.* | head -n 1)"
BASE="${IN%.*}"

if [[ "$IN" == *.m4a ]]; then
  echo "done: $IN (original)"
  exit 0
fi

ffmpeg -y -i "$IN" -c:a aac -b:a 320k -movflags +faststart "${BASE}.m4a"
rm -f "$IN"

echo "done: ${BASE}.m4a (re-encoded)"
