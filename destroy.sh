#!/bin/bash
set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

echo "=========================================="
echo "Destroying K3s Cluster"
echo "=========================================="

cd "$SCRIPT_DIR/terraform"
terraform destroy -auto-approve

echo "Cluster destroyed!"
