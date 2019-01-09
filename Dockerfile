FROM alpine:edge
MAINTAINER Brian Maurer aka XVicarious

# Install everything we need, should I build rtorrent with extra build flags?
RUN apk add --no-cache \  
        ncurses-dev zlib-dev \
        openssl-dev nghttp2-dev \
        libpsl-dev libsigc++-dev \
        c-ares-dev xmlrpc-c-dev \
        libtool gettext m4 git \
	bash build-base automake \
	autoconf linux-headers python2
WORKDIR /tmp
ENV MAKE_OPTS="-j4"
RUN git clone https://github.com/curl/curl.git &&\
    cd curl &&\
    git checkout curl-7_63_0 &&\
    ./buildconf &&\
    ./configure --enable-ares &&\
    make &&\
    make install &&\
    make DESTDIR=/tmp/root install
RUN git clone https://github.com/rakshasa/libtorrent.git &&\
    cd libtorrent &&\
    git checkout v0.13.7 &&\
    # Cherry pick the fix for openssl 1.1
    git cherry-pick -n 7b29b6bd &&\
    ./autogen.sh &&\
    ./configure &&\
    make &&\
    make install &&\
    make DESTDIR=/tmp/root install
RUN git clone https://github.com/rakshasa/rtorrent.git &&\
    cd rtorrent &&\
    git checkout v0.9.7 &&\
    ./autogen.sh &&\
    ./configure --with-xmlrpc-c &&\
    make &&\
    make install &&\
    make DESTDIR=/tmp/root install
# Get the latest ruTorrent
RUN git clone https://github.com/Novik/ruTorrent.git /tmp/root/www
RUN git clone https://github.com/pyroscope/pyrocore.git /tmp/root/opt/pyrocore
RUN rm -rf /tmp/root/usr/share/man/* /tmp/root/usr/share/include/*
FROM alpine:edge
MAINTAINER Brian Maurer aka XVicarious
COPY --from=0 /tmp/root /
RUN apk add --no-cache \
        # Webserver and PHP
        nginx php7 php7-fpm php7-json php7-curl php7-mbstring \
	# rTorrent Depends
	openssl nghttp2 libpsl libsigc++ c-ares xmlrpc-c ncurses zlib \
	# ruTorrent Plugin Deps
	mediainfo sox ffmpeg unrar \
	# Init System
	tini supervisor \
	# Pyrocore
	bash python2 git &&\
    rm -rf /usr/share/man/* /usr/share/include/*
RUN apk add --no-cache build-base linux-headers python2-dev &&\
    /opt/pyrocore/update-to-head.sh &&\
    /opt/pyrocore/bin/pip install -r /opt/pyrocore/requirements-torque.txt &&\
    rm -rf ~/.pyroscope &&\
    apk del build-base linux-headers python2-dev
RUN rm -rf /usr/share/man/* /usr/share/include/*
ENV PATH="/opt/pyrocore/bin:${PATH}"
ENV PYRO_CONFIG_DIR="/config/pyrocore"
#RUN sed -i -e "s/\#listen\-address\=/listen\-address\=127\.0\.0\.1/" /etc/dnsmasq.conf
# Change some php.ini settings
RUN sed -i -e "s~.*memory_limit\s\=\s.*~memory_limit = 512M~g" "/etc/php7/php.ini" &&\
    sed -i -e "s~.*max_execution_time\s\=\s.*~max_execution_time = 300~g" "/etc/php7/php.ini" &&\
    sed -i -e "s~.*max_file_uploads\s\=\s.*~max_file_uploads = 200~g" "/etc/php7/php.ini" &&\
    sed -i -e "s~.*max_input_vars\s\=\s.*~max_input_vars = 10000~g" "/etc/php7/php.ini" &&\
    sed -i -e "s~.*upload_max_filesize\s\=\s.*~upload_max_filesize = 20M~g" "/etc/php7/php.ini" &&\
    sed -i -e "s~.*post_max_size\s\=\s.*~post_max_size = 25M~g" "/etc/php7/php.ini"
    #sed -i -e "s~.*extension=mbstring~extension=mbstring~g" "/etc/php7/php.ini" &&\
    #sed -i -e "s~.*extension=curl~extension=curl~g" "/etc/php7/php.ini"
# make the init script executable
RUN echo "" >> /etc/php7/php-fpm.conf &&\
    echo "; Set php-fpm to use tcp/ip connection" >> /etc/php7/php-fpm.conf &&\
    echo "listen = 127.0.0.1:7777" >> /etc/php7/php-fpm.conf &&\
    # configure php-fpm listener for user nobody, group users
    echo "" >> /etc/php7/php-fpm.conf &&\
    echo "; Specify user listener owner" >> /etc/php7/php-fpm.conf &&\
    echo "listen.owner = nginx" >> /etc/php7/php-fpm.conf &&\
    echo "" >> /etc/php7/php-fpm.conf &&\
    echo "; Specify user listener group" >> /etc/php7/php-fpm.conf &&\
    echo "listen.group = users" >> /etc/php7/php-fpm.conf
RUN sed -i -r "s~\"curl\"\s+=>\s+'',~\"curl\" => '/usr/local/bin/curl',~g" "/www/conf/config.php" &&\
    sed -i -r "s~\"php\"\s+=>\s+'',~\"php\" => '/usr/bin/php',~g" "/www/conf/config.php"
# OWn these things by nginx
RUN chown -R nginx:nginx /var/lib/nginx &&\
    chown -R nginx:nginx /www &&\
    mkdir -p /run/nginx
# These programs don't make their own users
RUN adduser -D -g 'rtorrent' rtorrent &&\
    adduser -D -g 'supervisor' supervisor
# Copy the files written for the container
ADD build/ /
RUN chmod +x /root/init.sh &&\
    chmod +x /root/scripts/*
VOLUME /config
# SCGI
EXPOSE 5000
# RUTORRENT
EXPOSE 80
# TORQUE WEB UI
EXPOSE 8042
ENTRYPOINT ["/sbin/tini", "--"]
CMD ["/root/init.sh"]
