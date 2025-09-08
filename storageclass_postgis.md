apiVersion: storage.k8s.io/v1
kind: StorageClass
metadata:
  name: nsdi-postgis-storage
provisioner: rancher.io/local-path
reclaimPolicy: Delete
volumeBindingMode: WaitForFirstConsumer
allowVolumeExpansion: true
---
apiVersion: postgresql.cnpg.io/v1
kind: Cluster
metadata:
  name: nsdi-postgis-stac
spec:
  instances: 1
  imageName: ghcr.io/cloudnative-pg/postgis:17
  storage:
    size: 5Gi
    storageClass: nsdi-postgis-storage
  postgresql:
    parameters:
      log_statement: ddl
  bootstrap:
    initdb:
      postInitTemplateSQL:
        - CREATE EXTENSION IF NOT EXISTS postgis;
        - CREATE EXTENSION IF NOT EXISTS postgis_topology;
        - CREATE EXTENSION IF NOT EXISTS fuzzystrmatch;
        - CREATE EXTENSION IF NOT EXISTS postgis_tiger_geocoder;
        - |
          CREATE SCHEMA IF NOT EXISTS stac;
          CREATE TABLE IF NOT EXISTS stac.collections (
            id TEXT PRIMARY KEY,
            description TEXT,
            title TEXT,
            keywords TEXT[],
            version TEXT,
            license TEXT,
            providers JSONB,
            extent JSONB,
            links JSONB,
            summaries JSONB
          );
          CREATE TABLE IF NOT EXISTS stac.items (
            id TEXT PRIMARY KEY,
            collection_id TEXT REFERENCES stac.collections(id),
            geometry JSONB,
            bbox DOUBLE PRECISION[],
            properties JSONB,
            assets JSONB,
            links JSONB,
            datetime TIMESTAMP WITH TIME ZONE,
            created TIMESTAMP WITH TIME ZONE DEFAULT now(),
            updated TIMESTAMP WITH TIME ZONE DEFAULT now()
          );
          CREATE INDEX IF NOT EXISTS idx_stac_items_geom ON stac.items USING GIST (ST_SetSRID(ST_GeomFromGeoJSON(geometry::text), 4326));
          CREATE INDEX IF NOT EXISTS idx_stac_items_datetime ON stac.items (datetime);
---
apiVersion: v1
kind: PersistentVolumeClaim
metadata:
  name: nsdi-postgis-pvc
spec:
  accessModes:
    - ReadWriteOnce
  storageClassName: nsdi-postgis-storage
  resources:
    requests:
      storage: 5Gi
# You can expand this PVC by editing the storage request (e.g., to 5Gi) and applying the change:
# kubectl edit pvc nsdi-postgis-pvc
# Then increase the storage value under 'resources.requests.storage'.
---
# Example pgAdmin4 Deployment
apiVersion: apps/v1
kind: Deployment
metadata:
  name: pgadmin4
spec:
  replicas: 2
  selector:
    matchLabels:
      app: pgadmin4
  template:
    metadata:
      labels:
        app: pgadmin4
    spec:
      containers:
      - name: pgadmin4
        image: dpage/pgadmin4:latest
        env:
        - name: PGADMIN_DEFAULT_EMAIL
          value: "anapitalai@gmail.com"
        - name: PGADMIN_DEFAULT_PASSWORD
          value: "pgadmin123"
        ports:
        - containerPort: 80
        volumeMounts:
        - name: pgadmin-data
          mountPath: /var/lib/pgadmin
      volumes:
      - name: pgadmin-data
        emptyDir: {}
---
apiVersion: v1
kind: Service
metadata:
  name: pgadmin4
spec:
  type: NodePort
  selector:
    app: pgadmin4
  ports:
    - port: 80
      targetPort: 80
      nodePort: 30080

