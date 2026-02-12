# 01 — NiFi Extraction → HDFS (Bronze)

## Process Group Layout
```
Root Canvas
├─ [Process Group] MSSQL_Extraction
├─ [Process Group] Postgres_Extraction
└─ [Process Group] Oracle_Extraction

Each Process Group:
GenerateFlowFile → ExecuteSQL → ConvertRecord → UpdateAttribute → PutHDFS
```

## Controller Services (per group)
- **DBCPConnectionPool** (JDBC)
- **AvroRecordSetWriter** or **ParquetRecordSetWriter**
- **AvroReader** (if needed)

## Core Processors
### 1) GenerateFlowFile
- **Run Schedule**: cron or timer
- **Batch Size**: 1

### 2) ExecuteSQL
- Uses `DBCPConnectionPool`
- Query example:
  ```sql
  SELECT *
  FROM dbo.TableName
  WHERE LastModified >= ?
  ORDER BY ID;
  ```
- **Fetch Size**: 1000–10000

### 3) ConvertRecord
- Record Reader: AvroReader
- Record Writer: ParquetRecordSetWriter
- Output: Parquet for downstream Iceberg

### 4) UpdateAttribute
- Add metadata:
  - `source_system`: mssql|postgres|oracle
  - `extract_ts`: ${now():format('yyyy-MM-dd HH:mm:ss')}
  - `table_name`
  - `partition_date`: ${now():format('yyyy-MM-dd')}

### 5) PutHDFS
- **Directory**: `/bronze/${source_system}/${table_name}/dt=${partition_date}/`
- **Conflict Resolution**: replace

## Tips
- Use **Enable/Disable** per group for safe operation
- Configure **back pressure** on queues
- Use **PutHDFS** with smaller FlowFiles for throughput
- Use **ExecuteSQLRecord** if you want record-based handling
- Add **RetryFlowFile** with penalization for transient failures

## Required JARs (NiFi /opt/nifi/lib)
- `mssql-jdbc-12.6.0.jre11.jar`
- `postgresql-42.7.1.jar`
- `ojdbc11-23.x.jar`
- `orai18n-23.x.jar`

## Required NARs
- `nifi-hadoop-nar`
- `nifi-record-serialization-services-nar`
