FROM php:8.3-apache-bullseye

# Install system packages, PHP extensions, and tools in a single layer (rarely changes)
RUN set -eux; \
    # Enable Apache modules
    if command -v a2enmod; then \
        a2enmod rewrite; \
        a2enmod headers; \
        a2enmod proxy proxy_http; \
    fi; \
    \
    # Save package state for cleanup
    savedAptMark="$(apt-mark showmanual)"; \
    \
    # Install system packages and PHP extension dependencies
    apt-get update && apt-get install -y --no-install-recommends \
        libfreetype6-dev \
        libjpeg-dev \
        libpng-dev \
        libpq-dev \
        libwebp-dev \
        libzip-dev \
        default-mysql-client \
        vim \
        ssmtp \
        openssh-server \
        git \
        jq \
    && \
    \
    # Configure and install PHP extensions
    docker-php-ext-configure gd \
        --with-freetype \
        --with-jpeg=/usr \
        --with-webp \
    && \
    docker-php-ext-install -j "$(nproc)" \
        gd \
        opcache \
        pdo_mysql \
        pdo_pgsql \
        zip \
    && \
    \
    # Install PECL extensions
    pecl install -o -f redis apcu && \
    docker-php-ext-enable redis apcu && \
    rm -rf /tmp/pear && \
    \
    # Clean up build dependencies
    apt-mark auto '.*' > /dev/null && \
    apt-mark manual $savedAptMark && \
    ldd "$(php -r 'echo ini_get("extension_dir");')"/*.so \
        | awk '/=>/ { print $3 }' \
        | sort -u \
        | xargs -r dpkg-query -S \
        | cut -d: -f1 \
        | sort -u \
        | xargs -rt apt-mark manual && \
    apt-get purge -y --auto-remove -o APT::AutoRemove::RecommendsImportant=false && \
    rm -rf /var/lib/apt/lists/*

# Set PHP configuration (rarely changes)
RUN { \
        echo 'opcache.memory_consumption=300'; \
        echo 'opcache.interned_strings_buffer=8'; \
        echo 'opcache.max_accelerated_files=30000'; \
        echo 'opcache.revalidate_freq=60'; \
    } > /usr/local/etc/php/conf.d/opcache-recommended.ini && \
    echo 'memory_limit = 256M' >> /usr/local/etc/php/conf.d/docker-php-memlimit.ini

# Install Composer (rarely changes)
COPY --from=composer:2 /usr/bin/composer /usr/local/bin/

# Set working directory
WORKDIR /opt/drupal

# Copy dependency files and required config files first (changes occasionally)
COPY src/composer.json src/composer.lock* src/settings.php src/services.yml src/redis-unavailable.services.yml ./

# Install PHP dependencies (cached until composer files change)
RUN set -eux; \
    export COMPOSER_HOME="$(mktemp -d)"; \
    composer config apcu-autoloader true; \
    composer install --optimize-autoloader --apcu-autoloader --no-dev; \
    rm -rf "$COMPOSER_HOME"

# Copy configuration and scripts (changes occasionally)
COPY .docker/deployment-scripts /opt/deployment-scripts
COPY .docker/000-default.conf /etc/apache2/sites-enabled/000-default.conf
COPY .docker/quant/ /quant/

# Set up permissions and SSH (rarely changes)
RUN chmod +x /opt/deployment-scripts/* && \
    mkdir -p /root/.ssh && \
    mkdir -p /run/sshd && \
    usermod -a -G www-data nobody && \
    usermod -a -G root nobody && \
    usermod -a -G www-data root && \
    rmdir /var/www/html || true

# Copy source code (changes frequently - do this last!)
COPY src/ /opt/drupal/

# Final setup that depends on source code
RUN set -eux; \
    chown -R www-data:www-data web/sites web/modules web/themes; \
    ln -sf /opt/drupal/web /var/www/html

# Set PATH
ENV PATH=${PATH}:/opt/drupal/vendor/bin

# Expose ports
EXPOSE 80 22

# Set entrypoint and command
ENTRYPOINT ["/quant/entrypoints.sh", "docker-php-entrypoint"]
CMD ["apache2-foreground"]
