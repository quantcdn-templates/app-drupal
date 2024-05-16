# Drupal QuantCDN starter template

This template provides everything you need to get started with [Drupal](https://www.drupal.com/) on QuantCDN.

Click the "Deploy to Quant" button to create a new GitHub repository, QuantCDN project, and deployment pipelines.

[![Deploy to Quant](https://www.quantcdn.io/img/quant-deploy-btn-sml.svg)](https://dashboard.quantcdn.io/deploy/step-one?template=app-drupal)

[![Open in Gitpod](https://gitpod.io/button/open-in-gitpod.svg)](https://gitpod.io/#https://github.com/quantcdn-templates/app-drupal)


### Build & test locally

#### Installation

This is a composer-managed codebase. In the `src` folder simply run `composer install` to install all required dependencies.

#### Build & test in docker container

To test the same container that gets deployed to Quant Cloud, run the following:
```
docker-compose up
```

The application will be available at `http://localhost:80`.

To import a MySQL database run `docker-compose exec -T app drush sqlc < /path/to/database.sql`.

Changes to the codebase in `src` will be reflected immediately.

### Deployment & Management

This template automatically preconfigures your CI pipeline to deploy to Quant. This means you simply need to edit the codebase in the `src` folder and commit changes to trigger the build & deploy process.

#### Post-deployment script

To run processes after a deployment completes (e.g cache rebuild, configuration import) you may modify the contents of the `.docker/deployment-scripts/post-deploy.sh` script.

#### Cron Jobs

Cron jobs will run on a schedule as defined in the `.github/workflows/cron.yaml` file. By default they will run once every 3 hours.

To modify the processes that run during cron you may modify the contents of the `.docker/deployment-scripts/cron.sh` script.

#### Database backups

To take a database backup navigate to your GitHub actions page > Database backup > Run workflow. The resulting database dump will be attached as a CI artefact for download.

#### Managing settings.php and services.yml

Modify the `settings.php` and `services.yml` files provided in the `src` folder to make changes. These files are automatically added to the appropriate location in the Drupal webroot via Composer:
```
    "scripts": {
        "post-install-cmd": [
            "@php -r \"copy('settings.php', 'web/sites/default/settings.php');\"",
            "@php -r \"copy('services.yml', 'web/sites/default/services.yml');\""
        ]
    }
```

The `settings.php` file comes preloaded with important values required for operation on Quant Cloud. If you replace this file please ensure you account for the inclusions below.

**Database connection:**
```
$databases['default']['default'] = [
    'database' => getenv('MARIADB_DATABASE'),
    'username' => getenv('MARIADB_USER'),
    'password' => getenv('MARIADB_PASSWORD'),
    'host' => getenv('MARIADB_HOST'),
    'port' => getenv('MARIADB_PORT') ?: 3306,
    'driver' => 'mysql',
    'prefix' => getenv('MARIADB_PREFIX') ?: '',
    'collation' => 'utf8mb4_general_ci',
];
```

**Configuration directory:**
```
$settings['config_sync_directory'] = '../config/default';
```

**Hash salt:**
```
$settings['hash_salt'] = getenv('MARIADB_DATABASE');
```

**Trusted host patterns:**
```
$settings['trusted_host_patterns'] = [
  '\.apps\.quant\.cloud$',
];
```

**Reverse proxy:**
```
$settings['reverse_proxy'] = TRUE;
$settings['reverse_proxy_addresses'] = array($_SERVER['REMOTE_ADDR']);
```

**Origin protection (if enabled):**
```
// Direct application protection.
// Must route via edge.
$headers = getallheaders();
if (PHP_SAPI !== 'cli' &&
  ($_SERVER['REMOTE_ADDR'] != '127.0.0.1') &&
  (empty($headers['X_QUANT_TOKEN']) || $headers['X_QUANT_TOKEN'] != 'abc123')) {
  die("Not allowed.");
}
```
