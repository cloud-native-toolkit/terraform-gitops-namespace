#!/usr/bin/env bash

REPO="$1"
REPO_PATH="$2"
NAMESPACE="$3"

echo "Path: ${REPO_PATH}"

REPO_DIR=".tmprepo-namespace-${NAMESPACE}"

SEMAPHORE="${REPO//\//-}.semaphore"

while true; do
  echo "Checking for semaphore"
  if [[ ! -f "${SEMAPHORE}" ]]; then
    echo -n "${REPO_DIR}" > "${SEMAPHORE}"

    if [[ $(cat "${SEMAPHORE}") == "${REPO_DIR}" ]]; then
      echo "Got the semaphore. Setting up gitops repo"
      break
    fi
  fi

  SLEEP_TIME=$((1 + $RANDOM % 10))
  echo "  Waiting $SLEEP_TIME seconds for semaphore"
  sleep $SLEEP_TIME
done

function finish {
  rm "${SEMAPHORE}"
}

trap finish EXIT

git config --global user.email "cloudnativetoolkit@gmail.com"
git config --global user.name "Cloud-Native Toolkit"

mkdir -p "${REPO_DIR}"

git clone "https://${TOKEN}@${REPO}" "${REPO_DIR}"

cd "${REPO_DIR}" || exit 1

mkdir -p "${REPO_PATH}/namespaces"

cat > "${REPO_PATH}/namespaces/${NAMESPACE}.yaml" <<EOL
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
