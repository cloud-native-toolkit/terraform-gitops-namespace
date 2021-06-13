#!/usr/bin/env bash

REPO="$1"
PATH="$2"
NAMESPACE="$3"

REPO_DIR=".tmprepo-namespace-${NAMESPACE}"

git config --global user.email "cloudnativetoolkit@gmail.com"
git config --global user.name "Cloud-Native Toolkit"

mkdir -p "${REPO_DIR}"

git clone "https://${TOKEN}@${REPO}" "${REPO_DIR}"

cd "${REPO_DIR}" || exit 1

mkdir -p "${PATH}/namespaces"

cat > "${PATH}/namespaces/${NAMESPACE}.yaml" <<EOL
apiVersion: v1
kind: Namespace
metadata:
  name: $NAMESPACE
EOL

git add .
git commit -m "Adds config for '$NAMESPACE' namespace"
git push

cd ..
rm -rf "${REPO_DIR}"
