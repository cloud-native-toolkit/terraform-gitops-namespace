#!/usr/bin/env bash

GIT_REPO=$(cat git_repo)
GIT_TOKEN=$(cat git_token)

BIN_DIR=$(cat .bin_dir)

export PATH="${BIN_DIR}:${PATH}"

export KUBECONFIG=$(cat .kubeconfig)

mkdir -p .testrepo

git clone https://${GIT_TOKEN}@${GIT_REPO} .testrepo

cd .testrepo || exit 1

find . -name "*"

SERVER_NAME="default"
NAMESPACE="gitops-namespace"

if [[ ! -f "argocd/1-infrastructure/cluster/${SERVER_NAME}/base/namespace-${NAMESPACE}.yaml" ]]; then
  echo "Argocd config missing: argocd/1-infrastructure/cluster/${SERVER_NAME}/base/namespace-${NAMESPACE}.yaml"
  exit 1
fi

echo "Printing argocd/1-infrastructure/cluster/${SERVER_NAME}/base/namespace-${NAMESPACE}.yaml"
cat "argocd/1-infrastructure/cluster/${SERVER_NAME}/base/namespace-${NAMESPACE}.yaml"

if [[ ! -f "argocd/1-infrastructure/cluster/${SERVER_NAME}/kustomization.yaml" ]]; then
  echo "Argocd config missing: argocd/1-infrastructure/cluster/${SERVER_NAME}/kustomization.yaml"
  exit 1
fi

echo "Printing argocd/1-infrastructure/cluster/${SERVER_NAME}/kustomization.yaml"
cat "argocd/1-infrastructure/cluster/${SERVER_NAME}/kustomization.yaml"


if [[ ! -f "payload/1-infrastructure/namespace/${NAMESPACE}/namespace/Chart.yaml" ]]; then
  echo "Payload missing: payload/1-infrastructure/namespace/${NAMESPACE}/namespace/Chart.yaml"
  exit 1
fi

echo "Printing payload/1-infrastructure/namespace/${NAMESPACE}/namespace/Chart.yaml"
cat "payload/1-infrastructure/namespace/${NAMESPACE}/namespace/Chart.yaml"

if [[ ! -f "payload/1-infrastructure/namespace/${NAMESPACE}/namespace/values.yaml" ]]; then
  echo "Payload missing: payload/1-infrastructure/namespace/${NAMESPACE}/namespace/values.yaml"
  exit 1
fi

echo "Printing payload/1-infrastructure/namespace/${NAMESPACE}/namespace/values.yaml"
cat "payload/1-infrastructure/namespace/${NAMESPACE}/namespace/values.yaml"

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
