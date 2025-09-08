# Designing a Multi-tenant Application with Next.js for Spatial Data Infrastructure

A multi-tenant application is a software architecture where a single instance of the application serves multiple customers (tenants) while keeping their data isolated. This guide focuses on implementing a multi-tenant application using Next.js with PostGIS STAC-compliant data and MinIO object storage.

## Core Infrastructure Components

### 1. PostGIS STAC Setup in Kubernetes
```yaml
# kubernetes/postgresql/statefulset.yaml
apiVersion: apps/v1
kind: StatefulSet
metadata:
  name: postgis-cluster
spec:
  serviceName: postgis
  replicas: 3
  template:
    spec:
      containers:
      - name: postgres
        image: postgis/postgis:15-3.3
        env:
        - name: POSTGRES_DB
          value: spatial_db
        - name: REPLICATION_MODE
          value: "logical"
        volumeMounts:
        - name: postgis-data
          mountPath: /var/lib/postgresql/data
  volumeClaimTemplates:
  - metadata:
      name: postgis-data
    spec:
      accessModes: [ "ReadWriteOnce" ]
      resources:
        requests:
          storage: 100Gi
---
# kubernetes/postgresql/configmap.yaml
apiVersion: v1
kind: ConfigMap
metadata:
  name: postgres-config
data:
  postgresql.conf: |
    wal_level = logical
    max_worker_processes = 10
    max_replication_slots = 10
    max_wal_senders = 10
```

### 2. MinIO Tenant Operator Setup
```yaml
# kubernetes/minio/tenant.yaml
apiVersion: minio.min.io/v2
kind: Tenant
metadata:
  name: minio-tenant
spec:
  pools:
    - servers: 4
      volumesPerServer: 4
      volumeClaimTemplate:
        spec:
          accessModes:
            - ReadWriteOnce
          resources:
            requests:
              storage: 1Ti
  credsSecret:
    name: minio-creds
  configuration:
    name: minio-config
---
# kubernetes/minio/tenant-service.yaml
apiVersion: v1
kind: Service
metadata:
  name: minio-service
spec:
  type: LoadBalancer
  ports:
    - port: 9000
      targetPort: 9000
  selector:
    app: minio-tenant
```

### 3. Database Replication Configuration
```yaml
# kubernetes/postgresql/replication-config.yaml
apiVersion: postgres-operator.crunchydata.com/v1beta1
kind: PostgresCluster
metadata:
  name: spatial-cluster
spec:
  instances:
    - name: instance1
      replicas: 3
      dataVolumeClaimSpec:
        accessModes:
        - "ReadWriteOnce"
        resources:
          requests:
            storage: 100Gi
  patroni:
    dynamicConfiguration:
      postgresql:
        parameters:
          max_connections: "100"
          shared_buffers: 4GB
  proxy:
    pgBouncer:
      replicas: 2
```

### 4. Remote Sensing Processing Pipeline
- Distributed processing using Dask
- GDAL/rasterio integration
- Support for common satellite data sources:
  - Sentinel-2
  - Landsat
  - Planet Labs
  - Custom imagery

### 4. Analysis Components
- Interactive Jupyter notebooks per tenant
- Real-time visualization of analysis results
- Common analysis workflows:
  - NDVI calculation
  - Change detection
  - Land cover classification
  - Custom indices computation

## 1. Database Design

### Tenant Isolation Strategies for Spatial Data

1. **PostGIS Database Strategy**
   - Separate schemas per tenant for STAC metadata
   - Shared postgis_topology schema
   - Tenant-specific spatial reference systems
   - Row-level security for shared tables

2. **MinIO Storage Strategy**
   - Isolated buckets per tenant
   - Tenant-specific access policies
   - Shared processing workspaces

3. **STAC Metadata Organization**
   - Tenant-specific STAC collections
   - Isolated STAC catalogs
   - Shared base layers with tenant-specific overlays

