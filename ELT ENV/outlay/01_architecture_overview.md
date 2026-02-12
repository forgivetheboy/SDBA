# Architecture Overview

## End-to-End Flow

```mermaid
flowchart LR
    A[MSSQL] -->|JDBC| N[NiFi]
    B[PostgreSQL] -->|JDBC| N
    C[Oracle] -->|JDBC| N
    N -->|Avro/Parquet| H[HDFS Raw/Bronze]
    H --> I[Iceberg Tables (Silver)]
    I --> S[Spark Transformations (Gold)]
    S --> P[(PostgreSQL Staging/Serving)]
    P --> D[dbt Models]
    D --> M[Metabase BI]

    subgraph HDFS_Cluster
      H
    end

    subgraph Lakehouse
      I
      S
    end
```

## Layers
- **Bronze**: Raw ingested data in HDFS (Parquet/Avro).
- **Silver**: Iceberg tables for ACID + schema evolution.
- **Gold**: Curated data via Spark + dbt, served in PostgreSQL.

## Key Services
- **NiFi**: ingestion + routing + lightweight transformations
- **HDFS**: raw storage + cluster foundation
- **Iceberg**: ACID table layer on HDFS
- **Spark**: distributed transformations
- **PostgreSQL**: staging/serving and dbt target
- **dbt**: transformations, testing, documentation
- **Metabase**: dashboards and analytics
