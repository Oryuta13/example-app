FROM php:8.1-apache-buster

COPY --from=composer:2.6 /usr/bin/composer /usr/bin/composer

COPY --chown=www-data:www-data . /work/backend

RUN apt-get update && \
  apt-get -y install git libicu-dev libonig-dev libpq-dev unzip locales && \
  apt-get clean && \
  rm -rf /var/lib/apt/lists/* && \
  locale-gen en_US.UTF-8 && \
  localedef -f UTF-8 -i en_US en_US.UTF-8 && \
  a2enmod rewrite && \
  docker-php-ext-install intl pdo_mysql zip bcmath pdo_pgsql && \
  composer config -g process-timeout 3600 && \
  composer config -g repos.packagist composer https://packagist.org


COPY ./php.ini /usr/local/etc/php/php.ini
COPY ./httpd.conf /etc/apache2/sites-available/000-default.conf

WORKDIR /work/backend

RUN pwd
RUN ls -l
RUN chmod -R 777 storage/ bootstrap/cache

RUN php artisan cache:clear
RUN php artisan config:cache