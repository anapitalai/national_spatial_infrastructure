## Operator deployment via declarative configuration
- The operator is installed in a declarative way using a Kubernetes manifest that defines four major CustomResourceDefinition objects: 
  - Cluster
  - Pooler
  - Backup
  - ScheduledBackup

- PostgreSQL cluster deployment via declarative configuration
You define a PostgreSQL cluster (operand) using the Cluster custom resource in a fully declarative way. The PostgreSQL version is determined by the operand container image defined in the CR, which is automatically fetched from the requested registry. When deploying an operand, the operator also creates the following resources: 
  - Pod
  - Service
  - Secret
  - ConfigMap
  - PersistentVolumeClaim
  - PodDisruptionBudget
  - ServiceAccount
  - RoleBinding
  - Role