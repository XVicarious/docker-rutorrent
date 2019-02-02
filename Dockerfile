FROM bmaurer/alpine-builder
MAINTAINER Brian Maurer aka XVicarious
RUN apk add --no-cache go
RUN mkdir -p /tmp/gopath /tmp/root/usr/local/bin
RUN GOPATH=/tmp/gopath go get -u github.com/ochinchina/supervisord
RUN cp /tmp/gopath/bin/supervisord /tmp/root/usr/local/bin/
#RUN upx --best --ultra-brute /tmp/root/usr/local/bin/supervisord
RUN git clone --depth 1 --single-branch --branch master https://github.com/Novik/ruTorrent.git /tmp/root/www
FROM alpine:3.8
MAINTAINER Brian Maurer aka XVicarious
RUN apk add --no-cache \
        nginx php7 php7-fpm php7-json php7-curl php7-mbstring \
	mediainfo sox ffmpeg unrar curl ca-certificates tini &&\
    rm /etc/nginx/conf.d/default.conf
COPY --from=0 /tmp/root /
RUN green='\033[0;32m' && endc='\033[0m' &&\
    printf "[Build] ${green}Modifying php.ini${endc}\n" &&\
    sed -i -e "s~.*memory_limit\s\=\s.*~memory_limit = 512M~g" "/etc/php7/php.ini" &&\
    sed -i -e "s~.*max_execution_time\s\=\s.*~max_execution_time = 300~g" "/etc/php7/php.ini" &&\
    sed -i -e "s~.*max_file_uploads\s\=\s.*~max_file_uploads = 200~g" "/etc/php7/php.ini" &&\
    sed -i -e "s~.*max_input_vars\s\=\s.*~max_input_vars = 10000~g" "/etc/php7/php.ini" &&\
    sed -i -e "s~.*upload_max_filesize\s\=\s.*~upload_max_filesize = 20M~g" "/etc/php7/php.ini" &&\
    sed -i -e "s~.*post_max_size\s\=\s.*~post_max_size = 25M~g" "/etc/php7/php.ini" &&\
    #sed -i -e "s~.*extension=mbstring~extension=mbstring~g" "/etc/php7/php.ini" &&\
    #sed -i -e "s~.*extension=curl~extension=curl~g" "/etc/php7/php.ini"
    printf "[Build] ${green}Modifying php-fpm.conf${endc}\n" &&\
    echo "" >> /etc/php7/php-fpm.conf &&\
    echo "; Set php-fpm to use tcp/ip connection" >> /etc/php7/php-fpm.conf &&\
    echo "listen = 127.0.0.1:7777" >> /etc/php7/php-fpm.conf &&\
    # configure php-fpm listener for user nobody, group users
    echo "" >> /etc/php7/php-fpm.conf &&\
    echo "; Specify user listener owner" >> /etc/php7/php-fpm.conf &&\
    echo "listen.owner = nginx" >> /etc/php7/php-fpm.conf &&\
    echo "" >> /etc/php7/php-fpm.conf &&\
    echo "; Specify user listener group" >> /etc/php7/php-fpm.conf &&\
    echo "listen.group = users" >> /etc/php7/php-fpm.conf &&\
    printf "[Build] ${green}Modifying rutorrent's config.php${endc}\n" &&\
    sed -i -r "s~scgi_port\s=\s5000~scgi_port = 0~g" "/www/conf/config.php" &&\
    sed -i -r "s~scgi_host\s=\s\"127.0.0.1\"~scgi_host = \"unix:///config/rpc.socket\"~g" "/www/conf/config.php" &&\
    sed -i -r "s~\"curl\"\s+=>\s+'',~\"curl\" => '/usr/local/bin/curl',~g" "/www/conf/config.php" &&\
    sed -i -r "s~\"php\"\s+=>\s+'',~\"php\" => '/usr/bin/php',~g" "/www/conf/config.php"
# OWn these things by nginx
RUN chown -R nginx:nginx /var/lib/nginx &&\
    chown -R nginx:nginx /www &&\
    mkdir -p /run/nginx
# Copy the files written for the container
ADD build/ /
RUN chmod +x /bin/rutorrent.sh
VOLUME /config
EXPOSE 80
ENTRYPOINT ["/sbin/tini", "--", "supervisord"]
