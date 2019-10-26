FROM php:7.1-apache


RUN apt-get update \
    && apt-get install -y \
    graphviz \
    libmcrypt-dev \
    libpng-dev \
    libgmp-dev \
    libzip-dev \
    libc-client-dev \
    libkrb5-dev \
    libldap2-dev \
    vim \
    git \
    --no-install-recommends

RUN apt-get clean \
    && apt-get -y autoremove \
    && rm -rf /var/lib/apt/lists/*

RUN adduser sugar --disabled-password --disabled-login --gecos ""

RUN echo 'date.timezone = GMT' >> /usr/local/etc/php/conf.d/docker.ini \
    && echo 'error_reporting = E_ALL \& ~E_NOTICE \& ~E_STRICT \& ~E_DEPRECATED' >> /usr/local/etc/php/conf.d/docker.ini \
    && echo 'error_log = /var/log/apache2/error.log' >> /usr/local/etc/php/conf.d/docker.ini \
    && echo 'log_errors = On' >> /usr/local/etc/php/conf.d/docker.ini \
    && echo 'display_errors = Off' >> /usr/local/etc/php/conf.d/docker.ini \
    && echo 'memory_limit = 512M' >> /usr/local/etc/php/conf.d/docker.ini \
    && echo 'post_max_size = 100M' >> /usr/local/etc/php/conf.d/docker.ini \
    && echo 'upload_max_filesize = 100M' >> /usr/local/etc/php/conf.d/docker.ini \
    && echo 'max_execution_time = 600' >> /usr/local/etc/php/conf.d/docker.ini \
    && echo 'max_input_time = 600' >> /usr/local/etc/php/conf.d/docker.ini \
    && echo 'realpath_cache_size = 4096K' >> /usr/local/etc/php/conf.d/docker.ini \
    && echo 'realpath_cache_ttl = 600' >> /usr/local/etc/php/conf.d/docker.ini \
    && echo 'mbstring.func_overload = 0' >> /usr/local/etc/php/conf.d/docker.ini \
    && echo 'session.use_cookies = 1' >> /usr/local/etc/php/conf.d/docker.ini \
    && echo 'session.cookie_httponly = 1' >> /usr/local/etc/php/conf.d/docker.ini \
    && echo 'session.use_trans_sid = 0' >> /usr/local/etc/php/conf.d/docker.ini \
    && echo 'session.save_handler = files' >> /usr/local/etc/php/conf.d/docker.ini \
    && echo 'session.save_path = "/var/www/html/sessioni"' >> /usr/local/etc/php/conf.d/docker.ini

COPY config/apache2/mods-available/deflate.conf /etc/apache2/mods-available/deflate.conf
COPY config/apache2/sites-available/sugar.conf /etc/apache2/sites-available/sugar.conf
COPY config/apache2/ports.conf /etc/apache2/ports.conf


RUN set -ex \
    && . "/etc/apache2/envvars" \
    && ln -sfT /dev/stderr "$APACHE_LOG_DIR/error.log" \
    && ln -sfT /dev/stdout "$APACHE_LOG_DIR/access.log" \
    && ln -sfT /dev/stdout "$APACHE_LOG_DIR/other_vhosts_access.log" \
    && a2enmod headers expires deflate rewrite \
    && sed -i "s#Timeout .*#Timeout 600#" /etc/apache2/apache2.conf \
    # && sed -i "s#Listen 80 .*#Listen 8080#" /etc/apache2/ports.conf \
    && a2dissite 000-default \
    && a2ensite sugar 

RUN docker-php-ext-install mysqli \
    && docker-php-ext-install mcrypt \
    && docker-php-ext-install bcmath \
    && docker-php-ext-install gd \
    && docker-php-ext-install gmp \
    && docker-php-ext-configure imap --with-kerberos --with-imap-ssl \
    && docker-php-ext-install imap \
    && docker-php-ext-install zip \
    && docker-php-ext-install ldap 
    # && pecl install xdebug \
    # && pecl install redis \
    # && docker-php-ext-enable redis

# disable by default, it can be enabled locally
#COPY config/php/mods-available/xdebug.ini /usr/local/etc/php/conf.d/xdebug.ini
COPY config/php/mods-available/opcache.ini /usr/local/etc/php/conf.d/opcache.ini
COPY config/php/opcache-blacklist /usr/local/etc/php/opcache-blacklist

ENV REPO_SUGAR https://github.com/stefanos87/empty
 

# RUN git clone ${REPO_SUGAR} /sugarsource
# RUN mkdir /sugarsource/sessioni
# RUN chmod -R 777 /var
# RUN chown -R sugar:sugar /sugarsource


# COPY config/apache2/info.php /sugarsource
COPY config/apache2/copyfileinvolumes.sh /usr/local/bin/copyfileinvolumes.sh
RUN chmod +x /usr/local/bin/copyfileinvolumes.sh
# RUN chmod +x /usr/local/bin/sugarfixpermissions
#COPY config/apache2/.htaccess /var/www/html/.htaccess

# RUN sugarfixpermissions

# RUN find /var/www/html -type d -exec chmod 775 {} \;
# RUN find /var/www/html -type f -exec chmod 664 {} \;
# RUN chmod 770 /var/www/html/bin/sugarcrm


# VOLUME /var/www/html

EXPOSE 8080


ENV APACHE_RUN_USER sugar
ENV APACHE_RUN_GROUP sugar

USER sugar
WORKDIR "/var/www/html"


#RUN copyfileinvolumes.sh
# ENTRYPOINT [ "httpd", "-k", "start"]
# RUN service apache2 start


# ENTRYPOINT copyfileinvolumes.sh && apachectl -D FOREGROUND


# ENTRYPOINT ["apachectl", "-D", "FOREGROUND"]
# CMD ["&&", "copyfileinvolumes.sh" ]
ENTRYPOINT ["copyfileinvolumes.sh"]
