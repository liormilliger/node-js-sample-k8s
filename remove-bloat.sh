#!/bin/bash
# This script removes the bloated 'last-applied-configuration' annotation from the problematic CRDs.

# Array of CRD names that are failing
CRDS=(
  "alertmanagers.monitoring.coreos.com"
  "prometheusagents.monitoring.coreos.com"
  "prometheuses.monitoring.coreos.com"
  "thanosrulers.monitoring.coreos.com"
)

echo "Removing bloated annotations from Prometheus CRDs..."

for crd in "${CRDS[@]}"; do
  # Check if the CRD exists before trying to patch it
  if kubectl get crd "$crd" > /dev/null 2>&1; then
    echo "Patching $crd..."
    # The 'json-patch' type with 'remove' is the cleanest way to delete a specific annotation.
    # The '~1' is the correct way to escape the '/' character in a JSON Pointer path.
    kubectl patch crd "$crd" --type='json' -p='[{"op": "remove", "path": "/metadata/annotations/kubectl.kubernetes.io~1last-applied-configuration"}]'
  else
    echo "CRD $crd not found, skipping."
  fi
done

echo "Done."
