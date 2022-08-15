FROM php:8.1.8-fpm as php81
WORKDIR /usr/share/nginx/html

# Update system.
RUN apt-get update

# Install libraries.
RUN apt-get -y install wget git zip unzip libpq-dev librabbitmq-dev libssh-dev gcc make autoconf libc-dev pkg-config libssl-dev

# Change SSL security level to one more permissive. Some HTTP APIs fails at SECLEVEL=2.
RUN sed -i 's/DEFAULT@SECLEVEL=2/DEFAULT@SECLEVEL=1/g' /etc/ssl/openssl.cnf

ADD https://github.com/mlocati/docker-php-extension-installer/releases/latest/download/install-php-extensions /usr/local/bin/
RUN chmod +x /usr/local/bin/install-php-extensions

# Install xdebug.
RUN pecl install xdebug \
    && docker-php-ext-enable xdebug

# Install PHP extensions.
RUN docker-php-ext-install pdo pdo_pgsql bcmath sockets pdo_mysql
RUN install-php-extensions amqp
RUN install-php-extensions redis

# Install Composer
RUN curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/local/bin --filename=composer

RUN curl -sS https://get.symfony.com/cli/installer | bash
RUN mv /root/.symfony/bin/symfony /usr/local/bin/symfony
