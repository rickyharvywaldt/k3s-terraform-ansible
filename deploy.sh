#!/bin/bash
set -e  # Exit on any error

echo "=========================================="
echo "K3s Cluster Deployment Script"
echo "=========================================="

# Colors for output
GREEN='\033[0;32m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Configuration
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
TERRAFORM_DIR="$SCRIPT_DIR/terraform"
ANSIBLE_DIR="$SCRIPT_DIR/ansible"
MASTER_IP="10.100.2.50"
KUBECONFIG_PATH="$HOME/.kube/k3s-config"

# Step 1: Clean SSH known hosts
echo -e "${BLUE}[1/6] Cleaning SSH known_hosts...${NC}"
for ip in 10.100.2.50 10.100.2.51 10.100.2.52; do 
    ssh-keygen -R $ip 2>/dev/null || true
done

# Step 2: Start SSH agent and add key
echo -e "${BLUE}[2/6] Setting up SSH agent...${NC}"
if [ -z "$SSH_AUTH_SOCK" ]; then
    eval $(ssh-agent -s)
fi
if ! ssh-add -l | grep -q "id_rsa"; then
    echo "Adding SSH key to agent..."
    ssh-add ~/.ssh/k3s-terraform-ansible
fi

# Step 3: Provision VMs with Terraform
echo -e "${BLUE}[3/6] Provisioning VMs with Terraform...${NC}"
cd "$TERRAFORM_DIR"
terraform init
terraform apply -auto-approve

# Step 4: Wait for VMs to fully boot
echo -e "${BLUE}[4/6] Waiting for VMs to boot (30 seconds)...${NC}"
sleep 30

# Step 5: Deploy k3s with Ansible
echo -e "${BLUE}[5/6] Deploying k3s cluster with Ansible...${NC}"
cd "$ANSIBLE_DIR"
ansible-playbook playbooks/site.yml -i inventory/cluster/hosts.ini

# Step 6: Fetch and configure kubeconfig
echo -e "${BLUE}[6/6] Fetching kubeconfig...${NC}"
ssh ubuntu@$MASTER_IP "sudo cat /etc/rancher/k3s/k3s.yaml" > "$KUBECONFIG_PATH"
sed -i '' "s/127.0.0.1/$MASTER_IP/g" "$KUBECONFIG_PATH"
chmod 600 "$KUBECONFIG_PATH"

cd "$SCRIPT_DIR"

# Verify cluster
echo -e "${GREEN}=========================================="
echo "Deployment Complete!"
echo "==========================================${NC}"
echo ""
echo "Kubeconfig saved to: $KUBECONFIG_PATH"
echo ""
echo "Cluster status:"
kubectl --kubeconfig "$KUBECONFIG_PATH" get nodes
echo ""
echo -e "${GREEN}To use the cluster, run:${NC}"
echo "export KUBECONFIG=$KUBECONFIG_PATH"
echo "kubectl get nodes"
