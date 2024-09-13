kubectl get secret/console-sa-secret -n minio-operator -o json | jq -r '.data.token' | base64 -d

kubectl -n minio-operator port-forward svc/console 9090 --address 0.0.0.0 &

kubectl port-forward svc/myminio-console 9443:9443 -n minio-tenant --address 0.0.0.0 &

kubectl get service tenant1-console -n ns -o yaml > servicename.yaml

When installing kubectl minio -plugin, this should match the minio operator version.

tenant create using minio plugin
kubectl minio tenant create minio-tenant1 --capacity 20Gi --servers 1 --volumes 1 --namespace minio --storage-class local-path --enable-host-sharing --disable-tls

| Left Aligned | Center Aligned | Right Aligned |
|:-------------|:---------------:|--------------:|
| Row 1 Col 1  | Row 1 Col 2    | Row 1 Col 3  |
| Row 2 Col 1  | Row 2 Col 2    | Row 2 Col 3  |
| Row 3 Col 1  | Row 3 Col 2    | Row 3 Col 3  |
