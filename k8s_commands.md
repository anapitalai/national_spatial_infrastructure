kubectl get secret/console-sa-secret -n minio-operator -o json | jq -r '.data.token' | base64 -d

kubectl -n minio-operator port-forward svc/console 9090 --address 0.0.0.0 &

kubectl port-forward svc/myminio-console 9443:9443 -n minio-tenant --address 0.0.0.0 &

kubectl get service tenant1-console -n ns -o yaml > servicename.yaml

When installing kubectl minio -plugin, this should match the minio operator version.

tenant create using minio plugin
kubectl minio tenant create minio-uni-tenant --capacity 5Gi --servers 1 --volumes 2 --namespace minio-uni --storage-class local-path --enable-host-sharing --disable-tls

| Server | Volume | Capacity  | Total Space |
|:-------|:------:|----------:|------------:| 
| 2      |    2   |    10GB   |  40GB       |    
| 2      |    2   |    5GB    |   20GB      |
| 2      |    1   |    10GB   |   20GB     |


Tenant 'unitech' created in 'unitech' Namespace

  Username: V0KEBH8LT1G90BJ9R4US 
  Password: SjF8VhVG03HuL0JYDea4VJpLZVmfqAse97jw910w 
  Note: Copy the credentials to a secure location. MinIO will not display these again.

APPLICATION     SERVICE NAME    NAMESPACE       SERVICE TYPE    SERVICE PORT 
MinIO           minio           unitech         ClusterIP       80          
Console         unitech-console unitech         ClusterIP       9090

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