# Installing and Using Kubernetes (k8s)

## Prerequisites
- Linux machine (Ubuntu/Debian recommended)
- At least 2 CPUs
- At least 2GB RAM
- Docker installed
- sudo privileges

## 1. Installing Kubernetes Components

### Install Required Packages
```bash
# Update package list
sudo apt-get update

# Install required packages
sudo apt-get install -y apt-transport-https ca-certificates curl software-properties-common

# Add Kubernetes apt repository
curl -s https://packages.cloud.google.com/apt/doc/apt-key.gpg | sudo apt-key add -
echo "deb https://apt.kubernetes.io/ kubernetes-xenial main" | sudo tee /etc/apt/sources.list.d/kubernetes.list

# Update package list again
sudo apt-get update

# Install kubelet, kubeadm, and kubectl
sudo apt-get install -y kubelet kubeadm kubectl

# Pin their versions
sudo apt-mark hold kubelet kubeadm kubectl
```

### Configure Docker
```bash
# Create Docker daemon configuration
cat << EOF | sudo tee /etc/docker/daemon.json
{
  "exec-opts": ["native.cgroupdriver=systemd"],
  "log-driver": "json-file",
  "log-opts": {
    "max-size": "100m"
  },
  "storage-driver": "overlay2"
}
EOF

# Restart Docker
sudo systemctl restart docker
```

## 2. Initialize Kubernetes Cluster

### Master Node Setup
```bash
# Initialize the cluster
sudo kubeadm init --pod-network-cidr=10.244.0.0/16

# Set up kubectl for your user
mkdir -p $HOME/.kube
sudo cp -i /etc/kubernetes/admin.conf $HOME/.kube/config
sudo chown $(id -u):$(id -g) $HOME/.kube/config

# Install network plugin (Flannel)
kubectl apply -f https://raw.githubusercontent.com/coreos/flannel/master/Documentation/kube-flannel.yml
```

### Worker Node Setup (Optional)
After initializing the master node, you'll get a command like this to run on worker nodes:
```bash
sudo kubeadm join <master-ip>:6443 --token <token> --discovery-token-ca-cert-hash <hash>
```

## 3. Verify Installation
```bash
# Check node status
kubectl get nodes

# Check system pods
kubectl get pods --all-namespaces
```

## 4. Basic Kubernetes Usage

### Pod Management
```bash
# Create a pod
kubectl run nginx --image=nginx

# List pods
kubectl get pods

# Get pod details
kubectl describe pod <pod-name>

# Delete pod
kubectl delete pod <pod-name>
```

### Deployment Management
```yaml
# example-deployment.yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: nginx-deployment
spec:
  replicas: 3
  selector:
    matchLabels:
      app: nginx
  template:
    metadata:
      labels:
        app: nginx
    spec:
      containers:
      - name: nginx
        image: nginx:1.14.2
        ports:
        - containerPort: 80
```

```bash
# Apply deployment
kubectl apply -f example-deployment.yaml

# List deployments
kubectl get deployments

# Scale deployment
kubectl scale deployment nginx-deployment --replicas=5

# Update deployment
kubectl set image deployment/nginx-deployment nginx=nginx:1.15
```

### Service Management
```yaml
# example-service.yaml
apiVersion: v1
kind: Service
metadata:
  name: nginx-service
spec:
  selector:
    app: nginx
  ports:
    - protocol: TCP
      port: 80
      targetPort: 80
  type: LoadBalancer
```

```bash
# Create service
kubectl apply -f example-service.yaml

# List services
kubectl get services

# Get service details
kubectl describe service nginx-service
```

## 5. Useful Commands

### Cluster Management
```bash
# Get cluster info
kubectl cluster-info

# Get component status
kubectl get componentstatuses

# Get namespace list
kubectl get namespaces
```

### Troubleshooting
```bash
# Get pod logs
kubectl logs <pod-name>

# Execute command in pod
kubectl exec -it <pod-name> -- /bin/bash

# Get resource usage
kubectl top nodes
kubectl top pods
```

### Configuration
```bash
# Get current context
kubectl config current-context

# View kubeconfig
kubectl config view

# Set namespace for context
kubectl config set-context --current --namespace=<namespace>
```

## 6. Best Practices

1. **Resource Management**
   - Always set resource limits and requests
   - Use namespaces for isolation
   - Implement pod disruption budgets

2. **Security**
   - Use RBAC for access control
   - Keep Kubernetes version updated
   - Use network policies
   - Enable audit logging

3. **High Availability**
   - Deploy multiple replicas
   - Use pod anti-affinity
   - Implement health checks
   - Use PodDisruptionBudgets

4. **Monitoring**
   - Deploy metrics-server
   - Use Prometheus for monitoring
   - Set up alerting
   - Implement logging solution

## 7. Common Issues and Solutions

1. **Pod Pending State**
   - Check node resources
   - Verify PVC availability
   - Check node taints

2. **Pod CrashLoopBackOff**
   - Check container logs
   - Verify resource limits
   - Check container configuration

3. **Network Issues**
   - Verify network plugin
   - Check service DNS
   - Verify node connectivity

4. **Permission Issues**
   - Check RBAC configuration
   - Verify service account
   - Check pod security policies

## 8. Maintenance

### Backup etcd
```bash
# Backup etcd
sudo ETCDCTL_API=3 etcdctl snapshot save snapshot.db \
  --endpoints=https://127.0.0.1:2379 \
  --cacert=/etc/kubernetes/pki/etcd/ca.crt \
  --cert=/etc/kubernetes/pki/etcd/server.crt \
  --key=/etc/kubernetes/pki/etcd/server.key
```

### Update Kubernetes
```bash
# Update kubeadm
sudo apt-get update
sudo apt-get upgrade kubeadm

# Plan the upgrade
kubeadm upgrade plan

# Apply the upgrade
sudo kubeadm upgrade apply v<version>

# Upgrade kubelet
sudo apt-get upgrade kubelet
sudo systemctl restart kubelet
```