### Kubernetes-aware PostGIS Implementation
```yaml
# kubernetes/postgresql/init-config.yaml
apiVersion: v1
kind: ConfigMap
metadata:
  name: init-postgis
data:
  init.sql: |
    CREATE EXTENSION IF NOT EXISTS postgis;
    
    -- Function to create tenant schema
    CREATE OR REPLACE FUNCTION create_tenant_schema(tenant_id text)
    RETURNS void AS $$
    BEGIN
      EXECUTE format('CREATE SCHEMA IF NOT EXISTS tenant_%I', tenant_id);
      EXECUTE format('CREATE EXTENSION IF NOT EXISTS postgis WITH SCHEMA tenant_%I', tenant_id);
      
      -- Set up replication for the tenant schema
      EXECUTE format(
        'SELECT pg_create_logical_replication_slot(''tenant_%I_slot'', ''pgoutput'')',
        tenant_id
      );
      
      -- Create publication for tenant schema
      EXECUTE format(
        'CREATE PUBLICATION tenant_%I_pub FOR ALL TABLES IN SCHEMA tenant_%I',
        tenant_id, tenant_id
      );
    END;
    $$ LANGUAGE plpgsql;

-- STAC metadata table example
CREATE TABLE tenant_${id}.collections (
    id VARCHAR PRIMARY KEY,
    title VARCHAR,
    description TEXT,
    spatial_extent GEOMETRY(POLYGON, 4326),
    temporal_extent TSTZRANGE,
    properties JSONB
);
```

### MinIO Bucket Structure
```typescript
// lib/minio-config.ts
export const setupTenantBucket = async (tenant: string) => {
  const minioClient = new MinioClient({
    endPoint: 'minio-server',
    port: 9000,
    useSSL: true,
    accessKey: process.env.MINIO_ACCESS_KEY,
    secretKey: process.env.MINIO_SECRET_KEY
  });

  // Create tenant-specific buckets
  await minioClient.makeBucket(`${tenant}-raster`);
  await minioClient.makeBucket(`${tenant}-vector`);
  await minioClient.makeBucket(`${tenant}-derivatives`);
};

## 2. Authentication & Authorization

### Implementation Steps
1. **Tenant Identification**
   ```typescript
   // middleware.ts
   export function middleware(req: NextRequest) {
     const hostname = req.headers.get('host')
     const tenant = identifyTenant(hostname)
     // Add tenant context to request
   }
   ```

2. **User Authentication**
   - Use Next-Auth or similar solution
   - Implement tenant-aware login flows
   - Store tenant information in JWT

## 3. Application Structure

### Directory Organization
```
src/
├── app/
│   ├── api/
│   │   ├── [tenant]/
│   │   └── analysis/
│   │       ├── compute/
│   │       ├── notebooks/
│   │       └── results/
│   └── [tenant]/
├── components/
│   ├── shared/
│   │   ├── MapViewer/
│   │   ├── AnalysisTools/
│   │   └── Visualizations/
│   └── tenant-specific/
├── lib/
│   ├── tenant/
│   ├── analysis/
│   │   ├── processors/
│   │   ├── algorithms/
│   │   └── visualizations/
│   └── remote-sensing/
│       ├── satellite/
│       ├── indices/
│       └── corrections/
└── workers/
    ├── processing/
    └── analysis/
```

### Remote Sensing Components
```typescript
// lib/remote-sensing/indices/vegetation.ts
export async function calculateNDVI(
  tenant: string,
  imageId: string,
  options: NDVIOptions
) {
  const { red, nir } = await loadBands(tenant, imageId, ['B04', 'B08']);
  return computeIndex(red, nir, 'ndvi', options);
}

