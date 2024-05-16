FROM php:8.3-apache-bullseye

# NOTE: This Dockerfile is taken from the official Drupal images.
# https://github.com/docker-library/drupal/blob/6d83cf89d49b5da2608592197dcf5dcc1f233978/10.0/php8.1/apache-bullseye/Dockerfile

# install the PHP extensions we need
RUN set -eux; \
	\
	if command -v a2enmod; then \
		a2enmod rewrite; \
		a2enmod headers; \
		a2enmod proxy proxy_http; \
	fi; \
	\
	savedAptMark="$(apt-mark showmanual)"; \
	\
	apt-get update; \
	apt-get install -y --no-install-recommends \
		libfreetype6-dev \
		libjpeg-dev \
		libpng-dev \
		libpq-dev \
		libwebp-dev \
		libzip-dev \
	; \
	\
	docker-php-ext-configure gd \
		--with-freetype \
		--with-jpeg=/usr \
		--with-webp \
	; \
	\
	docker-php-ext-install -j "$(nproc)" \
		gd \
		opcache \
		pdo_mysql \
		pdo_pgsql \
		zip \
	; \
	\
# reset apt-mark's "manual" list so that "purge --auto-remove" will remove all build dependencies
	apt-mark auto '.*' > /dev/null; \
	apt-mark manual $savedAptMark; \
	ldd "$(php -r 'echo ini_get("extension_dir");')"/*.so \
		| awk '/=>/ { print $3 }' \
		| sort -u \
		| xargs -r dpkg-query -S \
		| cut -d: -f1 \
		| sort -u \
		| xargs -rt apt-mark manual; \
	\
	apt-get purge -y --auto-remove -o APT::AutoRemove::RecommendsImportant=false;

# Install redis with pecl.
RUN pecl install -o -f redis apcu \
	&&  rm -rf /tmp/pear \
	&&  docker-php-ext-enable redis apcu

# install the mysql client and other required tools
RUN apt-get install -y --no-install-recommends default-mysql-client vim ssmtp openssh-server git jq

# remove apt caches
RUN rm -rf /var/lib/apt/lists/*

# set recommended PHP.ini settings
# see https://secure.php.net/manual/en/opcache.installation.php
RUN { \
		echo 'opcache.memory_consumption=300'; \
		echo 'opcache.interned_strings_buffer=8'; \
		echo 'opcache.max_accelerated_files=30000'; \
		echo 'opcache.revalidate_freq=60'; \
	} > /usr/local/etc/php/conf.d/opcache-recommended.ini

RUN echo 'memory_limit = 256M' >> /usr/local/etc/php/conf.d/docker-php-memlimit.ini;

COPY --from=composer:2 /usr/bin/composer /usr/local/bin/

WORKDIR /opt/drupal

COPY src /opt/drupal/
COPY .docker/deployment-scripts /opt/deployment-scripts
COPY .docker/000-default.conf /etc/apache2/sites-enabled/000-default.conf
COPY .docker/quant/ /quant/

RUN chmod +x /opt/deployment-scripts/*

RUN set -eux; \
	export COMPOSER_HOME="$(mktemp -d)"; \
	composer config apcu-autoloader true; \
	composer install --optimize-autoloader --apcu-autoloader; \
	chown -R www-data:www-data web/sites web/modules web/themes; \
	rmdir /var/www/html; \
	usermod -a -G www-data nobody; \
	usermod -a -G root nobody; \
	usermod -a -G www-data root; \
	ln -sf /opt/drupal/web /var/www/html; \
	# delete composer cache
	rm -rf "$COMPOSER_HOME"

ENV PATH=${PATH}:/opt/drupal/vendor/bin

RUN mkdir -p /root/.ssh
RUN mkdir -p /run/sshd
EXPOSE 80 22

ENTRYPOINT [ "/quant/entrypoints.sh", "docker-php-entrypoint" ]
CMD ["apache2-foreground"]

# vim:set ft=dockerfile:
