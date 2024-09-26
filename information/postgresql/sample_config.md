apiVersion: postgresql.cnpg.io/v1
kind: Cluster
metadata:
  name: postgis-example
spec:
  instances: 3
  ## backup
  startDelay: 300
  stopDelay: 300
  primaryUpdateStrategy: unsupervised
  
  imageName: ghcr.io/cloudnative-pg/postgis:16.4
  bootstrap:
    initdb:
      postInitTemplateSQL:
        - CREATE EXTENSION postgis;
        - CREATE EXTENSION postgis_topology;
        - CREATE EXTENSION fuzzystrmatch;
        - CREATE EXTENSION postgis_tiger_geocoder;

  storage:
  ## storage with storage class
    storageClass: standard
    size: 1Gi
  