// lib/remote-sensing/corrections/atmospheric.ts
export async function applyAtmosphericCorrection(
  tenant: string,
  imageId: string,
  method: 'dos1' | 'simple' | 'full'
) {
  const image = await loadImage(tenant, imageId);
  return await correctAtmosphere(image, method);
}
```

### Key Components
1. **Spatial Data Context Provider**
   ```typescript
   // context/SpatialContext.tsx
   interface SpatialContext {
     tenant: string;
     stacApi: STACApi;
     minioClient: MinioClient;
     postgis: Pool;
   }

   export const SpatialContext = createContext<SpatialContext | null>(null);

   export function SpatialProvider({ children, tenant }) {
     const contextValue = useMemo(() => {
       return {
         tenant,
         stacApi: new STACApi(tenant),
         minioClient: setupMinioClient(tenant),
         postgis: getPostgisPool(tenant)
       };
     }, [tenant]);

     return (
       <SpatialContext.Provider value={contextValue}>
         {children}
       </SpatialContext.Provider>
     );
   }
   ```

2. **Spatial Database Management**
   ```typescript
   // lib/spatial-db.ts
   import { Pool } from 'pg';
   import { getMinioUrl } from './minio-utils';

   export async function getPostgisPool(tenant: string) {
     return new Pool({
       host: process.env.POSTGIS_HOST,
       port: 5432,
       database: 'spatial_db',
       schema: `tenant_${tenant}`,
       user: process.env.POSTGIS_USER,
       password: process.env.POSTGIS_PASSWORD
     });
   }

   export async function querySTACCollection(tenant: string, collectionId: string) {
     const pool = await getPostgisPool(tenant);
     const result = await pool.query(`
       SELECT c.*, 
         array_agg(a.href) as assets
       FROM tenant_${tenant}.collections c
       LEFT JOIN tenant_${tenant}.assets a ON c.id = a.collection_id
       WHERE c.id = $1
       GROUP BY c.id
     `, [collectionId]);
     
     // Transform URLs to MinIO paths
     result.rows[0].assets = result.rows[0].assets.map(getMinioUrl(tenant));
     return result.rows[0];
   }
   ```

## 4. Tenant Configuration

### Configuration Management
1. **Tenant Settings**
   - Theme customization
   - Feature flags
   - Custom domain mapping

2. **Feature Isolation**
   - Implement tenant-specific features
   - Handle different subscription tiers

## 5. Data Isolation

### Implementation Patterns
1. **Request Pipeline**
   - Validate tenant access
   - Enforce data boundaries
   - Handle cross-tenant requests

2. **Query Filters**
   ```typescript
   // Example Prisma query with tenant filter
   const data = await prisma.resource.findMany({
     where: {
       tenantId: currentTenant.id,
       // other filters
     }
   })
   ```

## 6. Deployment Considerations

### Infrastructure Setup
1. **Domain Configuration**
   - Wildcard SSL certificates
   - DNS management
   - Custom domain support

2. **Scaling Strategy**
   - Horizontal scaling
   - Cache strategies per tenant
   - Resource allocation

## 7. Monitoring and Maintenance

### Key Aspects
1. **Tenant-aware Logging**
   ```typescript
   // logger.ts
   export function log(message: string, tenant: string) {
     console.log(`[${tenant}] ${message}`)
     // Send to logging service with tenant context
   }
   ```

2. **Performance Monitoring**
   - Per-tenant metrics
   - Resource usage tracking
   - Alert thresholds

## 8. Security Considerations

### Security Measures
1. **Data Isolation**
   - Strict tenant boundaries
   - Input validation
   - Access control

2. **API Security**
   - Rate limiting per tenant
   - Authentication checks
   - CORS policies

## Kubernetes Deployment and Management

### 1. High Availability Setup
```yaml
# kubernetes/ingress.yaml
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: spatial-ingress
  annotations:
    kubernetes.io/ingress.class: nginx
spec:
  rules:
  - host: "*.spatialapp.com"
    http:
      paths:
      - path: /
        pathType: Prefix
        backend:
          service:
            name: nextjs-service
            port:
              number: 3000
```

### 2. Resource Management
```yaml
# kubernetes/resource-quotas.yaml
apiVersion: v1
kind: ResourceQuota
metadata:
  name: tenant-quota
spec:
  hard:
    requests.cpu: "4"
    requests.memory: 8Gi
    requests.storage: 500Gi
    pods: "20"
```

### 3. Monitoring Stack
```yaml
# kubernetes/monitoring/prometheus-postgresql.yaml
apiVersion: monitoring.coreos.com/v1
kind: ServiceMonitor
metadata:
  name: postgres-metrics
spec:
  selector:
    matchLabels:
      app: postgres
  endpoints:
  - port: metrics
    interval: 30s
```

### 4. Backup Strategy
```yaml
# kubernetes/backup/velero-backup.yaml
apiVersion: velero.io/v1
kind: Schedule
metadata:
  name: daily-backup
spec:
  schedule: "0 0 * * *"
  template:
    includedNamespaces:
    - spatial-infrastructure
    includedResources:
    - persistentvolumeclaims
    - persistentvolumes
    labelSelector:
      matchLabels:
        app: spatial-app
