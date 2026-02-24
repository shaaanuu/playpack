# playpack

A minimal, POSIX-compliant Bash script to archive YouTube audio in its highest native fidelity. In m4a.

### Core Philosophy

* **Zero Transcoding:** Audio is never re-encoded. No generation loss.
* **Format Priority:** Strictly targets YouTube's best audio streams:
1. **Opus** (Format 251, ~160kbps)
2. **AAC** (Format 140, ~128kbps)


* **Strict Output:** Every file is wrapped in an `.m4a` (MPEG-4 Part 14) container for clean library management.

### Dependencies

* `yt-dlp`
* `ffmpeg`
* `ffprobe`

### Usage

1. Make the script executable:
```bash
chmod +x playback.sh
```

2. Run it:
```bash
./playback.sh
```

3. Then simply give the URL (both playlist and single is supported).

### Technical Implementation

The script uses a temporary staging area to download the raw streams. It then uses `ffmpeg` with the `-c:a copy` flag. This "remuxing" process is nearly instantaneous and ensures the output file is a bit-for-bit duplicate of the source audio. (That's what the Ai said...)

To support high-fidelity Opus streams within the `.m4a` extension, the script forces the standard MP4 muxer (`-f mp4`), ensuring compatibility with all modern media players. (This too, from Ai)

