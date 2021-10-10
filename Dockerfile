FROM php:7.4-apache

# Build Environment Variables

COPY btc_chargers.tar.gz /tmp

# Install Base
RUN apt-get update

# Install & Setup Dependencies
RUN set -ex; \
    apt-get install -y curl iputils-ping; \
    apt-get install -y zip unzip git; \
    #docker-php-ext-configure gd --with-freetype-dir=/usr --with-jpeg-dir=/usr --with-webp-dir=/usr --with-png-dir=/usr --with-xpm-dir=/usr; \
    docker-php-ext-install pdo pdo_mysql mysqli sockets; \
    apt-get clean -y; \
    rm -rf /var/lib/apt/lists/*; \
    curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/local/bin --filename=composer

# Expose Ports
EXPOSE 80


ENV MYSQL_HOST database
ENV MYSQL_USER root
ENV MYSQL_PASSWORD root
ENV MYSQL_DATABASE btc_chargers
ENV MYSQL_DATABASE_PREFIX btc_

# Time Zone
ENV PHP_TIME_ZONE 'Asia/Kolkata'
RUN mv "$PHP_INI_DIR/php.ini-production" "$PHP_INI_DIR/php.ini"
RUN sed -i 's/;date.timezone =/date.timezone = "${PHP_TIME_ZONE}"/g' "$PHP_INI_DIR/php.ini"
# RUN php -i | grep -i error

# Extract Repo HTML Files
ADD  web_socket_chargers.tar.gz /root 
CMD ["cd /root"]
# Composer install dependencies
#RUN set -ex; \
#  cd /usr/local/bin; \
RUN composer install --no-dev -o

# Add Entrypoint & Start Commands

ENTRYPOINT ["php app.php"]
