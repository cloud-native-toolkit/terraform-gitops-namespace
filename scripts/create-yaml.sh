#!/usr/bin/env bash

YAML_DIR="$1"
NAMESPACE="$2"

mkdir -p "${YAML_DIR}"

cat > "${YAML_DIR}/ns.yaml" <<EOL
apiVersion: v1
kind: Namespace
metadata:
  name: $NAMESPACE
  annotations:
    argocd.argoproj.io/sync-wave: "-10"
EOL
