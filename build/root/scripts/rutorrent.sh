#!/bin/sh
while [[ $(netstat -lnt | awk '$6 == "LISTEN" && $4 ~ ".5000"') == "" ]]; do
	if [ $DEBUG ]; then
		echo "[Debug] Waiting for rtorrent to listen on port 5000."
	fi
	sleep 0.1
done
echo "[Info] Starting nginx."
nginx -g "daemon off;"
