# DDEV Local Development Setup

This Drupal template includes DDEV configuration for easy local development.

## Quick Start

1. **Install DDEV**: Follow instructions at https://ddev.readthedocs.io/en/stable/users/install/
2. **Start DDEV**: `ddev start`
3. **Install dependencies**: `ddev composer install`
4. **Access your site**: DDEV will show you the URL (typically `https://drupalpod.ddev.site`)

## What's Included

### Services
- **Web**: PHP 8.3 with Nginx-FPM (matches production)
- **Database**: MariaDB 10.6 (matches production)  
- **Redis**: Redis 7 (matches production, optional caching)

### Configuration Matches Production
- **PHP settings**: Same memory limits and OPcache settings as production Dockerfile
- **Environment variables**: Uses `DB_*` variables like production
- **Redis support**: Enabled by default with `REDIS_ENABLED=true`

### Development Features
- **Xdebug**: Available via `ddev xdebug on`
- **Composer**: Integrated with `ddev composer [command]`
- **Drush**: Available via `ddev drush [command]`
- **Database**: Import/export via `ddev import-db` / `ddev export-db`

## Common Commands

```bash
# Start/stop
ddev start
ddev stop

# Composer & Drush
ddev composer install
ddev drush cr
ddev drush updb
ddev drush cex

# Database operations
ddev import-db --file=backup.sql
ddev export-db > backup.sql

# Debugging
ddev xdebug on
ddev logs -f
```

## Production Consistency

This DDEV setup mirrors the production Docker configuration:
- Same PHP version and extensions
- Same environment variable names
- Same Redis configuration (when enabled)
- Same database settings 