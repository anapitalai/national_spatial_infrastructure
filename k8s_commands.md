kubectl get secret/console-sa-secret -n minio-operator -o json | jq -r '.data.token' | base64 -d

kubectl -n minio-operator port-forward svc/console 9090 --address 0.0.0.0 &

kubectl port-forward svc/myminio-console 9443:9443 -n minio-tenant --address 0.0.0.0 &

kubectl get service tenant1-console -n ns -o yaml > servicename.yaml

When installing kubectl minio -plugin, this should match the minio operator version.

tenant create using minio plugin
kubectl minio tenant create minio-uni-tenant --capacity 5Gi --servers 1 --volumes 2 --namespace minio-uni --storage-class local-path --enable-host-sharing --disable-tls

| Server | Volume | Capacity | Total Space |
| :----- | :----: | -------: | ----------: |
| 2      |   2    |     10GB |        40GB |
| 2      |   2    |      5GB |        20GB |
| 2      |   1    |     10GB |        20GB |

Tenant 'unitech' created in 'unitech' Namespace

Username: V0KEBH8LT1G90BJ9R4US
Password: SjF8VhVG03HuL0JYDea4VJpLZVmfqAse97jw910w
Note: Copy the credentials to a secure location. MinIO will not display these again.

APPLICATION SERVICE NAME NAMESPACE SERVICE TYPE SERVICE PORT
MinIO minio unitech ClusterIP 80  
Console unitech-console unitech ClusterIP 9090

## Install nginx ingress

kubectl apply -f https://raw.githubusercontent.com/kubernetes/ingress-nginx/controller-v1.11.2/deploy/static/provider/cloud/deploy.yaml

## ideas of using gnix ingress with metallb

https://kubernetes.github.io/ingress-nginx/deploy/baremetal/

## KUBADM commands

## taints prevents pods runnning on the master node, in production, dont run pods in the master node

Remove the taint from master node in dev environment
kubectl taint nodes <node-name> node-role.kubernetes.io/control-plane-

## install weaveNet

kubectl apply -f https://github.com/weaveworks/weave/releases/download/v2.8.1/weave-daemonset-k8s.yaml

## local path provisoner

kubectl apply -f https://raw.githubusercontent.com/rancher/local-path-provisioner/v0.0.29/deploy/local-path-storage.yaml

## set storage class to default

kubectl patch storageclass local-path -p '{"metadata": {"annotations":{"storageclass.kubernetes.io/is-default-class":"true"}}}'

### Non default

kubectl patch storageclass local-path -p '{"metadata": {"annotations":{"storageclass.kubernetes.io/is-default-class":"false"}}}'

## Minio tenants

kubectl kustomize https://github.com/minio/operator/examples/kustomization/base/ > tenant-base.yaml

## alpine pod

kubectl run alpine --image=alpine -it

## POSTGIS

https://github.com/cloudnative-pg/postgis-containers

## export commands

export PATH="${KREW_ROOT:-$HOME/.krew}/bin:$PATH"
KUBECONFIG=/etc/kubernetes/admin.conf


## pgadmin4

To access this pgAdmin instance, use the following credentials:

username: user@pgadmin.com
password: Bl6FWU70mEb8B7BVuJ00JdRrKNT6tp00

To establish a connection to the database server, you'll need the password for
the 'app' user. Retrieve it with the following
command:

kubectl get secret cluster-example-app -o 'jsonpath={.data.password}' | base64 -d; echo ""

Easily reach the new pgAdmin4 instance by forwarding your local 8080 port using:

kubectl rollout status deployment cluster-example-pgadmin4
kubectl port-forward deployment/cluster-example-pgadmin4 8080:80

Then, navigate to http://localhost:8080 in your browser.

To remove this pgAdmin deployment, execute:

kubectl cnpg pgadmin4 cluster-example --dry-run | kubectl delete -f -

https://min.io/docs/minio/kubernetes/upstream/index.html
https://min.io/docs/minio/kubernetes/upstream/operations/install-deploy-manage/upgrade-minio-operator.html

To start using your cluster, you need to run the following as a regular user:

mkdir -p $HOME/.kube
  sudo cp -i /etc/kubernetes/admin.conf $HOME/.kube/config
  sudo chown $(id -u):$(id -g) $HOME/.kube/config




## get minio operator version
kubectl describe deployment minio-operator -n minio-operator


## minio in docker
https://kodekloud.com/community/t/setting-up-object-storage-with-minio-with-docker/336624


docker run \
-d \
-p 9000:9000 \
-p 9001:9001 \
--name minio \
-e "MINIO_ROOT_USER=minino" \
-e "MINIO_ROOT_PASSWORD=minio123" \
-v /mnt/data:/data \
--restart=always \
quay.io/minio/minio server /data --console-address ":9001"

https://min.io/docs/minio/linux/administration/bucket-replication/enable-server-side-one-way-bucket-replication.html

==================
To access this pgAdmin instance, use the following credentials:

username: user@pgadmin.com
password: k4s9Q0ThaPkyutRnr1rsS548r59NAy5g


To establish a connection to the database server, you'll need the password for
the 'app' user. Retrieve it with the following
command:

kubectl get secret png-nsdi-app -o 'jsonpath={.data.password}' | base64 -d; echo ""
e9DLDNCdRDkOjkzw8fZXDP0llk93EyAiOqgyW2QUYQj04pKCgMxy0HuUitn3WqMO

Easily reach the new pgAdmin4 instance by forwarding your local 8080 port using:

kubectl rollout status deployment png-nsdi-pgadmin4
kubectl port-forward deployment/png-nsdi-pgadmin4 8080:80

Then, navigate to http://localhost:8080 in your browser.

To remove this pgAdmin deployment, execute:


kubectl cnpg pgadmin4 png-nsdi --dry-run | kubectl delete -f -