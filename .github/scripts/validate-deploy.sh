#!/usr/bin/env bash

GIT_REPO=$(cat git_repo)
GIT_TOKEN=$(cat git_token)

mkdir -p .testrepo

git clone https://${GIT_TOKEN}@${GIT_REPO} .testrepo

cd .testrepo || exit 1

find . -name "*"

NAMESPACE="gitops-namespace"

if [[ ! -f "argocd/1-infrastructure/active/namespaces.yaml" ]]; then
  echo "Argocd config missing: argocd/1-infrastructure/active/namespaces.yaml"
  exit 1
fi

echo "Printing argocd/1-infrastructure/active/namespaces.yaml"
cat "argocd/1-infrastructure/active/namespaces.yaml"

if [[ ! -f "argocd/1-infrastructure/active/namespace-${NAMESPACE}.yaml" ]]; then
  echo "Argocd config missing: argocd/1-infrastructure/active/namespace-${NAMESPACE}.yaml"
  exit 1
fi

echo "Printing argocd/1-infrastructure/active/namespace-${NAMESPACE}.yaml"
cat "argocd/1-infrastructure/active/namespace-${NAMESPACE}.yaml"

if [[ ! -f "payload/1-infrastructure/namespaces/${NAMESPACE}.yaml" ]]; then
  echo "Payload missing: payload/1-infrastructure/namespaces/${NAMESPACE}.yaml"
  exit 1
fi

echo "Printing payload/1-infrastructure/namespaces/${NAMESPACE}.yaml"
cat "payload/1-infrastructure/namespaces/${NAMESPACE}.yaml"

if [[ ! -f "payload/1-infrastructure/namespace/${NAMESPACE}/.gitkeep" ]]; then
  echo "Payload directory missing: payload/1-infrastructure/namespace/${NAMESPACE}/.gitkeep"
  exit 1
fi

echo "Printing payload/1-infrastructure/namespace/${NAMESPACE}/.gitkeep"
cat "payload/1-infrastructure/namespace/${NAMESPACE}/.gitkeep"

cd ..
rm -rf .testrepo
