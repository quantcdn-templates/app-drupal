#!/bin/bash
RED='\033[0;31m'
NC='\033[0m'

## PRODUCTION
## This script will run after each deployment completes.
printf "${RED}**Production environment**${NC} post-deploy-development\n"

## Cache rebuild and database updates.
drush updb -y

## Show the output of drush status.
drush status

## Configuration import example.
#drush cim -y

## Warm Drupal caches.
curl -X GET -I http://localhost
