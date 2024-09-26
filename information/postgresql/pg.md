apiVersion: v1
data:
  password: VHhWZVE0bk44MlNTaVlIb3N3cU9VUlp2UURhTDRLcE5FbHNDRUVlOWJ3RHhNZDczS2NrSWVYelM1Y1U2TGlDMg==
  username: YXBw
kind: Secret
metadata:
  name: cluster-example-app-user
type: kubernetes.io/basic-auth
---
apiVersion: v1
data:
  password: dU4zaTFIaDBiWWJDYzRUeVZBYWNCaG1TemdxdHpxeG1PVmpBbjBRSUNoc0pyU211OVBZMmZ3MnE4RUtLTHBaOQ==
  username: cG9zdGdyZXM=
kind: Secret
metadata:
  name: cluster-example-superuser
type: kubernetes.io/basic-auth
---
apiVersion: v1
kind: Secret
metadata:
  name: backup-creds
data:
  ACCESS_KEY_ID: a2V5X2lk
  ACCESS_SECRET_KEY: c2VjcmV0X2tleQ==
---
apiVersion: postgresql.cnpg.io/v1
kind: Cluster
metadata:
  name: png-nsdi
spec:
  instances: 3

  startDelay: 300
  stopDelay: 300
  primaryUpdateStrategy: unsupervised
  imageName: ghcr.io/cloudnative-pg/postgis:16-3.4
  postgresql:
    parameters:
      shared_buffers: "256MB"  # Ensure values are quoted for consistency
      pg_stat_statements.max: "10000"
      pg_stat_statements.track: "all"
      auto_explain.log_min_duration: "10s"
    pg_hba:
      - host all all 0.0.0.0/0 md5
  bootstrap:
    initdb:
      postInitTemplateSQL:
        - CREATE EXTENSION postgis;
        - CREATE EXTENSION postgis_topology;
        - CREATE EXTENSION fuzzystrmatch;
        - CREATE EXTENSION postgis_tiger_geocoder;

  storage:
    size: 1Gi
---
apiVersion: v1
kind: Service
metadata:
  name: png-nsdi-lb
  namespace: png-nsdi-ns  # Ensure correct namespace
spec:
  type: LoadBalancer
  loadBalancerIP: 170.64.179.236
  ports:
    - name: '5432'
      protocol: TCP
      port: 5432
      targetPort: 5432
  selector:
    app: png-nsdi  # Ensure this matches the labels of your PostgreSQL pods
                                                                                 