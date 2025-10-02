#!/bin/bash
RED='\033[0;31m'
YELLOW='\033[1;33m'
NC='\033[0m'

## PRODUCTION
## This script will run after each deployment completes.
printf "${RED}**Production environment**${NC} post-deploy-production\n"

## Check if Drupal is installed
if drush status --fields=bootstrap 2>/dev/null | grep -q "Successful"; then
    echo "Drupal is installed, running post-deploy tasks..."
    
    ## Cache rebuild and database updates.
    drush updb -y
    
    ## Configuration import example.
    #drush cim -y
    
    ## Show the output of drush status.
    drush status
else
    printf "${YELLOW}Drupal not installed yet.${NC} Skipping post-deploy tasks.\n"
    printf "Install Drupal first, then redeploy to run post-deploy tasks.\n"
fi

