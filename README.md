# national_spatial_infrastructure

## Install the k8s cluster in the two servers

### geodata1-127 and geodat2-129

### change the datetime tzslect and date -s “2 June 2023 14:05:00”

## Installing Kubernetes on both servers

Deciding which CRI to use is abit tricky, whether to use docker,container ,etc

Install the cri-dockerd CRI
https://www.mirantis.com/blog/how-to-install-cri-dockerd-and-migrate-nodes-from-dockershim
https://www.jjworld.fr/kubernetes-installation/
https://github.com/Mirantis/cri-dockerd

## In nodes, install postgresql and minio as the database

## Installing K8S

Install docker
Install CRI cri-dockerd
Install kubelet, kubeadmin, kubectl

## Using timeshift for creatign snapshots

> > timeshift --create --comments "A new backup" --tags D
> > --tags D stands for Daily Backup
> > --tags W stands for Weekly Backup
> > --tags M stands for Monthly Backup
> > --tags O stands for On-demand Backup

> > timeshift --restore

## Install minio

https://min.io/docs/minio/kubernetes/upstream/index.html
https://min.io/docs/minio/kubernetes/upstream/operations/installation.html#minio-operator-installation

## Ports used by K8s master

Control plane
Protocol Direction Port Range Purpose Used By
TCP Inbound 6443 Kubernetes API server All
TCP Inbound 2379-2380 etcd server client API kube-apiserver, etcd
TCP Inbound 10250 Kubelet API Self, Control plane
TCP Inbound 10259 kube-scheduler Self
TCP Inbound 10257 kube-controller-manager Self

## Used kubectl commands

kubectl run nginx --image=nginx
get pods --all-namespaces
get nodes
describe pod <podname>
delete pod <podname>
api-resources
apply -f <yml file>
create namespace <namespace>
get pods -o wide
get pods -n kube-system -o wide

## minio

        describe pod/minio -n minio-dev
        port-forward pod/minio 9000 9090 -n minio-dev
        logs pod/minio -n minio-dev

## change namespaces

        config set-context --current --namespaces=<namespace>

# eg: kubectl config set-context --current --namespace=minio-operator

        get all -A
        get all --ns <operator>

## show labels

        get node --show-labels

## kubeadmin commands

kubeadm token create --print-join-command
init
init --pod-network-cidr=10.244.0.0/16 –apiserver-advertise-address=<ip_master> --cri-socket unix:///var/run/cri-dockerd.sock
reset
kubectl delete pod [pod_name] -n [namespace] --grace-period 0 --force

## taints

kubectl describe node k8s-master | grep Taints
kubectl taint node k8s-master node-role.kubernetes.io/control-plane:NoSchedule-

## Nodes

Worker node(s)
Protocol Direction Port Range Purpose Used By
TCP Inbound 10250 Kubelet API Self, Control plane
TCP Inbound 10256 kube-proxy Self, Load balancers
TCP Inbound 30000-32767 NodePort Services† All

## kubectl create -f https://raw.githubusercontent.com/projectcalico/calico/v3.28.0/manifests/tigera-operator.yaml

kubectl apply -f https://reweave.azurewebsites.net/k8s/v1.29/net.yaml

## Install minio operator for multitenant creation

https://min.io/docs/minio/kubernetes/upstream/operations/installation.html#minio-operator-installation

--pod-network-cidr=10.244.0.0/16 - flannel network
--pod-network-cidr=10.244.0.0/16 - weaveNet
cidr=192.168.0.0/16 -calico

## Define these

High availability
Fail Over Clusters

# Youtube to install grafana n prometheus,

## Kubernetes Monitoring with Prometheus and Grafana | Kubernetes Training | Edureka Rewind

What is GRAFANA? a multiplatform FOSS anyltics and interactive visualization web app.
What is Prometheus?A software app used for event monitoring and alerting.
What is Helm ? It helps manage k8s applications. Helm charts help you define, install and upgrade k8s apps.

wg set wg0 peer Lmal5IcZDYXz9t6kuDnRMpWmHK0FxlTaFgsUQ7sN/Gg= allowed-ips 10.0.0.2/32

Calica
https://docs.tigera.io/calico/latest/getting-started/kubernetes/quickstart

https://kubernetes.io/docs/tasks/configure-pod-container/assign-pods-nodes/#add-a-label-to-a-node


## Disable IPV6
vi /etc/sysctl.conf
Add the following lines to the file:

net.ipv6.conf.all.disable_ipv6=1
net.ipv6.conf.default.disable_ipv6=1
net.ipv6.conf.lo.disable_ipv6=1

For the settings to take effect use:
sysctl -p

## Cloud Native PG
https://github.com/cloudnative-pg/

## Mutiple Control Planes
https://github.com/frankisinfotech/k8s-HA-Multi-Master-Node
https://www.learnitguide.net/2021/10/kubernetes-multi-master-setup-with.html