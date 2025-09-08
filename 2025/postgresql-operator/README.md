# Install the Operator
kubectl apply --server-side -f \
  https://raw.githubusercontent.com/cloudnative-pg/cloudnative-pg/release-1.27/releases/cnpg-1.27.0.yaml

# Install the local storage class
kubectl apply -f https://raw.githubusercontent.com/rancher/local-path-provisioner/master/deploy/local-path-storage.yaml



# PostgreSQL Operator with STAC and Local Storage

This directory contains Kubernetes manifests and configuration for deploying a CloudNativePG PostgreSQL/PostGIS cluster with STAC-compliant schema and local-path storage, plus pgAdmin4 for management.

## Contents
- `storageclass_postgis.yaml`: StorageClass, Cluster, PVC, and pgAdmin4 manifests

## Usage

### 1. Prerequisites
- Kubernetes cluster (minikube, k3s, or multi-node)
- [CloudNativePG operator](https://cloudnative-pg.io/) installed
- [local-path-provisioner](https://github.com/rancher/local-path-provisioner) installed for local storage

### 2. Deploy StorageClass
```bash
kubectl apply -f storageclass_postgis.yaml
```

### 3. Deploy PostgreSQL/PostGIS Cluster
- The manifest creates a STAC-compliant PostGIS cluster using the local-path StorageClass.
- PVCs will be dynamically provisioned.

### 4. Deploy pgAdmin4
- The manifest includes a pgAdmin4 deployment and NodePort service (default: 30080).
- Access pgAdmin4 at `http://<node-ip>:30080` with the credentials in the manifest.

### 5. Troubleshooting PVCs
- If PVCs are pending, ensure the local-path-provisioner is running:
  ```bash
  kubectl get pods -n local-path-storage
  kubectl get storageclass
  ```
- Install if missing:
  ```bash
  kubectl apply -f https://raw.githubusercontent.com/rancher/local-path-provisioner/master/deploy/local-path-storage.yaml
  ```
- Check PVC events:
  ```bash
  kubectl describe pvc <pvc-name>
  ```

### 6. STAC Schema
- The cluster is initialized with STAC-compliant tables for collections and items.
- You can ingest and query STAC metadata using standard SQL.

### 7. Expanding Storage
- Edit the PVC and increase the `storage` value, then apply the change.

