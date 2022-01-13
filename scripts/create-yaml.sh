#!/usr/bin/env bash

YAML_DIR="$1"
NAMESPACE="$2"
CREATEOG="$3"
ARGOCD_NAMESPACE="$4"

ARGOCD_SA="openshift-gitops-argocd-application-controller"

mkdir -p "${YAML_DIR}"

cat > "${YAML_DIR}/ns.yaml" <<EOL
apiVersion: v1
kind: Namespace
metadata:
  name: $NAMESPACE
  annotations:
    argocd.argoproj.io/sync-wave: "-20"
EOL

cat > "${YAML_DIR}/rbac.yaml" <<EOL
apiVersion: rbac.authorization.k8s.io/v1
kind: Role
metadata:
  name: argocd-admin
  annotations:
    argocd.argoproj.io/sync-wave: "-20"
rules:
  - apiGroups:
    - "*"
    resources:
    - "*"
    verbs:
    - "*"
---
apiVersion: rbac.authorization.k8s.io/v1
kind: RoleBinding
metadata:
  name: argocd-admin
  annotations:
    argocd.argoproj.io/sync-wave: "-20"
roleRef:
  apiGroup: rbac.authorization.k8s.io
  kind: Role
  name: argocd-admin
subjects:
- apiGroup: rbac.authorization.k8s.io
  kind: Group
  name: system:serviceaccounts:${ARGOCD_NAMESPACE}
- kind: ServiceAccount
  name: ${ARGOCD_SA}
  namespace: ${ARGOCD_NAMESPACE}
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
    argocd.argoproj.io/sync-wave: "-20"
spec:
  targetNamespaces:
    - ${NAMESPACE}
---
EOL

fi
