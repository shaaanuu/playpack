#!/usr/bin/env bash

set -euo pipefail

# --- Configuration ---
WORK_DIR=$(mktemp -d)
trap 'rm -rf "$WORK_DIR"' EXIT

check_deps() {
    for tool in yt-dlp ffmpeg ffprobe; do
        if ! command -v "$tool" >/dev/null 2>&1; then
            echo "Error: $tool is not installed." >&2
            exit 1
        fi
    done
}

process_file() {
    local input_file="$1"
    local filename=$(basename "$input_file")
    local base_name="${filename%.*}"
    
    # Detect Source Codec
    local codec=$(ffprobe -v error -select_streams a:0 -show_entries stream=codec_name -of default=noprint_wrappers=1:nokey=1 "$input_file")
    local final_output="${base_name}.m4a"
    
    if [[ -f "$final_output" ]]; then
        echo "Skipping: $final_output (exists)"
        return
    fi

    # The Pure Remux Command
    # -c:a copy: Bit-perfect stream duplication
    # -f mp4: Forces standard container support for Opus
    # -strict -2: Allows experimental codec mapping
    ffmpeg -i "$input_file" -vn -hide_banner -loglevel error -c:a copy -f mp4 -strict -2 "$final_output"
    
    local size=$(du -sh "$final_output" | cut -f1)
    echo "Done: $final_output [$codec] ($size)"
}

# --- Main ---

check_deps

URL="${1:-}"
if [[ -z "$URL" ]]; then
    read -p "Enter YouTube URL: " URL
fi

echo "Downloading best available audio bitstream..."

# f 251/140: Prioritize Opus (251) then AAC (140)
yt-dlp -f "251/140/bestaudio" \
    --extract-audio \
    --output "$WORK_DIR/%(playlist_index|0)s - %(title)s.%(ext)s" \
    --restrict-filenames \
    --no-continue \
    "$URL"

# Safe loop for file processing
while IFS= read -r -d '' file; do
    process_file "$file"
done < <(find "$WORK_DIR" -type f -not -name ".*" -print0)

echo "Library synchronization complete."