#!/bin/bash -e
tmp="/dev/shm"
dst="/nas/media/music/youn00b/"
ytdir="$HOME/.ytdl"

ytargs="--no-playlist --extract-audio --no-mtime"
ytargs+=" --audio-format best --audio-quality 0 --write-all-thumbnails"

[ -d "$ytdir" ] \
	|| mkdir "$ytdir"
[ ! -f "$ytdir"/youtube-dl ] \
	&& wget "https://yt-dl.org/downloads/latest/youtube-dl" \
			-O "$ytdir"/youtube-dl \
	&& chmod +x "$ytdir"/youtube-dl \
	|| "$ytdir"/youtube-dl -U

echo "$1" | grep '^http' \
	&& url="$1" \
	|| url="$(xclip -o)"
echo "$url" | grep '^http' \
	|| { echo No url given..; exit 0; }

filt()
{
	tr -dc "[:alnum:]\n _-" \
		| sed -e 's/ \+/_/g' \
			-e 's/[_-]\+$//' \
			-e 's/^[_-]\+//' \
		| tr "[:upper:]" "[:lower:]"
}

title=$("$ytdir"/youtube-dl --no-playlist --get-title "$url" | filt)
"$ytdir"/youtube-dl -o "$tmp/$title.%(ext)s" $ytargs "$url" --exec \
	'bs1770gain -o '"$dst"' --replaygain'

