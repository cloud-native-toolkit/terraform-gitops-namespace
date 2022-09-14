#!/usr/bin/env bash

GIT_REPO=$(cat git_repo)
GIT_TOKEN=$(cat git_token)

export KUBECONFIG=$(cat .kubeconfig)

source "${SCRIPT_DIR}/validation-functions.sh"

mkdir -p .testrepo

git clone https://${GIT_TOKEN}@${GIT_REPO} .testrepo

cd .testrepo || exit 1

find . -name "*"

NAMESPACE="gitops-namespace"

validate_gitops_ns_content "${NAMESPACE}"

cd ..
rm -rf .testrepo

count=0
until kubectl get namespace "${NAMESPACE}" 1> /dev/null 2> /dev/null || [[ $count -eq 20 ]]; do
  echo "Waiting for namespace: ${NAMESPACE}"
  count=$((count + 1))
  sleep 15
done

if [[ $count -eq 20 ]]; then
  echo "Timed out waiting for namespace: ${NAMESPACE}"
  exit 1
else
  echo "Found namespace: ${NAMESPACE}. Sleeping for 30 seconds to wait for everything to settle down"
  sleep 30
fi

if ! kubectl get rolebinding -n "${NAMESPACE}" argocd-admin 1> /dev/null 2> /dev/null; then
  echo "Unable to find rolebinding: ${NAMESPACE}/argocd-admin"
  kubectl get rolebinding -n "${NAMESPACE}"
  exit 1
fi
