#!/bin/bash
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

## DEVELOPMENT
## This script will run after each deployment completes.
printf "${GREEN}**Development environment**${NC} post-deploy-development\n"

## Check if Drupal is installed
if drush status --fields=bootstrap 2>/dev/null | grep -q "Successful"; then
    echo "Drupal is installed, running post-deploy tasks..."
    
    ## Cache rebuild and database updates.
    drush updb -y
    
    ## Configuration import example.
    ## This example would import partial development environment overrides.
    # drush config:import -y --source="/opt/drupal/config/dev" --partial
    
    ## Show the output of drush status.
    drush status

else
    printf "${YELLOW}Drupal not installed yet.${NC} Visit http://localhost to install.\n"
    printf "After installation, redeploy to run post-deploy tasks.\n"
fi
