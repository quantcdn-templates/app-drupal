# Drupal Template for Quant Cloud

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
| **Database** | MySQL container | Managed RDS |
| **Environment** | `docker-compose.override.yml` | Platform variables |
| **Storage** | Local volumes | EFS persistent storage |
| **Scaling** | Single container | Auto-scaling |
| **Debug** | Available via settings | Production optimized |
| **Redis Cache** | Optional (via override) | Optional (via env vars) |
| **Access** | localhost | Custom domains + CDN |

## Environment Variables

### Database Configuration (Automatic)
These are automatically provided by Quant Cloud:
- `DB_HOST` - Database host
- `DB_DATABASE` - Database name  
- `DB_USERNAME` - Database username
- `DB_PASSWORD` - Database password

### Optional Drupal Configuration
- `DB_PREFIX` - Table prefix (default: none)
- `DRUPAL_DEBUG` - Enable debug mode (default: `false`)
- `REDIS_ENABLED` - Enable Redis caching (set to `"true"` to enable)
- `REDIS_HOST` - Redis server host (default: `redis`)

The template automatically falls back to legacy `MARIADB_*` variables for backward compatibility.

### Redis Caching (Optional)

Redis can significantly improve Drupal's performance by providing fast caching. Redis is **optional** and disabled by default.

**To enable Redis:**

1. **Local Development**: Uncomment the Redis section in `docker-compose.override.yml`
2. **Production**: Set `REDIS_ENABLED=true` in your Quant Cloud environment variables
3. **Install Redis module**: `composer require drupal/redis` and enable it

If Redis is not available or fails to connect, Drupal automatically falls back to database caching.

## Drush Support

This template includes Drush (Drupal Console) pre-installed and configured.

### Local Development
```bash
docker compose exec drupal drush status
docker compose exec drupal drush cr  # Clear cache
docker compose exec drupal drush updb  # Update database
docker compose exec drupal drush cex  # Export configuration
docker compose exec drupal drush cim  # Import configuration
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
   ```bash
   docker compose exec drupal drush pm:enable module_name
   ```

3. **Export configuration**:
   ```bash
   docker compose exec drupal drush cex
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
   - For docker compose, you may see `port is already allocated`
   - If you are also running DDEV, turn it off first: `ddev poweroff`

### Logs

View container logs:
```bash
docker compose logs -f drupal
```

### Accessing the Container
```bash
docker compose exec drupal bash
```

## File Structure

```
app-drupal/
├── Dockerfile                           # Drupal image with PHP extensions
├── docker-compose.yml                   # Production/base service definition
├── docker-compose.override.yml.example  # Local development overrides template
├── .github/
│   └── workflows/
│       ├── build-deploy.yaml            # Quant Cloud ECR deployment
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
