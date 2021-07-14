#!/usr/bin/env bash

YAML_DIR="$1"
NAMESPACE="$2"

mkdir -p "${YAML_DIR}"

cat > "${YAML_DIR}/${NAMESPACE}.yaml" <<EOL
apiVersion: v1
kind: Namespace
metadata:
  name: $NAMESPACE
EOL
