FROM php:8.2-apache

RUN docker-php-ext-install pdo_mysql mysqli mbstring exif pcntl bcmath gd \
    && a2enmod rewrite headers expires

COPY docker/apache-vhost.conf /etc/apache2/sites-available/000-default.conf
COPY . /var/www/html/

RUN chown -R www-data:www-data /var/www/html \
    && find /var/www/html -type d -exec chmod 755 {} \; \
    && find /var/www/html -type f -exec chmod 644 {} \; \
    && chmod 775 /var/www/html/install /var/www/html/assets/img /var/www/html/assets/img/article

EXPOSE 80
CMD ["apache2-foreground"]
