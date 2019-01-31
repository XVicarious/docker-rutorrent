#!/bin/bash
config_dir=/config
rtorrent_dir="${config_dir}/rtorrent"
rtorrent_config_dir="${rtorrent_dir}/config"
rtorrent_config_file="${rtorrent_config_dir}/rtorrent.rc"
rutorrent_dir="${config_dir}/rutorrent"
nginx_dir="${config_dir}/nginx"
supervisor_dir="${config_dir}/supervisor"

# Create Dirs If they don't exist
if [ ! -d $rtorrent_config_dir ]; then
	echo "[Init] Creating rtorrent config directory"
	mkdir -p "${rtorrent_config_dir}"
fi
if [ ! -f "${rtorrent_config_file}" ]; then
	echo "[Init] Copying default rtorrent.rc file to config directory"
	cp /root/config/rtorrent.rc "${rtorrent_config_dir}"
fi
if [ ! -d $rutorrent_dir ]; then
	echo "[Init] Creating rutorrent config directory"
	mkdir -p "${rutorrent_dir}"
fi
if [ ! -d $nginx_dir ]; then
	echo "[Init] Creating nginx config directory"
	mkdir -p "${nginx_dir}"
fi
if [ ! -f "${nginx_dir}/nginx.conf" ]; then
	echo "[Init] Copying default nginx config"
	cp /root/config/nginx.conf "${nginx_dir}/"
	echo "[Init] Linking config to /etc/nginx/conf.d"
	ln -sf "${nginx_dir}/nginx.conf" /etc/nginx/conf.d/
fi
if [ ! -d $supervisor_dir ]; then
	echo "[Init] Creating supervisor directory"
	mkdir -p "${supervisor_dir}"
fi
if [ ! -d $PYRO_CONFIG_DIR ]; then
	echo "[Init] Creating pyrocore configuration"
	pyroadmin --create-config
	echo "[Init] Modifying configuration for container"
	find $PYRO_CONFIG_DIR -type f -print -exec \
		sed -i -e "s~\~\/\.rtorrent\.rc~\/config\/rtorrent\/config\/rtorrent\.rc~g" {} \;
	find $PYRO_CONFIG_DIR -type f -print -exec \
		sed -i -e "s~\~\/\.pyroscope~\/config\/pyrocore~g" {} \;
	if [ $DEBUG ]; then
		echo "[Debg] ------ Fucked Files ------"
		grep -r "~/.rtorrent.rc\|~/.pyroscope" $PYRO_CONFIG_DIR
		echo "[Debg] ---- End Fucked Files ----"
	fi
fi

chown -R supervisor:supervisor /config/supervisor
chown -R nginx:nginx /var/lib/nginx
chown -R rtorrent:rtorrent /config/rtorrent
chown -R rtorrent:rtorrent /config/pyrocore
chown -R nginx:nginx /www
chmod -R 775 /www
chmod -R 777 /www/share

/usr/bin/supervisord -c /etc/supervisor.d/supervisor.ini
