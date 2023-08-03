#!/bin/bash

# Run post-deployment scripts.
if [ "$QUANT_ENVIRONMENT_TYPE" == "development" ]; then
    ##
    ## Fresh installation example.
    ##
    STATUS=$(drush status --fields=bootstrap --format=json)

    # Drupal cannot be bootstrapped.
    # Here we perform a fresh installation, and install the required default modules.
    # We install devel_generate to create some sample content.
    if [ "$(jq -r '.bootstrap' 2> /dev/null <<< "$STATUS")" != "Successful" ]; then
        drush sql:create -y
        drush site:install -y
        drush pm:enable devel_generate -y
        drush devel-generate:content -y
    fi
fi
