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
>> timeshift --create --comments "A new backup" --tags D
--tags D stands for Daily Backup
--tags W stands for Weekly Backup
--tags M stands for Monthly Backup
--tags O stands for On-demand Backup

>> timeshift --restore

## Ports used by K8s master
Control plane 
Protocol	Direction	Port Range	Purpose	Used By
TCP	Inbound	6443	Kubernetes API server	All
TCP	Inbound	2379-2380	etcd server client API	kube-apiserver, etcd
TCP	Inbound	10250	Kubelet API	Self, Control plane
TCP	Inbound	10259	kube-scheduler	Self
TCP	Inbound	10257	kube-controller-manager	Self
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
## change namespaces
        config set-context --current --namespaces=<namespace>
#       eg: kubectl config set-context --current --namespace=minio-operator
        get all -A
        get all --ns <operator>
## kubeadmin commands
kubeadm token create --print-join-command
        init
        init --pod-network-cidr=10.244.0.0/16 –apiserver-advertise-address=<ip_master> --cri-socket unix:///var/run/cri-dockerd.sock
        reset
## Nodes
Worker node(s) 
Protocol	Direction	Port Range	Purpose	Used By
TCP	Inbound	10250	Kubelet API	Self, Control plane
TCP	Inbound	10256	kube-proxy	Self, Load balancers
TCP	Inbound	30000-32767	NodePort Services†	All

## Install minio operator for multitenant creation 
https://min.io/docs/minio/kubernetes/upstream/operations/installation.html#minio-operator-installation


## Define these 
High availability
Fail Over Clusters
What is GRAFANA? a multiplatform FOSS anyltics and interactive visualization web app.
What is Prometheus?A software app used for event monitoring and alerting.
What is Helm ? It helps manage k8s applications. Helm charts help you define, install and upgrade k8s apps.