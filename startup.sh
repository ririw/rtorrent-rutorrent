#!/bin/bash

mkdir /downloads/.session && mkdir /downloads/watch && chown rtorrent:rtorrent /downloads/.session /downloads/watch && cp /downloads/.htpasswd /var/www/rutorrent/
chown rtorrent:rtorrent -R downloads

rm -f /downloads/.session/rtorrent.lock

rm -f /etc/nginx/sites-enabled/*

rm -rf /etc/nginx/ssl

rm /var/www/rutorrent/.htpasswd

# Basic auth enabled by default
site=rutorrent-basic.nginx

# Check if TLS needed
if [[ -e /root/nginx.key && -e /root/nginx.crt ]]; then
mkdir -p /etc/nginx/ssl
cp /root/nginx.crt /etc/nginx/ssl/
cp /root/nginx.key /etc/nginx/ssl/
site=rutorrent-tls.nginx
fi

cp /root/$site /etc/nginx/sites-enabled/

# Check if .htpasswd presents
if [ -e /root/.htpasswd ]; then
cp /root/.htpasswd /var/www/rutorrent/ && chmod 755 /var/www/rutorrent/.htpasswd && chown www-data:www-data /var/www/rutorrent/.htpasswd
else
# disable basic auth
sed -i 's/auth_basic/#auth_basic/g' /etc/nginx/sites-enabled/rutorrent-tls.nginx
fi


/etc/init.d/ssh start
nginx -g "daemon off;"

