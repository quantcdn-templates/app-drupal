#!/bin/bash

# Wait for rollout to complete..
# kubectl rollout status deploy/drupal --watch=true

# # Wait for shutdown of terminating pods..
# SELECTOR=$(kubectl get deploy/drupal -o wide --no-headers | awk '{print $NF}')

# runtime="5 minute"
# endtime=$(date -ud "$runtime" +%s)

# while :
# do
#     POD_STATES=$(kubectl get pods --selector ${SELECTOR} --no-headers | awk '{print $3}' | uniq)
#     if [[ "$POD_STATES" == "Running" ]] || [[ $(date -u +%s) -le $endtime ]]; then
#         break
#     fi

#     sleep 5
# done

kubectl exec deploy/drupal -- /opt/deployment-scripts/post-deploy.sh
