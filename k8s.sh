#!/bin/bash

[[ -z $STAGE ]] && echo "Missing STAGE" && exit 1
[[ -z $SLUG ]] && echo "Missing SLUG" && exit 1


# Create vars
BASEDIR=$(dirname "$0")
NAME=$(echo "${STAGE}" | tr '[:upper:]' '[:lower:]')
NAMESPACE="${NAME}"

# Update config
aws eks update-kubeconfig --name "$NAME"

secrets () {
  # Create secrets
  kubectl -n "$NAMESPACE" create secret generic "${SLUG}"-secrets \
    --from-env-file=<(aws secretsmanager get-secret-value --secret-id "${SLUG}"-secrets | jq -r .SecretString | jq -r 'to_entries | .[] | .key + "=" + .value') \
    --dry-run=client -o yaml |
    kubectl apply -f -
}

config () {
  # Apply config map
  envsubst <"$BASEDIR"/config.yml | kubectl apply -n "$NAMESPACE" -f -
}

deploy () {
  # Required to substitute variables in k8s.yml
  [[ -z $HOST ]] && echo "Missing HOST" && exit 1
  [[ -z $PORT ]] && echo "Missing PORT" && exit 1
  [[ -z $MEMORY_LIMIT ]] && echo "Missing MEMORY_LIMIT" && exit 1
  [[ -z $MEMORY_REQUESTS ]] && echo "Missing MEMORY_REQUESTS" && exit 1
  [[ -z $AWS_ECR_URL ]] && echo "Missing AWS_ECR_URL" && exit 1

  envsubst <"$BASEDIR"/k8s.yml | kubectl apply -n "$NAMESPACE" -f -
}

restart () {
  kubectl rollout restart deployment -n "$NAMESPACE" "$SLUG"
}

case $1 in
  "secrets")
    secrets
  ;;
  "config")
    config
  ;;
  "deploy")
    deploy
  ;;
  "restart")
    restart
  ;;
  *)
    exit 1;
  ;;
esac
