#!/usr/bin/env bash

GIT_REPO=$(cat git_repo)
GIT_TOKEN=$(cat git_token)

export KUBECONFIG=$(cat .kubeconfig)

source "${SCRIPT_DIR}/validation-functions.sh"

NAMESPACE=$(jq -r '.name // "gitops-namespace"' gitops-output.json)
BRANCH=$(jq -r '.branch // "main"' gitops-output.json)
SERVER_NAME=$(jq -r '.server_name // "default"' gitops-output.json)
LAYER=$(jq -r '.layer_dir // "2-services"' gitops-output.json)
TYPE=$(jq -r '.type // "base"' gitops-output.json)

mkdir -p .testrepo

git clone https://${GIT_TOKEN}@${GIT_REPO} .testrepo

cd .testrepo || exit 1

find . -name "*"

validate_gitops_ns_content "${NAMESPACE}"

cd ..
rm -rf .testrepo

check_k8s_namespace "${NAMESPACE}"
check_k8s_resource "${NAMESPACE}" rolebinding argocd-admin
