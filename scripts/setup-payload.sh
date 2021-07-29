#!/usr/bin/env bash

SCRIPT_DIR=$(cd $(dirname "$0"); pwd -P)

NAME="$1"
REPO="$2"
REPO_PATH="$3"
NAMESPACE="$4"
CONTENT_DIR="$5"
REPO_PATH2="$6"
NAMESPACE2="$7"

REPO_DIR=".tmprepo-payload-${NAMESPACE}"

git config --global user.email "cloudnativetoolkit@gmail.com"
git config --global user.name "Cloud-Native Toolkit"

mkdir -p "${REPO_DIR}"

git clone "https://${TOKEN}@${REPO}" "${REPO_DIR}"

cd "${REPO_DIR}" || exit 1

mkdir -p "${REPO_PATH}"
mkdir -p "${REPO_PATH2}"

cp -R "${CONTENT_DIR}/"* "${REPO_PATH}"
echo "${NAMESPACE2}" > "${REPO_PATH2}/.gitkeep"

git add .
git commit -m "Adds payload yaml for ${NAME}"
git push

cd ..
rm -rf "${REPO_DIR}"
