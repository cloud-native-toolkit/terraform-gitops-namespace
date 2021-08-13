#!/usr/bin/env bash

GIT_REPO=$(cat git_repo)
GIT_TOKEN=$(cat git_token)

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

if [[ ! -f "payload/1-infrastructure/namespace/${NAMESPACE}/namespace/ns.yaml" ]]; then
  echo "Payload missing: payload/1-infrastructure/namespace/${NAMESPACE}/namespace/ns.yaml"
  exit 1
fi

echo "Printing payload/1-infrastructure/namespace/${NAMESPACE}/namespace/ns.yaml"
cat "payload/1-infrastructure/namespace/${NAMESPACE}/namespace/ns.yaml"

cd ..
rm -rf .testrepo
