# K3s Homelab Cluster
Automated k3s cluster deployment on Proxmox using Terraform and Ansible. The script will provision 1 control plane and 2 worker nodes. There is also an option to provision a bastion host with some default tools installed like kubectl, k9s, vim etc.

## Prerequisites
- Proxmox server
- Ubuntu cloud-init template (VM ID 100)
- Terraform installed
- Ansible installed
- SSH key pair

## Configuration

### 1. Terraform Configuration
Copy the template and update with your Proxmox details:
```bash
cp terraform/terraform.tfvars.template terraform/terraform.tfvars
```

Edit `terraform/terraform.tfvars` with:
- Proxmox endpoint and API token
- SSH public key
- SSH private key path
- VM IP addresses and gateway
- Cluster size (optional - defaults in `variables.tf`)

### 2. Ansible Configuration
Copy the template configuration:
```bash
cp ansible/inventory/cluster/group_vars/all.yml.template \
   ansible/inventory/cluster/group_vars/all.yml
```

Generate a secure k3s token:
```bash
openssl rand -base64 64
```

Edit `ansible/inventory/cluster/group_vars/all.yml` and:
- Replace `GENERATE_WITH_openssl_rand_-base64_64` with your generated token
- Update k3s version if needed (default: v1.31.12+k3s1)

## Deployment

Deploy the entire cluster:
```bash
./deploy.sh
```

Deploy the entire cluster with bastion:
```bash
./deploy.sh bastion
```

Destroy the cluster:
```bash
./destroy.sh
```

## Manual Steps

Provision VMs only:
```bash
cd terraform
terraform apply
```

Provision VMs only with bastion:
```bash
cd terraform
terraform apply -var="enable_bastion=true"
```

Deploy k3s only:
```bash
cd ansible
ansible-playbook playbooks/site-minimal.yml -i inventory/cluster/hosts.ini
```

## Access the Cluster
```bash
export KUBECONFIG=~/.kube/k3s-config
kubectl get nodes
```

Or use the kubeconfig directly:
```bash
kubectl --kubeconfig ~/.kube/k3s-config get nodes
```

## Access the bastion host
```bash
ssh -i <PATH_TO_SSH_PRIVATE_KEY> ubuntu@<BASTION_IP>
```

## Security Notes

- `terraform/terraform.tfvars` and `ansible/inventory/cluster/group_vars/all.yml` contain secrets and are excluded from git
- Use the `.template` files as references
- Never commit your actual tokens or API keys to version control

## Repos used

- https://github.com/k3s-io/k3s-ansible
- https://github.com/bpg/terraform-provider-proxmox
