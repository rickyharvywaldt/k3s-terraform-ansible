# K3s Homelab Cluster

Automated k3s cluster deployment on Proxmox using Terraform and Ansible.

## Prerequisites

- Proxmox server
- Ubuntu cloud-init template (VM ID 100)
- Terraform installed
- Ansible installed
- SSH key pair

## Configuration

1. Copy `terraform/terraform.tfvars.template` to `terraform/terraform.tfvars`
2. Update with your Proxmox details and SSH keys
3. Customize cluster size in `terraform/variables.tf` if needed and ssh private key path
4. Update k3s version in `ansible/inventory/my-cluster/group_vars/all.yml`

## Deployment

Deploy the entire cluster:
```bash
./deploy.sh
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

Deploy k3s only:
```bash
cd ansible
ansible-playbook playbooks/site.yml -i inventory/my-cluster/hosts.ini
```

## Access the Cluster
```bash
export KUBECONFIG=~/.kube/k3s-config
kubectl get nodes
```
