#!/bin/sh
config_dir=/config
rtorrent_dir="${config_dir}/rtorrent"
rtorrent_config_dir="${rtorrent_dir}/config"
rtorrent_config_file="${rtorrent_config_dir}/rtorrent.rc"
rutorrent_dir="${config_dir}/rutorrent"
nginx_dir="${config_dir}/nginx"
supervisor_dir="${config_dir}/supervisor"

# Create Dirs If they don't exist
if [ ! -d $rtorrent_config_dir ]; then
	mkdir -p "${rtorrent_config_dir}"
fi
if [ ! -f "${rtorrent_config_file}" ]; then
	cp /root/rtorrent.rc "${rtorrent_config_dir}"
fi
if [ ! -d $rutorrent_dir ]; then
	mkdir -p "${rutorrent_dir}"
fi
if [ ! -d $nginx_dir ]; then
	mkdir -p "${nginx_dir}"
fi
if [ ! -d $supervisor_dir ]; then
	mkdir -p "${supervisor_dir}"
fi
if [ ! -d $PYRO_CONFIG_DIR ]; then
	pyroadmin --create-config
fi

cp /root/rtorrent-pyro.rc /config/pyrocore/

chown -R supervisor:supervisor /config/supervisor
chown -R nginx:nginx /var/lib/nginx
chown -R rtorrent:rtorrent /config/rtorrent
chown -R rtorrent:rtorrent /config/pyrocore
chown -R nginx:nginx /www
chmod -R 775 /www
chmod -R 777 /www/share

/usr/bin/supervisord -c /etc/supervisor.d/supervisor.ini
