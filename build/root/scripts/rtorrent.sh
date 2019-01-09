#!/bin/ash

if [ -f "/config/rtorrent/.session/rtorrent.lock" ]; then
	echo "[Init] Removing old rtorrent lock file"
	rm /config/rtorrent/.session/rtorrent.lock
fi

rtorrent -n -o import=/config/rtorrent/config/rtorrent.rc
