#!/usr/bin/env bash

REPO="$1"
PATH="$2"
PROJECT="$3"
APPLICATION_REPO="$4"
APPLICATION_PATH="$5"
NAMESPACE="$6"
BRANCH="$7"

REPO_DIR=".tmprepo-namespace-${NAMESPACE}"

git config --global user.email "cloudnativetoolkit@gmail.com"
git config --global user.name "Cloud-Native Toolkit"

mkdir -p "${REPO_DIR}"

git clone "https://${TOKEN}@${REPO}" "${REPO_DIR}"

cd "${REPO_DIR}" || exit 1

cat > "${PATH}/namespaces.yaml" <<EOL
apiVersion: argoproj.io/v1alpha1
kind: Application
metadata:
  name: namespaces-${BRANCH}
spec:
  destination:
    namespace: ${NAMESPACE}
    server: "https://kubernetes.default.svc"
  project: ${PROJECT}
  source:
    path: ${APPLICATION_PATH}
    repoURL: ${APPLICATION_PATH}
    targetRevision: ${BRANCH}
  syncPolicy:
    automated:
      prune: true
      selfHeal: true
EOL

if [[ $(git status --porcelain | wc -l) -gt 0 ]]; then
  git add .
  git commit -m "Adds argocd config for namespaces"
  git push
fi

cd ..
rm -rf "${REPO_DIR}"
