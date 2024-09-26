To install the MinIO plugin on Ubuntu 22.04, follow these steps:

### 1. **Install MinIO Client (mc)**

First, install the MinIO Client (mc), which allows you to interact with the MinIO object storage and Kubernetes through plugins:

```bash
wget https://dl.min.io/client/mc/release/linux-amd64/mc
chmod +x mc
sudo mv mc /usr/local/bin/
```

### 2. **Install the MinIO Plugin for Kubernetes**

If you are using Kubernetes and the MinIO Operator, you need to install the MinIO plugin, which provides `kubectl` extensions for managing MinIO resources.

#### a. Install the Plugin Using `kubectl krew` (Recommended)

1. Install `kubectl krew` if you don’t have it:

```bash
(
  set -x; cd "$(mktemp -d)" &&
  OS="$(uname | tr '[:upper:]' '[:lower:]')" &&
  ARCH="$(uname -m | sed 's/x86_64/amd64/' | sed 's/arm.*$/arm/')" &&
  KREW="krew-${OS}_${ARCH}" &&
  curl -fsSLO "https://github.com/kubernetes-sigs/krew/releases/latest/download/${KREW}.tar.gz" &&
  tar zxvf "${KREW}.tar.gz" &&
  ./"${KREW}" install krew
)
```

2. Add the `krew` plugin path to your environment:

```bash
export PATH="${KREW_ROOT:-$HOME/.krew}/bin:$PATH"
```

3. Install the MinIO Kubernetes plugin:

```bash
kubectl krew install minio
```

4. Verify the installation:

```bash
kubectl minio version
```

### 3. **Alternative Method: Install MinIO Operator Plugin Manually**

If you do not use `kubectl krew`, you can manually install the plugin:

1. Download the MinIO plugin:

```bash
wget https://github.com/minio/operator/releases/download/v4.5.8/kubectl-minio-linux-amd64
```

2. Make it executable and move it to `/usr/local/bin/`:

```bash
chmod +x kubectl-minio-linux-amd64
sudo mv kubectl-minio-linux-amd64 /usr/local/bin/kubectl-minio
```

3. Verify the installation:

```bash
kubectl minio version
```

This will install the MinIO plugin on your Ubuntu 22.04 system, enabling you to manage MinIO resources using `kubectl minio`.

