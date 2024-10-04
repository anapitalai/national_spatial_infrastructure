- high availability
- Scaling
  - horizontal
    - scale up
    - scale down
  - vertical

- self healing
- robustness
- replicas
- failover
- recovery
- redundancy

- deployments
- statefulsets


```mermaid
graph TD
    A[client] --> B{HTML}
    B -- Yes --> C[Continue]
    B -- No --> D[Fix it]
    D --> B
    C --> E[End]
