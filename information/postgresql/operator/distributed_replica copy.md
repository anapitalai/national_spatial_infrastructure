apiVersion: postgresql.cnpg.io/v1
kind: Cluster
metadata:
  name: png-nsdi-unitech
  namespace: png-nsdi
spec:
  instances: 3
  replica:
    primary: png-nsdi-unitech
    source: png-nsdi-sydney

  imageName: ghcr.io/cloudnative-pg/postgis:16
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
          - CREATE EXTENSION IF NOT EXISTS postgis;
          - CREATE EXTENSION IF NOT EXISTS postgis_raster;
          - CREATE EXTENSION IF NOT EXISTS vector;
          - CREATE EXTENSION IF NOT EXISTS hstore;
          - CREATE EXTENSION IF NOT EXISTS pointcloud;
          - CREATE EXTENSION IF NOT EXISTS pointcloud_postgis;
          - CREATE EXTENSION IF NOT EXISTS postgres_fdw;
          - CREATE EXTENSION IF NOT EXISTS postgis_topology;
          - CREATE EXTENSION IF NOT EXISTS fuzzystrmatch;
          - CREATE EXTENSION IF NOT EXISTS postgis_tiger_geocoder;

  storage:
    storageClass: standard
    size: 2Gi

                                                                                 
================================
apiVersion: postgresql.cnpg.io/v1
kind: Cluster
metadata:
  name: png-nsdi-unitech
  namespace: png-ndsi
spec:
  instances: 3
  replica:
    primary: png-nsdi-unitech
    source: png-nsdi-sydney
  externalClusters:
    - name: png-nsdi-unitech
      barmanObjectStore:
        destinationPath: s3://202.1.32.102:9000
        endpointURL: http://202.1.32.102:9000
        s3Credentials:
          accessKeyId:
            name: minio
            key: minio123
          secretAccessKey:
            name: aws-creds
            key: secret_key
    - name: png-nsdi-sydney
      barmanObjectStore:
        destinationPath: s3://170.64.179.236:9000
        endpointURL: http://170.64.179.236:9000
        s3Credentials:
          accessKeyId:
            name: minio
            key: minio123
          secretAccessKey:
            name: aws-creds
            key: secret_key
  postgresql:
    syncReplicaElectionConstraint:
      enabled: true
      nodeLabelsAntiAffinity:
        - topology.kubernetes.io/zone
    imageName: ghcr.io/cloudnative-pg/postgis:16
    bootstrap:
      initdb:
        postInitTemplateSQL:
          - CREATE EXTENSION IF NOT EXISTS postgis;
          - CREATE EXTENSION IF NOT EXISTS postgis_raster;
          - CREATE EXTENSION IF NOT EXISTS vector;
          - CREATE EXTENSION IF NOT EXISTS hstore;
          - CREATE EXTENSION IF NOT EXISTS pointcloud;
          - CREATE EXTENSION IF NOT EXISTS pointcloud_postgis;
          - CREATE EXTENSION IF NOT EXISTS postgres_fdw;
          - CREATE EXTENSION IF NOT EXISTS postgis_topology;
          - CREATE EXTENSION IF NOT EXISTS fuzzystrmatch;
          - CREATE EXTENSION IF NOT EXISTS postgis_tiger_geocoder;
    storage:
      storageClass: standard
      size: 5Gi
      resources:
        requests:
          memory: "2Gi"
          cpu: "1"
        limits:
          memory: "4Gi"
          cpu: "2"
    resources:
      requests:
        memory: "2Gi"
        cpu: "1"
      limits:
        memory: "4Gi"
        cpu: "2"

==============================================

apiVersion: postgresql.cnpg.io/v1
kind: Cluster
metadata:
  name: png-nsdi-sydney
  namespace: png-nsdi
spec:
  instances: 3
  replica:
    primary: png-nsdi-unitech
    source: png-nsdi-unitech
  externalClusters:
    - name: png-nsdi-unitech
      barmanObjectStore:
        destinationPath: s3://202.1.32.102:9000
        endpointURL: http://202.1.32.102:9000
        s3Credentials:
          accessKeyId:
            name: minio
            key: minio123
          secretAccessKey:
            name: aws-creds
            key: secret_key
    - name: png-nsdi-sydney
      barmanObjectStore:
        destinationPath: s3://170.64.179.236:9000
        endpointURL: http://170.64.179.236:9000
        s3Credentials:
          accessKeyId:
            name: minio
            key: minio123
          secretAccessKey:
            name: aws-creds
            key: secret_key
  postgresql:
    syncReplicaElectionConstraint:
      enabled: true
      nodeLabelsAntiAffinity:
        - topology.kubernetes.io/zone
    imageName: ghcr.io/cloudnative-pg/postgis:16
    bootstrap:
      initdb:
        postInitTemplateSQL:
          - CREATE EXTENSION IF NOT EXISTS postgis;
          - CREATE EXTENSION IF NOT EXISTS postgis_raster;
          - CREATE EXTENSION IF NOT EXISTS vector;
          - CREATE EXTENSION IF NOT EXISTS hstore;
          - CREATE EXTENSION IF NOT EXISTS pointcloud;
          - CREATE EXTENSION IF NOT EXISTS pointcloud_postgis;
          - CREATE EXTENSION IF NOT EXISTS postgres_fdw;
          - CREATE EXTENSION IF NOT EXISTS postgis_topology;
          - CREATE EXTENSION IF NOT EXISTS fuzzystrmatch;
          - CREATE EXTENSION IF NOT EXISTS postgis_tiger_geocoder;
    storage:
      storageClass: standard
      size: 5Gi
      resources:
        requests:
          memory: "2Gi"
          cpu: "1"
        limits:
          memory: "4Gi"
          cpu: "2"
    resources:
      requests:
        memory: "2Gi"
        cpu: "1"
      limits:
        memory: "4Gi"
        cpu: "2"

