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

- Override of operand images through the CRD
The operator is designed to support any operand container image with PostgreSQL inside. By default, the operator uses the latest available minor version of the latest stable major version supported by the PostgreSQL community and published on ghcr.io. You can use any compatible image of PostgreSQL supporting the primary/standby architecture directly by setting the imageName attribute in the CR. The operator also supports imagePullSecrets to access private container registries, and it supports digests and tags for finer control of container image immutability. If you prefer not to specify an image name, you can leverage image catalogs by simply referencing the PostgreSQL major version. Moreover, image catalogs enable you to effortlessly create custom catalogs, directing to images based on your specific requirements.

- Labels and annotations
You can configure the operator to support inheriting labels and annotations that are defined in a cluster's metadata. The goal is to improve the organization of the CloudNativePG deployment in your Kubernetes infrastructure.

- Self-contained instance manager
Instead of relying on an external tool to coordinate PostgreSQL instances in the Kubernetes cluster pods, such as Patroni or Stolon, the operator injects the operator executable inside each pod, in a file named /controller/manager. The application is used to control the underlying PostgreSQL instance and to reconcile the pod status with the instance based on the PostgreSQL cluster topology. The instance manager also starts a web server that's invoked by the kubelet for probes. Unix signals invoked by the kubelet are filtered by the instance manager. Where appropriate, they're forwarded to the postgres process for fast and controlled reactions to external events. The instance manager is written in Go and has no external dependencies.

- Storage configuration
Storage is a critical component in a database workload. Taking advantage of the Kubernetes native capabilities and resources in terms of storage, the operator gives you enough flexibility to choose the right storage for your workload requirements, based on what the underlying Kubernetes environment can offer. This implies choosing a particular storage class in a public cloud environment or fine-tuning the generated PVC through a PVC template in the CR's storage parameter.

For better performance and finer control, you can also choose to host your cluster's write-ahead log (WAL, also known as pg_wal) on a separate volume, preferably on different storage. The "Benchmarking" section of the documentation provides detailed instructions on benchmarking both storage and the database before production. It relies on the cnpg plugin to ensure optimal performance and reliability.

- Replica configuration
The operator detects replicas in a cluster through a single parameter, called instances. If set to 1, the cluster comprises a single primary PostgreSQL instance with no replica. If higher than 1, the operator manages instances -1 replicas, including high availability (HA) through automated failover and rolling updates through switchover operations.

CloudNativePG manages replication slots for all the replicas in the HA cluster. The implementation is inspired by the previously proposed patch for PostgreSQL, called failover slots, and also supports user defined physical replication slots on the primary.

- Service Configuration
By default, CloudNativePG creates three Kubernetes services for applications to access the cluster via the network:

One pointing to the primary for read/write operations.
One pointing to replicas for read-only queries.
A generic one pointing to any instance for read operations.
You can disable the read-only and read services via configuration. Additionally, you can leverage the service template capability to create custom service resources, including load balancers, to access PostgreSQL outside Kubernetes. This is particularly useful for DBaaS purposes.

- Database configuration
The operator is designed to manage a PostgreSQL cluster with a single database. The operator transparently manages access to the database through three Kubernetes services provisioned and managed for read-write, read, and read-only workloads. Using the convention-over-configuration approach, the operator creates a database called app, by default owned by a regular Postgres user with the same name. You can specify both the database name and the user name, if required.

Although no configuration is required to run the cluster, you can customize both PostgreSQL runtime configuration and PostgreSQL host-based authentication rules in the postgresql section of the CR.

Configuration of Postgres roles, users, and groups
CloudNativePG supports management of PostgreSQL roles, users, and groups through declarative configuration using the .spec.managed.roles stanza.

- Pod security policies
For InfoSec requirements, the operator doesn't require privileged mode for any container. It enforces a read-only root filesystem to guarantee containers immutability for both the operator and the operand pods. It also explicitly sets the required security contexts.

- Affinity
The cluster's affinity section enables fine-tuning of how pods and related resources, such as persistent volumes, are scheduled across the nodes of a Kubernetes cluster. In particular, the operator supports:

Pod affinity and anti-affinity
Node selector
Taints and tolerations
Topology spread constraints
The cluster's topologySpreadConstraints section enables additional control of scheduling pods across topologies, enhancing what affinity and anti-affinity can offer.

- Command-line interface
CloudNativePG doesn't have its own command-line interface. It relies on the best command-line interface for Kubernetes, kubectl, by providing a plugin called cnpg. This plugin enhances and simplifies your PostgreSQL cluster management experience.

- Current status of the cluster
The operator continuously updates the status section of the CR with the observed status of the cluster. The entire PostgreSQL cluster status is continuously monitored by the instance manager running in each pod. The instance manager is responsible for applying the required changes to the controlled PostgreSQL instance to converge to the required status of the cluster. (For example, if the cluster status reports that pod -1 is the primary, pod -1 needs to promote itself while the other pods need to follow pod -1.) The same status is used by the cnpg plugin for kubectl to provide details.

- Operator's certification authority
The operator creates a certification authority for itself. It creates and signs with the operator certification authority a leaf certificate for the webhook server to use. This certificate ensures safe communication between the Kubernetes API server and the operator.

- Cluster's certification authority
The operator creates a certification authority for every PostgreSQL cluster. This certification authority is used to issue and renew TLS certificates for clients' authentication, including streaming replication standby servers (instead of passwords). Support for a custom certification authority for client certificates is available through secrets, which also includes integration with cert-manager. Certificates can be issued with the cnpg plugin for kubectl.

- TLS connections
The operator transparently and natively supports TLS/SSL connections to encrypt client/server communications for increased security using the cluster's certification authority. Support for custom server certificates is available through secrets, which also includes integration with cert-manager.

- Certificate authentication for streaming replication
To authorize streaming replication connections from the standby servers, the operator relies on TLS client certificate authentication. This method is used instead of relying on a password (and therefore a secret).

- Continuous configuration management
The operator enables you to apply changes to the Cluster resource YAML section of the PostgreSQL configuration. Depending on the configuration option, it also makes sure that all instances are properly reloaded or restarted.