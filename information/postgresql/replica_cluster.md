### Master
apiVersion: postgresql.cnpg.io/v1
kind: Cluster
metadata:
  name: sydney-master-cluster
  namespace: nsdi-replica
spec:
  instances: 1
  imageName: ghcr.io/cloudnative-pg/postgresql:16.4
  enableSuperuserAccess: true
  storage:
    size: 1Gi
    storageClass: standard
  replicationSlots:
    maxSlots: 5
  bootstrap:
    initdb:
      postInitApplicationSQL:
        - CREATE EXTENSION IF NOT EXISTS postgis;
        - CREATE EXTENSION IF NOT EXISTS vector;
        - CREATE EXTENSION IF NOT EXISTS hstore;
        - CREATE EXTENSION IF NOT EXISTS pointcloud;
        - CREATE EXTENSION IF NOT EXISTS pointcloud_postgis;
        - CREATE EXTENSION IF NOT EXISTS postgres_fdw;
        - CREATE EXTENSION IF NOT EXISTS postgis_topology;
        - CREATE EXTENSION IF NOT EXISTS fuzzystrmatch;
        - CREATE EXTENSION IF NOT EXISTS postgis_tiger_geocoder;

## Replica
apiVersion: postgresql.cnpg.io/v1
kind: Cluster
metadata:
  name: unitech-replica-cluster
  namespace: nsdi-replica
spec:
  instances: 1
  imageName: ghcr.io/cloudnative-pg/postgresql:16.4
  enableSuperuserAccess: true
  storage:
    size: 10Gi
    storageClass: standard
  externalClusters:
    - name: sydney-master-cluster
      connection:
        host: unitech.raliku.com
        port: 5432
        user: anapitalai
        password:
          name: replication-secret  # Kubernetes secret for replication user
        database: postgres  # Main database to replicate
  replicationSlots:
    maxSlots: 5
    slot:
      - name: replica_slot  # Slot name to ensure WAL shipping
        type: physical
