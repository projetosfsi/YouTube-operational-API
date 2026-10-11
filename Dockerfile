FROM php:8.5.11-apache

RUN a2enmod rewrite

# Copy application files into the container
COPY . /var/www/html/

# Replace `AllowOverride None` with `AllowOverride All` in `<Directory /var/www/>` in `/etc/apache2/apache2.conf`.
RUN sed -ri -e 'N;N;N;s/(<Directory \/var\/www\/>\n)(.*\n)(.*)AllowOverride None/\1\2\3AllowOverride All/;p;d;' /etc/apache2/apache2.conf

COPY --from=composer/composer:2.10.3-bin /composer /usr/bin/composer
RUN apt update
RUN apt install -y git protobuf-compiler unzip
RUN composer install --no-dev --no-interaction
RUN protoc --php_out=proto/php/ --proto_path=proto/prototypes/ $(find proto/prototypes/ -type f)

CMD apachectl -D FOREGROUND
