# Custom PHP Configuration

This directory is for **custom PHP configuration files** that are specific to your Drupal application.

## Important Note

The base image (`ghcr.io/quantcdn-templates/app-apache-php`) already provides optimized PHP configuration including:

- Production-ready error reporting and logging
- Optimized upload limits (128M upload, 150M post)
- Performance settings (OPcache, memory limits)
- Security configurations
- Docker-friendly logging

**You should only add custom PHP configuration here if you need application-specific settings that aren't provided by the base image.**

## Adding Custom PHP Configuration

1. Create a new `.ini` file (e.g., `90-drupal-custom.ini`)
2. Add your PHP configuration directives
3. Use numeric prefixes to control loading order:
   - `10-` - Early configuration (loaded first)
   - `50-` - Mid-stage configuration  
   - `90-` - Late configuration (overrides base settings)
   - `99-` - Final configuration (reserved for critical overrides)

## Example Custom Configuration

Create `90-drupal-custom.ini`:

```ini
; drupal-specific custom settings
; Only add settings that differ from the base image defaults

; Custom session settings for drupal
session.gc_maxlifetime = 7200
session.cookie_lifetime = 0

; drupal-specific timezone (if needed)
date.timezone = "America/New_York"

; Custom error handling for development
; (Only enable for non-production environments)
; display_errors = On
; error_reporting = E_ALL
```

## Available Settings

Common settings you might want to customize:

- `memory_limit` - Maximum memory per script (base: 256M)
- `max_execution_time` - Maximum execution time (base: optimized)
- `upload_max_filesize` - Maximum file upload size (base: 128M)
- `post_max_size` - Maximum POST data size (base: 150M)
- `session.*` - Session handling settings
- `date.timezone` - Server timezone
- Custom extension configurations

## Configuration Loading Order

Files are loaded in alphabetical order:
1. Base image configurations (10-50 range)
2. Your custom configurations (90+ range)
3. Final overrides (99 range - use sparingly)

## Best Practices

- Only override settings that you specifically need to change
- Use descriptive comments explaining why you're changing defaults
- Test configuration changes thoroughly
- Avoid conflicting with base image security settings
- Use environment-specific configurations when possible