#!/usr/bin/env bash

YAML_DIR="$1"
CREATEOG="$2"
ARGOCD_NAMESPACE="$3"
CI="$4"

mkdir -p "${YAML_DIR}"

cat > "${YAML_DIR}/values.yaml" <<EOL
createOperatorGroup: ${CREATEOG}
argocdNamespace: ${ARGOCD_NAMESPACE}
gitopsConfig:
  create: false
EOL
