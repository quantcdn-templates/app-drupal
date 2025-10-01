ARG PHP_VERSION=8.4
FROM ghcr.io/quantcdn-templates/app-apache-php:${PHP_VERSION}

# Set document root to Drupal's web directory
ENV DOCUMENT_ROOT=/opt/drupal/web

# Set working directory to Drupal root (parent of web/)
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
COPY .docker/deployment-scripts /quant/deployment-scripts

# Copy custom entrypoint scripts to Quant platform location (if any exist)
COPY .docker/quant/entrypoints/ /quant-entrypoint.d/
RUN if [ "$(ls -A /quant-entrypoint.d/)" ]; then chmod +x /quant-entrypoint.d/*; fi

# Copy custom PHP configuration files (if any exist)
COPY .docker/quant/php.ini.d/ /usr/local/etc/php/conf.d/

# Set up permissions (rarely changes)
RUN chmod +x /quant/deployment-scripts/* && \
    usermod -a -G www-data nobody && \
    usermod -a -G root nobody && \
    usermod -a -G www-data root

# Copy source code (changes frequently - do this last!)
COPY src/ /opt/drupal/

# Final setup that depends on source code
RUN set -eux; \
    chown -R www-data:www-data web/sites web/modules web/themes

# Set PATH
ENV PATH=${PATH}:/opt/drupal/vendor/bin

# Expose ports
EXPOSE 80

# Use standard Apache/PHP entrypoint (entrypoints in /quant-entrypoint.d/ run via Quant platform wrapper)
ENTRYPOINT ["docker-php-entrypoint"]
CMD ["apache2-foreground"]