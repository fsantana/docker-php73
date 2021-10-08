FROM ubuntu:18.04
LABEL maintainer="Fernando Santana <fernandosantanajr@gmail.com>"

ENV DEBIAN_FRONTEND=noninteractive

RUN apt-get update \
    && apt-get install -y curl zip unzip \
    git supervisor software-properties-common

RUN add-apt-repository -y ppa:ondrej/php

RUN curl -sL https://deb.nodesource.com/setup_12.x | bash -

RUN apt-get install -y nginx php7.3-fpm php7.3-cli \
        php7.3-curl  php7.3-mysql php7.3-mbstring \
        php7.3-xml php7.3-zip php7.3-xdebug \
        nodejs

RUN php -r "readfile('http://getcomposer.org/installer');" | php -- --install-dir=/usr/bin/ --filename=composer \
    && mkdir /run/php

RUN apt-get -y autoremove \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

RUN echo "daemon off;" >> /etc/nginx/nginx.conf \
    &&  sed -i 's/;daemonize = yes/daemonize = no/' /etc/php/7.3/fpm/php-fpm.conf

RUN ln -sf /dev/stdout /var/log/nginx/access.log \
    && ln -sf /dev/stderr /var/log/nginx/error.log

ADD supervisord.conf /etc/supervisor/conf.d/supervisord.conf

RUN usermod -u 1000 www-data

ENV npm_config_cache=/tmp/.npm

CMD ["supervisord"]
