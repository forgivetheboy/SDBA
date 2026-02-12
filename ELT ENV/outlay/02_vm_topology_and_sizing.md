# VM Topology & Sizing (Ubuntu 22.04 LTS Server GUI)

## Recommended VM Layout

### Option A — **Scale-Friendly (Recommended)**
| VM    | Services                              | Why separate?                                         |
--------------------------------------------------------------------------------------------------
| VM-01 | **NiFi**                              | IO + heap-heavy; isolates ingestion spikes |
| VM-02 | **HDFS NameNode**                     | Metadata service; needs stability |
| VM-03..N | **HDFS DataNode(s)**               | Storage-heavy; scale horizontally |
| VM-04 | **Spark Master + History Server**     | Control plane |
| VM-05..N | **Spark Workers**                  | Compute-heavy; scale horizontally |
| VM-06 | **PostgreSQL Staging + dbt**          | ELT + modeling |
| VM-07 | **Metabase**                          | BI workload |

### Option B — **Test (Single Host)**
| VM          | Services                                                                              |
| VM-01       | NiFi + HDFS NameNode + 1 DataNode + Spark Master/Worker + PostgreSQL + dbt + Metabase |

> For production, choose Option A.

## Minimum Sizing (Production Baseline)

### NiFi VM
- **CPU**: 8 vCPU
- **RAM**: 16–32 GB
- **Disk**: 200 GB OS + 200 GB repo (content/flowfile/provenance)

### HDFS NameNode
- **CPU**: 4 vCPU
- **RAM**: 16 GB
- **Disk**: 200 GB OS + 100 GB metadata

### HDFS DataNode (each)
- **CPU**: 8 vCPU
- **RAM**: 32–64 GB
- **Disk**: 2–10 TB data volume (x N)

### Spark Master + History
- **CPU**: 4 vCPU
- **RAM**: 8–16 GB
- **Disk**: 100 GB

### Spark Worker (each)
- **CPU**: 16 vCPU
- **RAM**: 64–128 GB
- **Disk**: 500 GB scratch

### PostgreSQL Staging + dbt
- **CPU**: 8 vCPU
- **RAM**: 16–32 GB
- **Disk**: 500 GB

### Metabase
- **CPU**: 4 vCPU
- **RAM**: 8–16 GB
- **Disk**: 100 GB

## Network
- **Private subnet** for data plane
- **Public subnet** only for Metabase (if needed)
- Open ports: 8080 (NiFi), 9870/9864 (HDFS), 7077/8080/18080 (Spark), 5432 (Postgres), 3000 (Metabase)
