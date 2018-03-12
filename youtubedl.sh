#!/bin/bash -e
#beware, this script is ancient.. :)

[ -d $HOME/.ytdl ] || mkdir $HOME/.ytdl
[ -f $HOME/.ytdl/youtube-dl ] || wget "https://yt-dl.org/downloads/latest/youtube-dl" -O $HOME/.ytdl/youtube-dl && chmod +x $HOME/.ytdl/youtube-dl
$HOME/.ytdl/youtube-dl -U

cd /nas/media/music/youn00b/

echo "$1"   | grep '^http' && URL="$1" || URL="$(xclip -o)"
echo "$URL" | grep '^http' || { echo No URL given..; exit 1; }

YTDLARGS='-o %(title)s.%(ext)s --restrict-filenames --extract-audio --audio-format best --audio-quality 0'
#YTDLARGS='-o %(title)s.%(ext)s --restrict-filenames --extract-audio --audio-format vorbis --audio-quality 0'
TMPFILE="/tmp/$USERNAME-$(echo "$URL" | tr -dc '[[:alnum:]]').log"

tail -n 0 --retry -f "$TMPFILE" 2>/dev/null & TAILPID=$!
YTDLOUTPUT="$($HOME/.ytdl/youtube-dl $YTDLARGS "$URL" | tee "$TMPFILE")"
kill -HUP $TAILPID

# extract the filename.. (FIXME: assumption about youtube-dl status output)
ORIG="$(echo "$YTDLOUTPUT" \
    | grep "^\[download\] \|^\[avconv\] \|^\[ffmpeg\] " \
    | sed -e 's/^\[avconv\] //g' -e 's/^\[ffmpeg\] //g' -e 's/^\[download\] //g' -e 's/^Destination: //g' -e 's/ has already been downloaded$//g' \
    | tail -n 1)"
ORIGBASE="$(echo "$ORIG" | sed -e 's/\(.*\)\..*/\1/g')"
touch "$ORIGBASE".*
