# Drupal Template for Quant Cloud

[![Deploy to Quant Cloud](https://www.quantcdn.io/img/quant-deploy-btn-sml.svg)](https://dashboard.quantcdn.io/deploy/app/app-drupal)

A production-ready Drupal template designed for deployment on Quant Cloud. This template uses a standard Drupal installation with intelligent environment variable mapping to support Quant Cloud's database configuration.

## Features

- **Drupal Latest**: Based on PHP 8.4 with all required extensions
- **Composer Managed**: Modern Drupal development with dependency management
- **Quant Cloud Integration**: Maps Quant Cloud's `DB_*` variables to Drupal standards
- **Production Ready**: Includes proper configuration, security settings, and performance optimizations
- **Drush Included**: Drupal CLI tool pre-installed and configured
- **Code Standards**: PHP CodeSniffer with Drupal coding standards included
- **CI/CD Integration**: GitHub Actions workflow for automated building and deployment
- **Multi-Registry Support**: Pushes to both GitHub Container Registry and Quant Cloud Registry
- **Database Ready**: Works with Quant Cloud's managed database service

## Deployment to Quant Cloud

This template provides two deployment options depending on your needs:

### 🚀 Quick Start (Recommended)

**Use our pre-built image** - Perfect for most users who want Drupal running quickly without customization.

1. **Import Template**: In [Quant Dashboard](https://dashboard.quantcdn.io), create a new application and import this `docker-compose.yml` directly
2. **Image Source**: The **"Public Registry"** image (`ghcr.io/quantcdn-templates/app-drupal:latest`) will automatically be provided and used by default
3. **Deploy**: Save the application - your Drupal site will be live in minutes!

**What you get:**
- ✅ Latest Drupal version
- ✅ Automatic updates via our maintained image
- ✅ Zero configuration required
- ✅ Production-ready setup
- ✅ Works with Quant Cloud's managed database

### ⚙️ Advanced (Custom Build)

**Fork and customize** - For users who need custom modules, themes, or configuration.

#### Step 1: Get the Template
- Click **"Use this template"** on GitHub, or fork this repository
- Clone your new repository locally

#### Step 2: Setup CI/CD Pipeline  
Add these secrets to your GitHub repository settings:
- `QUANT_API_KEY` - Your Quant Cloud API key
- `QUANT_ORGANIZATION` - Your organization slug (e.g., "my-company")  
- `QUANT_APPLICATION` - Your application name (e.g., "my-drupal-site")

#### Step 3: Remove Public Registry CI
Since you'll be using your own registry, delete the public build file:
```bash
rm .github/workflows/ci.yml
```

#### Step 4: Create Application
1. In Quant Cloud, create a new application 
2. Import your `docker-compose.yml`
3. Select **"Internal Registry"** when prompted
4. This will use your custom built image from the Quant Cloud private registry

#### Step 5: Deploy
- Push to `master`/`main` branch → Production deployment
- Push to `develop` branch → Staging deployment  
- Create tags → Tagged releases

**What you get:**
- ✅ Full customization control
- ✅ Your own Docker registry
- ✅ Automated builds on git push
- ✅ Staging and production environments
- ✅ Version tagging support

---

## Local Development

For both deployment options, you can develop locally using either Docker Compose or DDEV:

### Option 1: Docker Compose

1. **Clone** your repo (or this template)
2. **Install dependencies**:
   ```bash
   cd src && composer install && cd ..
   ```
3. **Use overrides** (required for local development):
   ```bash
   ls docker-compose.override.yml
   ```
   > **Note**: This override enables testing of entrypoint scripts (like `00-set-document-root.sh`) that normally run via Quant Cloud's platform wrapper. Required for proper local development environment. It also mounts your local `src/` directory for live code changes and disables opcache for faster development.
4. **Start services**:
   ```bash
   docker compose up -d
   ```
5. **Access Drupal** at http://localhost and run through installation

### Option 2: DDEV (Recommended for Developers)

1. **Clone** your repo (or this template)
2. **Install DDEV**: https://ddev.readthedocs.io/en/stable/users/install/
3. **Install dependencies**:
   ```bash
   ddev composer install
   ```
4. **Check status**:
   ```bash
   ddev status
   ```
5. **Access Drupal** at the provided DDEV URL and run through installation
6. **Use DDEV Tools**
DDEV provides additional developer tools like Xdebug, Drush integration, Redis caching, and matches production configuration exactly. See `.ddev/README.md` for details.

**Local vs Quant Cloud:**

| Feature | Local Development | Quant Cloud |
|---------|------------------|-------------|
| **Database** | MySQL container | Managed database |
| **Environment** | `docker-compose.override.yml` | Platform variables |
| **Storage** | Local volumes | Shared filesystem persistent storage (public files + private files volumes) |
| **Scaling** | Single container | Auto-scaling |
| **Debug** | Available via settings | Production optimized |
| **Redis Cache** | Optional (via override) | Optional (via env vars) |
| **Access** | localhost | Custom domains + CDN |

## Environment Variables

### Database Configuration (Automatic)
These are automatically provided by Quant Cloud:
- `DB_HOST` - Database host
- `DB_PORT` - Database port
- `DB_DATABASE` - Database name  
- `DB_USERNAME` - Database username
- `DB_PASSWORD` - Database password

### Optional Drupal Configuration
- `DB_PREFIX` - Table prefix (default: none)
- `DRUPAL_DEBUG` - Enable debug mode (default: `false`)
- `REDIS_ENABLED` - Enable Redis caching (set to `"true"` to enable)
- `REDIS_HOST` - Redis server host (default: `redis`)
- `DRUPAL_PRIVATE_PATH` - Private files directory (default: `/opt/drupal/private`)

The template automatically falls back to legacy `MARIADB_*` variables for backward compatibility.

### Redis Caching (Optional)

Redis can significantly improve Drupal's performance by providing fast caching. Redis is **optional** and disabled by default.

**To enable Redis:**

1. **Local Development**: Uncomment the Redis section in `docker-compose.override.yml`
2. **Production**: Set `REDIS_ENABLED=true` in your Quant Cloud environment variables
3. **Install Redis module**: `composer require drupal/redis` and enable it

If Redis is not available or fails to connect, Drupal automatically falls back to database caching.

> When a **managed Valkey cache** is attached to the app in Quant Cloud, the platform injects `REDIS_ENABLED=true` plus the `REDIS_HOST`/`REDIS_USER`/`REDIS_PASSWORD`/`REDIS_TLS`/`CACHE_PREFIX` variables automatically on deploy — no manual configuration needed. Without a cache attached, `REDIS_ENABLED` is unset and the app uses the database cache.

## Private files

The private file system (`private://`) lives at `/opt/drupal/private`. It sits outside the docroot (`/opt/drupal/web`), so Apache never serves it, and it does not rely on an `.htaccess` file.

- **Persistent:** `docker-compose.yml` mounts the `drupal_private` volume at that path. It survives redeploys and is shared by every container in the environment.
- **Writable:** volume files belong to UID/GID 1000, which is `www-data` in the base image.
- **Configurable:** `src/settings.php` reads `DRUPAL_PRIVATE_PATH` and falls back to `/opt/drupal/private`. With Docker Compose, the `drupal_private` named volume holds the files locally too. With DDEV the default resolves to `src/private`, which is git-ignored.
- **Backed up:** Quant Cloud filesystem backups include every volume on the environment, including this one.

Never point `file_private_path` at a directory under `sites/default/files`. That is the public files directory.

**Existing environments:** a new volume reaches an environment only when the compose file is deployed (this repo's `build-deploy.yaml` does that through `quant-cloud-compose-action`, or use the dashboard or API). A redeploy on its own does not add the volume. After the deploy, run `drush cr` so Drupal registers the `private://` stream wrapper.

**Backups:** use Quant Cloud backups (dashboard **Backups**, `qc backup create`, or `quantcdn/quant-cloud-environment-backup-action` on a schedule) for the database and files. Do not schedule modules such as backup_migrate to write database dumps into `private://`: the dumps grow without limit and sit on the same storage as the site they protect.

## Configuration files (`settings.php`)

`src/settings.php` is the **single source of truth** for Drupal configuration (trusted hosts, cache backend, database, etc.).

It is copied to `web/sites/default/settings.php` **automatically by Composer** — the `post-install-cmd`/`post-update-cmd` hooks in `src/composer.json` run `copy('settings.php', 'web/sites/default/settings.php')` (likewise for `services.yml` and `redis-unavailable.services.yml`). The Docker build relies on this: it runs `composer install`, then `COPY src/ /opt/drupal/` overlays the source tree.

**Never commit `web/sites/default/settings.php`** (it is git-ignored). A committed copy would be overlaid on top of the Composer-generated one by `COPY src/`, silently shipping a stale config — only edit `src/settings.php`, and let Composer regenerate the rest.

## Drush Support

This template includes Drush (Drupal CLI) pre-installed and configured.

### Local Development

**Docker Compose**
```bash
docker compose exec drupal drush status
docker compose exec drupal drush cr    # Clear cache
docker compose exec drupal drush updb  # Update database
docker compose exec drupal drush cex   # Export configuration
docker compose exec drupal drush cim   # Import configuration
```

**DDEV**
```bash
ddev drush status
ddev drush cr    # Clear cache
ddev drush updb  # Update database
ddev drush cex   # Export configuration
ddev drush cim   # Import configuration
```

### Quant Cloud (via SSH/exec)
```bash
drush status
drush cr
drush pm:enable module_name
drush pm:uninstall module_name
```

Drush automatically inherits the environment variables and database configuration, so it works seamlessly with both local and production environments.

## Code Standards

### Find coding standard issues

**Docker Compose**
```bash
docker compose exec drupal vendor/bin/phpcs --standard=./phpcs.xml
```

**DDEV**
```bash
ddev exec php src/vendor/bin/phpcs --standard=src/phpcs.xml
```

### Fix coding standards automatically

**Docker Compose**
```bash  
docker compose exec drupal vendor/bin/phpcbf --standard=./phpcs.xml
```

**DDEV**
```bash
ddev exec php src/vendor/bin/phpcbf --standard=src/phpcs.xml
```

## Development Workflow

### Adding Custom Modules/Themes
1. **Add to composer.json** in the `src` folder:
   ```bash
   cd src
   composer require drupal/module_name
   ```

2. **Enable the module**:

   **Docker Compose**
   ```bash
   docker compose exec drupal drush pm:enable module_name
   ```

   **DDEV**
   ```bash
   ddev drush pm:enable module_name
   ```

3. **Export configuration**:

   **Docker Compose**
   ```bash
   docker compose exec drupal drush cex
   ```

   **DDEV**
   ```bash
   ddev drush cex
   ```

### Managing Configuration
- Configuration is stored in `src/config/default`
- Export: `drush cex`
- Import: `drush cim`
- Configurations are automatically imported on deployment

## Troubleshooting

### Common Issues

1. **Database Connection Failed**
   - Check `DB_HOST`, `DB_USERNAME`, `DB_PASSWORD` values
   - Verify database service is running (Quant Cloud manages this)
   - Check network connectivity

2. **Permission Issues**
   - Ensure `src` folder has proper permissions
   - Check Docker volume mounts

3. **Module Installation Issues**
   - Run `composer install` in the `src` directory
   - Clear Drupal cache: `drush cr`
   - Check for PHP memory limits

4. **Port Conflicts**
   - For docker compose, you may see `port is already allocated` errors
   - If you are running DDEV, turn it off with `ddev poweroff`
   - If you are running another app, turn it off with `docker compose -p app-name down`

5. **`ERROR 2026 (HY000): TLS/SSL error: self-signed certificate in certificate chain` from `mysql`, `mysqldump` or Drush**
   - The base image's MariaDB client verifies the server certificate by default, and the local MySQL container uses a self-signed one. Drupal itself (PDO) still connects.
   - The override mounts `.docker/mysql-local.cnf` (`skip-ssl` for the CLI clients) and sets the `DRUSH_COMMAND_*_OPTIONS_EXTRA` variables (Drush passes its own `--defaults-file`). Copy both from `docker-compose.override.yml.example` if your override predates them.
   - This is local only. On Quant Cloud the clients verify the managed database certificate.

### Logs

**Docker Compose**
View container logs:
```bash
docker compose logs -f drupal
```

**DDEV**
```bash
ddev logs -f
```

### Accessing the Container
**Docker Compose**
```bash
docker compose exec drupal bash
```

**DDEV**
```bash
ddev ssh
```

## File Structure

```
app-drupal/
├── Dockerfile                           # Drupal image with PHP extensions
├── docker-compose.yml                   # Production/base service definition
├── docker-compose.override.yml.example  # Local development overrides template
├── .github/
│   └── workflows/
│       ├── build-deploy.yaml            # Quant Cloud container registry deployment
│       ├── ci.yml                       # GitHub Container Registry (public)
│       └── test.yaml                    # Code standards testing
├── src/                                 # Drupal codebase
│   ├── composer.json                    # PHP dependencies
│   ├── settings.php                     # Drupal configuration
│   ├── services.yml                     # Drupal services
│   └── web/                             # Web root (auto-generated)
├── quant/
│   └── meta.json                        # Template metadata
└── README.md                            # This file
```

## Contributing

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Test with both local development and Quant Cloud deployment
5. See "Code Standards" section above for checking coding standards
6. Submit a pull request

## License

This template is released under the MIT License. See LICENSE file for details.

## Support

For issues and questions:
- GitHub Issues: [Create an issue](https://github.com/quantcdn-templates/app-drupal/issues)
- Documentation: [Quant Cloud Documentation](https://docs.quantcdn.io/)
- Community: [Quant Discord](https://discord.gg/quant)
