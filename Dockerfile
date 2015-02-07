FROM ubuntu
USER root

# add ffmpeg ppa
ADD ./jon-severinsson-ffmpeg-trusty.list /etc/apt/sources.list.d/jon-severinsson-ffmpeg-trusty.list

# install
RUN apt-get update && \
    apt-get install -y --force-yes rtorrent unzip unrar-free mediainfo curl php5-fpm php5-cli php5-geoip nginx wget ffmpeg supervisor openssh-server && \
    rm -rf /var/lib/apt/lists/*

# configure nginx
ADD rutorrent-basic.nginx /root/
ADD rutorrent-tls.nginx /root/

# Configure SSHD
ADD sshd_config /etc/ssh/sshd_config

# download rutorrent
RUN mkdir -p /var/www/rutorrent && wget http://dl.bintray.com/novik65/generic/rutorrent-3.6.tar.gz && \
    wget http://dl.bintray.com/novik65/generic/plugins-3.6.tar.gz && \
    tar xvf rutorrent-3.6.tar.gz -C /var/www && \
    tar xvf plugins-3.6.tar.gz -C /var/www/rutorrent && \
    rm *.gz
ADD ./config.php /var/www/rutorrent/conf/
RUN chown -R www-data:www-data /var/www/rutorrent

# configure rtorrent
RUN useradd -d /home/rtorrent -m -s /bin/bash rtorrent
ADD .rtorrent.rc /home/rtorrent/
RUN mkdir /home/rtorrent/.ssh
RUN chown -R rtorrent:rtorrent /home/rtorrent

# add startup script
RUN mkdir /downloads
RUN chown -R rtorrent:rtorrent /downloads
ADD startup.sh /root/

# Copy in the various keys:
ADD keys/authorized_keys /home/rtorrent/.ssh/
RUN chown -R rtorrent:rtorrent /home/rtorrent/.ssh
ADD keys/nginx.crt /root/
ADD keys/nginx.key /root/
ADD keys/htpasswd /root/.htpasswd

RUN mkdir /root/.ssh
ADD keys/authorized_keys /root/.ssh/

# configure supervisor
ADD supervisord.conf /etc/supervisor/conf.d/

EXPOSE 23
EXPOSE 80
EXPOSE 443
EXPOSE 49160
EXPOSE 49161

CMD ["supervisord"]
