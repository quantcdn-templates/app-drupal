#!/bin/bash

# Run post-deployment scripts.
if [ "$QUANT_ENV_TYPE" == "development" ]; then
    /quant/deployment-scripts/post-deploy-development.sh
elif [ "$QUANT_ENV_TYPE" == "production" ]; then
    /quant/deployment-scripts/post-deploy-production.sh
else
    echo "Unknown environment type: $QUANT_ENV_TYPE"
fi
