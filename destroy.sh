#!/bin/bash
set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
KUBECONFIG_PATH="$HOME/.kube/k3s-config"

# Define IPs (should match your terraform.tfvars)
CLUSTER_IPS=("10.100.2.50" "10.100.2.51" "10.100.2.52")

echo "=========================================="
echo "Destroying K3s Cluster"
echo "=========================================="

# Destroy infrastructure
cd "$SCRIPT_DIR/terraform"
terraform destroy -auto-approve

# Clean up kubeconfig
if [ -f "$KUBECONFIG_PATH" ]; then
    echo "Removing kubeconfig: $KUBECONFIG_PATH"
    rm "$KUBECONFIG_PATH"
fi

# Clean up SSH known_hosts
echo "Cleaning SSH known_hosts..."
for ip in "${CLUSTER_IPS[@]}"; do 
    ssh-keygen -R $ip 2>/dev/null || true
done

echo "Cluster destroyed and cleaned up!"
