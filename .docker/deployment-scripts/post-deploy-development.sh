#!/bin/bash
GREEN='\033[0;32m'
NC='\033[0m'

## DEVELOPMENT
## This script will run after each deployment completes.
printf "${GREEN}**Development environment**${NC} post-deploy-development\n"

## Cache rebuild and database updates.
drush updb -y

## Show the output of drush status.
drush status

## Configuration import example.
## This example would import partial development environment overrides.
# drush config:import -y --source="/opt/drupal/config/dev" --partial

## Warm Drupal caches.
curl -X GET -I http://localhost
