#!/usr/bin/env bash

YAML_DIR="$1"
NAMESPACE="$2"
CREATEOG="$3"

mkdir -p "${YAML_DIR}"

cat > "${YAML_DIR}/ns.yaml" <<EOL
apiVersion: v1
kind: Namespace
metadata:
  name: $NAMESPACE
  annotations:
    argocd.argoproj.io/sync-wave: "-10"
EOL

if [[ "${CREATEOG}" == "true" ]]; then
  cat >> "${YAML_DIR}/ns.yaml" << EOL
---
apiVersion: operators.coreos.com/v1
kind: OperatorGroup
metadata:
  name: ${NAMESPACE}-operator-group
  namespace: ${NAMESPACE}
  annotations:
    argocd.argoproj.io/sync-wave: "-10"
spec:
  targetNamespaces:
    - ${NAMESPACE}
---
EOL

fi
