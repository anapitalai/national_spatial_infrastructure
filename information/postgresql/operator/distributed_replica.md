## unitech-cluster
apiVersion: postgresql.cnpg.io/v1
kind: Cluster
metadata:
  name: png-nsdi-unitech
spec:
  instances: 3
  replica:
    primary: png-nsdi-unitech
    source: png-nsdi-sydney
  # Distributed topology configuration
externalClusters:
  - name: png-nsdi-unitech
    barmanObjectStore:
      destinationPath: s3://cluster-eu-south/
      # Additional configuration
  - name: png-nsdi-sydney
    barmanObjectStore:
      destinationPath: s3://cluster-eu-central/
      # Additional configuration
  ## enable asynchronous backup
  postgresql:
    syncReplicaElectionConstraint:
      enabled: true
      nodeLabelsAntiAffinity:
      - topology.kubernetes.io/zone  
  imageName: ghcr.io/cloudnative-pg/postgis:16
  ## backup functionality
  primaryUpdateStrategy: unsupervised
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
    size: 2Gi
  ## enable backup
  backup:
    barmanObjectStore:
      destinationPath: s3://202.1.32.102:9000/gps
      endpointURL: http://202.1.32.102:9000
      s3Credentials:
        accessKeyId:
          name: minio
          key: minio123
        secretAccessKey:
          name: aws-creds
          key: ACCESS_SECRET_KEY
      wal:
        compression: gzip
---------------------------------------------------------------------
## sydney-cluster
apiVersion: postgresql.cnpg.io/v1
kind: Cluster
metadata:
  name: png-nsdi-sydney
spec:
  instances: 3
  replica:
  primary: png-nsdi-sydney
  source: png-nsdi-sydney
  
  ## external cluster
  # Distributed topology configuration
externalClusters:
  - name: cluster-eu-south
    barmanObjectStore:
      destinationPath: s3://cluster-eu-south/
      # Additional configuration
  - name: cluster-eu-central
    barmanObjectStore:
      destinationPath: s3://cluster-eu-central/
      # Additional configuration

  ## enable asynchronous backup
  postgresql:
    syncReplicaElectionConstraint:
      enabled: true
      nodeLabelsAntiAffinity:
      - topology.kubernetes.io/zone  
  imageName: ghcr.io/cloudnative-pg/postgis:16
  ## backup functionality
  primaryUpdateStrategy: unsupervised
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
    size: 2Gi
  ## enable backup
  backup:
    barmanObjectStore:
      destinationPath: s3://202.1.32.102:9000/gps
      endpointURL: http://202.1.32.102:9000
      s3Credentials:
        accessKeyId:
          name: minio
          key: minio123
        secretAccessKey:
          name: aws-creds
          key: ACCESS_SECRET_KEY
      wal:
        compression: gzip