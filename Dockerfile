FROM debian:stretch
MAINTAINER Rolando Payán Mosqueda <rpayanm@gmail.com>
ENV DEBIAN_FRONTEND noninteractive

# Repositories
COPY ./files/sources.list /etc/apt/

# Install packages
RUN apt-get update \
&& apt-get install -y \
	nano \
	aptitude \
	locate \
	git \
	curl \
	golang \
	supervisor \
	bash-completion \
	apt-transport-https \
	lsb-release \
	ca-certificates \
	wget \
	lsb-release \
&& apt-get clean

# Add repo and intall php 7.1 and nginx
RUN wget -O /etc/apt/trusted.gpg.d/php.gpg https://packages.sury.org/php/apt.gpg \
&& sh -c 'echo "deb https://packages.sury.org/php/ $(lsb_release -sc) main" > /etc/apt/sources.list.d/php.list'
RUN apt-get update \
&& apt-get install -y \
    nginx \
    php7.1 \
    php7.1-dev \
    php7.1-fpm \
    php7.1-cli \
    php7.1-mysql \
    php7.1-gd \
    php7.1-curl \
    php7.1-soap \
    php7.1-bcmath \
    php7.1-mbstring \
    php7.1-xml \
&& apt-get clean

# PHP custom configuration
# php-fpm7.1
RUN mkdir -p /var/run/php \
&& sed -i "s#error_reporting = E_ALL & ~E_DEPRECATED & ~E_STRICT#error_reporting = E_ALL#" /etc/php/7.1/fpm/php.ini \
&& sed -i "s#display_errors = Off#display_errors = On#" /etc/php/7.1/fpm/php.ini \
&& sed -i "s#memory_limit = 128M#memory_limit = 1024M#" /etc/php/7.1/fpm/php.ini \
# Eliminada en PHP 7.0
#&& sed -i "s#;always_populate_raw_post_data = -1#always_populate_raw_post_data = -1#" /etc/php/7.1/fpm/php.ini \
&& sed -i "s#upload_max_filesize = 2M#upload_max_filesize = 100M#" /etc/php/7.1/fpm/php.ini \
&& sed -i "s#post_max_size = 8M#post_max_size = 100M#" /etc/php/7.1/fpm/php.ini \
&& sed -i "s#max_execution_time = 30#max_execution_time = 120#" /etc/php/7.1/fpm/php.ini \
# CLI
&& sed -i "s#error_reporting = E_ALL & ~E_DEPRECATED & ~E_STRICT#error_reporting = E_ALL#" /etc/php/7.1/cli/php.ini \
&& sed -i "s#display_errors = Off#display_errors = On#" /etc/php/7.1/cli/php.ini \
&& sed -i "s#upload_max_filesize = 2M#upload_max_filesize = 100M#" /etc/php/7.1/cli/php.ini \
&& sed -i "s#post_max_size = 8M#post_max_size = 100M#" /etc/php/7.1/cli/php.ini

# XDebug
RUN cd /tmp \
 && git clone https://github.com/xdebug/xdebug \
 && cd xdebug \
 && phpize \
 && ./configure --enable-xdebug \
 && make \
 && make install

# Xdebug settings for php7-fpm
COPY ./files/xdebug.ini /tmp/
RUN cat /tmp/xdebug.ini >> /etc/php/7.1/fpm/php.ini \
&& export XDEBUG_SOURCE=`find /usr/lib -name "xdebug.so"` \
&& sed -i "s#xdebug_so_path#$XDEBUG_SOURCE#" /etc/php/7.1/fpm/php.ini

# Xdebug setting for the command line
RUN cat /tmp/xdebug.ini >> /etc/php/7.1/cli/php.ini \
&& export XDEBUG_SOURCE=`find /usr/lib -name "xdebug.so"` \
&& sed -i "s#xdebug_so_path#$XDEBUG_SOURCE#" /etc/php/7.1/cli/php.ini

# nginx
COPY ./files/drupal* /etc/nginx/snippets/

# mhsendmail with Mailhog
ENV GOPATH /tmp/go
RUN go get github.com/mailhog/mhsendmail \
&& cp /tmp/go/bin/mhsendmail /usr/bin/mhsendmail \
&& echo 'sendmail_path = /usr/bin/mhsendmail --smtp-addr mailhog:1025' >> /etc/php/7.1/fpm/php.ini

# autocomplete in root
COPY ./files/autocomplete /tmp/
RUN cat /tmp/autocomplete >> /root/.bashrc && /bin/bash -c "source /root/.bashrc"

# Setup Supervisor
COPY ./files/supervisord.conf /etc/supervisor/conf.d/

# Drupal private folder
RUN mkdir /mnt/private/ \
&& chown www-data -R /mnt/private

COPY ./files/start.sh /start.sh
RUN chmod 755 /start.sh

WORKDIR /var/www/html

RUN rm -R /tmp/*

EXPOSE 80
CMD ["/bin/bash", "/start.sh"]
