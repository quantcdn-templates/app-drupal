#!/bin/bash

# Wait for rollout to complete..
kubectl rollout status deploy/drupal --watch=true

# Wait for shutdown of terminating pods..
SELECTOR=$(kubectl get deploy/my-deployment-name -o wide --no-headers | awk '{print \$NF}')

while :
do
    POD_STATES=$(kubectl get pods --selector ${SELECTOR} --no-headers | awk '{print \$3}' | uniq)
    if [[ "$POD_STATES" == "Running" ]]; then
        break
    fi

    sleep 5
done

kubectl exec deploy/drupal -- echo "Call your script here.."