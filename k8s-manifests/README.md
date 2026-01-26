# Kubernetes Manifests

  GitOps repository for K3s homelab cluster managed by ArgoCD.

  ## Structure
  - `argocd/` - ArgoCD installation and bootstrap configuration
  - `minio/` - MinIO S3-compatible object storage
  - `apps/` - Application deployments

  ## Deployment
  All applications are automatically synced by ArgoCD.
