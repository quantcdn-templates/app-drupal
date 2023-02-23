#!/bin/bash
test -z "${DEBUG}" || set -o xtrace
set -o errexit

cd "$(dirname "$0")"

cert=/etc/ssl/certs/ca-certificates.crt

main() {
  setCluster

  kubectl create secret docker-registry quant-cloud --docker-server=$CONTAINER_REGISTRY_URL --docker-username=$CONTAINER_REGISTRY_USER --docker-password=$CONTAINER_REGISTRY_TOKEN || true
  cat ../k8s/deploy.yaml| envsubst "$(env | cut -d= -f1 | sed -e 's/^/$/')" | kubectl apply -f -
  kubectl apply -f ../k8s/ingress-upstream.yaml
  kubectl rollout restart deployment node-express
}

setCluster() {
  # Configure kubectl to talk to Quant Cloud (Section)

  # change the cert path depending on OS.
  if [[ "$OSTYPE" == "darwin"* ]]; then
    cert=/usr/local/etc/ca-certificates/cert.pem
  fi

  kubectl config set-cluster quant-cloud \
  --server=$SECTION_K8S_API_URL \
  --certificate-authority=$cert

  kubectl config set-credentials quant-cloud-user --token=$SECTION_API_TOKEN
  kubectl config set-context quant-cloud-app --cluster=quant-cloud --user=quant-cloud-user --namespace=default
  kubectl config use-context quant-cloud-app
  kubectl version
}

"$@"