```

## Best Practices for Spatial Multi-tenancy

1. **Data Management**
   - Implement efficient spatial indexing per tenant
   - Use Cloud-Optimized GeoTIFF (COG) for raster data
   - Implement STAC API endpoints for data discovery
   - Cache spatial queries using PostGIS materialized views

2. **Storage Optimization**
   - Use MinIO lifecycle policies for archival data
   - Implement tenant-specific raster overviews
   - Enable compression for vector data
   - Use spatial partitioning for large datasets

3. **Security and Access Control**
   - Implement row-level security in PostGIS
   - Use MinIO IAM policies per tenant
   - Secure spatial web services (WMS/WFS)
   - Regular security audits for data isolation

4. **Performance**
   - Optimize spatial queries per tenant
   - Use spatial caching strategies
   - Implement connection pooling
   - Monitor spatial index usage

5. **Data Integration**
   ```typescript
   // Example of integrating STAC with MinIO
   async function getSTACItem(tenant: string, itemId: string) {
     const pool = await getPostgisPool(tenant);
     const item = await pool.query(`
       SELECT * FROM tenant_${tenant}.stac_items 
       WHERE id = $1
     `, [itemId]);

     // Get MinIO assets
     const assets = await getMinioAssets(tenant, itemId);
     return {
       ...item,
       assets: assets.map(asset => ({
         href: getMinioUrl(tenant, asset),
         type: asset.contentType
       }))
     };
   }
   ```

6. **Backup and Recovery**
   - Regular PostGIS dumps per tenant
   - MinIO bucket replication
   - STAC metadata backups
   - Disaster recovery procedures

## Remote Sensing and Analysis Features

### 1. Satellite Data Processing
```typescript
// components/AnalysisTools/SatelliteProcessor.tsx
import { useSpatialContext } from '@/context/spatial';
import { ProcessingQueue } from '@/lib/processing';

export function SatelliteProcessor() {
  const { tenant, minioClient } = useSpatialContext();
  
  const processImage = async (imageId: string) => {
    const queue = new ProcessingQueue(tenant);
    
    // Define processing pipeline
    await queue.addTask({
      type: 'atmospheric-correction',
      params: { method: 'dos1' }
    });
    
    await queue.addTask({
      type: 'index-calculation',
      params: { index: 'ndvi' }
    });
    
    // Execute pipeline
    const results = await queue.process(imageId);
    await saveResults(tenant, imageId, results);
  };
  
  return (
    // UI Components
  );
}
```

### 2. Analysis Workflows
```typescript
// lib/analysis/workflows/change-detection.ts
export async function detectChanges(
  tenant: string,
  options: {
    baselineImage: string,
    compareImage: string,
    method: 'difference' | 'regression' | 'ml'
  }
) {
  const baseline = await loadProcessedImage(tenant, options.baselineImage);
  const compare = await loadProcessedImage(tenant, options.compareImage);
  
  const changes = await analyzeChanges(baseline, compare, options.method);
  return generateChangeReport(changes);
}
```

### 3. Interactive Notebooks Integration
```typescript
// lib/notebooks/manager.ts
export class NotebookManager {
  constructor(tenant: string) {
    this.kernel = new JupyterKernel({
      tenant,
      environmentPath: `/environments/${tenant}`
    });
  }

  async createAnalysisNotebook(template: 'ndvi' | 'classification' | 'custom') {
    const notebook = await this.loadTemplate(template);
    return this.kernel.createNotebook(notebook);
  }

  async executeCell(notebookId: string, cellId: string) {
    return this.kernel.executeCell(notebookId, cellId);
  }
}
```

### 4. Visualization Components
```typescript
// components/Visualizations/RasterLayer.tsx
export function RasterLayer({ 
  tenant, 
  imageId, 
  renderMode = 'dynamic'
}) {
  const { stacApi } = useSpatialContext();
  
  // Dynamic rendering of raster data with WebGL
  const renderTile = useCallback(async (tile) => {
    const data = await loadTileData(tenant, imageId, tile);
    return processForDisplay(data, renderMode);
  }, [tenant, imageId, renderMode]);
  
  return (
    <WebGLLayer
      getTileData={renderTile}
      colormap={selectedColormap}
      opacity={layerOpacity}
    />
  );
}
```

## Testing Strategy

1. **Unit Tests**
   - Test tenant-specific logic
   - Validate isolation
   - Test processing algorithms
   - Verify analysis results

2. **Integration Tests**
   - Cross-tenant scenarios
   - Data boundary tests
   - Processing pipeline tests
   - Notebook integration tests

3. **End-to-End Tests**
   - Multi-tenant workflows
   - Tenant switching
   - Complete analysis workflows
   - Performance testing for large datasets