#!/bin/bash
test -z "${DEBUG}" || set -o xtrace
set -o errexit

cd "$(dirname "$0")"

cert=/etc/ssl/certs/ca-certificates.crt

if [[ "$OSTYPE" == "darwin"* ]]; then
  cert=/usr/local/etc/ca-certificates/cert.pem
fi

kubectl config set-cluster quant-cloud \
  --server=$SECTION_K8S_API_URL \
  --certificate-authority=$cert

kubectl config set-credentials quant-cloud-user --token=$SECTION_API_TOKEN
kubectl config set-context quant-cloud-app --cluster=quant-cloud --user=quant-cloud-user --namespace=default
kubectl config use-context quant-cloud-app