#!/bin/bash
set -e  # Exit on any error

# Colors for output
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Configuration
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
TERRAFORM_DIR="$SCRIPT_DIR/terraform"
ANSIBLE_DIR="$SCRIPT_DIR/ansible"
MASTER_IP="10.100.2.50"
KUBECONFIG_PATH="$HOME/.kube/k3s-config"
SSH_PRIVATE_KEY_PATH="$HOME/.ssh/k3s-terraform-ansible"

# Parse arguments
ENABLE_BASTION=false
if [[ "$1" == "bastion" ]]; then
    ENABLE_BASTION=true
    echo -e "${YELLOW}Bastion mode enabled${NC}"
fi

echo "=========================================="
echo "K3s Cluster Deployment Script"
echo "=========================================="

# Step 1: Clean SSH known hosts
echo -e "${BLUE}[1/6] Cleaning SSH known_hosts...${NC}"
SSH_IPS="10.100.2.50 10.100.2.51 10.100.2.52"
if [ "$ENABLE_BASTION" = true ]; then
    SSH_IPS="$SSH_IPS 10.100.2.49"
fi

for ip in $SSH_IPS; do 
    ssh-keygen -R $ip 2>/dev/null || true
done

# Step 2: Start SSH agent and add key
echo -e "${BLUE}[2/6] Setting up SSH agent...${NC}"
if [ -z "$SSH_AUTH_SOCK" ]; then
    eval $(ssh-agent -s)
fi
if ! ssh-add -l | grep -q "k3s-terraform-ansible"; then
    echo "Adding SSH key to agent..."
    ssh-add ~/.ssh/k3s-terraform-ansible
fi

# Step 3: Provision VMs with Terraform
echo -e "${BLUE}[3/6] Provisioning VMs with Terraform...${NC}"
cd "$TERRAFORM_DIR"
terraform init

if [ "$ENABLE_BASTION" = true ]; then
    terraform apply -auto-approve -var="enable_bastion=true"
else
    terraform apply -auto-approve
fi

# Step 4: Wait for VMs to fully boot
echo -e "${BLUE}[4/6] Waiting for VMs to boot (30 seconds)...${NC}"
sleep 30

# Step 5: Deploy k3s with Ansible
echo -e "${BLUE}[5/6] Deploying k3s cluster with Ansible...${NC}"
cd "$ANSIBLE_DIR"
ansible-playbook playbooks/site-minimal.yml -i inventory/cluster/hosts.ini

# Step 6: Fetch and configure kubeconfig
echo -e "${BLUE}[6/6] Fetching kubeconfig...${NC}"
ssh ubuntu@$MASTER_IP "sudo cat /etc/rancher/k3s/k3s.yaml" > "$KUBECONFIG_PATH"
sed -i '' "s/127.0.0.1/$MASTER_IP/g" "$KUBECONFIG_PATH"
chmod 600 "$KUBECONFIG_PATH"

# Copy kubeconfig to bastion if enabled
if [ "$ENABLE_BASTION" = true ]; then
    echo -e "${BLUE}Copying kubeconfig to bastion...${NC}"
    ssh -i ~/.ssh/k3s-terraform-ansible ubuntu@10.100.2.49 "mkdir -p ~/.kube"
    scp -i ~/.ssh/k3s-terraform-ansible "$KUBECONFIG_PATH" ubuntu@10.100.2.49:~/.kube/config
fi

cd "$SCRIPT_DIR"

# Verify cluster
echo -e "${GREEN}=========================================="
echo "Deployment Complete!"
echo "==========================================${NC}"
echo ""
if [ "$ENABLE_BASTION" = true ]; then
    echo -e "${GREEN}Bastion host: ubuntu@10.100.2.49${NC}"
    echo ""
fi
echo "Kubeconfig saved to: $KUBECONFIG_PATH"
echo ""
echo "Cluster status:"
kubectl --kubeconfig "$KUBECONFIG_PATH" get nodes
echo ""
echo -e "${GREEN}To use the cluster from your local machine, run:${NC}"
echo "export KUBECONFIG=$KUBECONFIG_PATH"
echo "kubectl get nodes"
echo ""
echo -e "${GREEN}If bastion is provisioned, to log in, run:${NC}"
echo "ssh -i $SSH_PRIVATE_KEY_PATH ubuntu@10.100.2.49"
