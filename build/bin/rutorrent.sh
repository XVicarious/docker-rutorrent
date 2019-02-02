#!/bin/sh
nginx_dir="/config/nginx"
rutorrent_dir="/config/rutorrent"
supervisor_dir="/config/supervisor"
if [ ! -d $nginx_dir ]; then
	echo "[Init] Creating nginx config directory"
	mkdir -p $nginx_dir
fi
if [ ! -f "${nginx_dir}/nginx.conf" ]; then
	echo "[Init] Copying default nginx config"
	cp /root/config/nginx.conf $nginx_dir
fi
if [ ! -f "/etc/nginx/conf.d/nginx.conf" ]; then
	echo "[Init] Linking config to /etc/nginx/conf.d"
	ln -sf "${nginx_dir}/nginx.conf" /etc/nginx/conf.d/
fi
echo "[Info] Starting nginx."
nginx -g "daemon off;"
