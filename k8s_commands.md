kubectl get secret/console-sa-secret -n minio-operator -o json | jq -r '.data.token' | base64 -d

kubectl -n minio-operator port-forward svc/console 9090 --address 0.0.0.0 &