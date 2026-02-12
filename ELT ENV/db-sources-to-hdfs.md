# HDFS Setup: Implications & Best Practices (Localhost: NameNode, DataNode, and NiFi on same host)

## Overview of Setup Implications
With HDFS NameNode, DataNode, and NiFi on the same localhost host, you have a pseudo-distributed setup that simplifies management by eliminating network dependencies but requires careful resource allocation since all components share CPU, memory, and disk. NiFi acts as the ingestion layer, pulling data from DBs and pushing to HDFS. Key implications:

- **Resource Allocation**: NameNode needs memory for metadata management; DataNode for storage and I/O; NiFi for data processing and transformation. Monitor VM/host resources closely to prevent out-of-memory errors or disk space exhaustion. Allocate sufficient RAM (e.g., 8-16GB total) and ensure fast storage (SSD recommended).
- **No Network Latency or Bandwidth Issues**: Since everything runs on localhost, data flows internally without network bottlenecks. This makes the setup ideal for development and testing.
- **Single Points of Failure**: With 1 NameNode and 1 DataNode on the same host, a host failure affects everything. However, restarts are straightforward. For production, consider full HA setup.
- **Security**: On localhost, security is less critical for dev/test, but still enable basic protections. Use firewalls to block external access to HDFS ports if needed.
- **HDFS Home**: Located at `C:\Tools\hadoop-3.4.2`. Configuration files are in `C:\Tools\hadoop-3.4.2\etc\hadoop\`.

## HDFS Best Practices
1. **Configuration**:
   - **core-site.xml** (located at `C:\Tools\hadoop-3.4.2\etc\hadoop\core-site.xml`): Set `fs.defaultFS` to `hdfs://localhost:9000`.
   - **hdfs-site.xml** (located at `C:\Tools\hadoop-3.4.2\etc\hadoop\hdfs-site.xml`): Set `dfs.replication=1` (since 1 DataNode). Set `dfs.namenode.name.dir` to `file:///C:/Tools/hadoop-3.4.2/data/namenode` and `dfs.datanode.data.dir` to `file:///C:/Tools/hadoop-3.4.2/data/datanode`.
   - **hdfs-site.xml on NiFi host**: Assuming NiFi is installed at `C:\Tools\nifi`, copy config files to `C:\Tools\nifi\conf\hadoop\`.

2. **Ports & Networking**:
   - **Localhost**: Open 9000 (RPC), 9870 (web UI), 9868 (secondary NameNode if used) on localhost. No external networking needed since all on same host.
   - **NiFi**: If NiFi is on same host, no additional ports needed for HDFS. Open NiFi's 8080/8443 for UI access.
   - **Firewall Rules**: Allow local connections. Block external access to HDFS ports.

3. **Monitoring & Maintenance**:
   - Use HDFS web UI (`http://localhost:9870`) to monitor health.
   - Enable NameNode logging; check DataNode logs for block reports.
   - Backup NameNode metadata (`C:\Tools\hadoop-3.4.2\data\namenode`) regularly.
   - Run `hdfs dfsadmin -report` to check cluster status.

4. **Performance Tuning**:
   - Increase `dfs.blocksize` (default 128MB) for larger files.
   - Tune JVM heap for NameNode/DataNode (e.g., -Xmx4g in hadoop-env.cmd).
   - Use SSDs for DataNode storage (`C:\Tools\hadoop-3.4.2\data\datanode`) to improve I/O.

5. **Scalability**: This is a localhost setup for dev/test. For production, scale to multi-node cluster with HA.

## NiFi-Specific Implications & Ports
NiFi runs on the same localhost host as HDFS, so all connections are local.

- **Processor Connections (within groups)**: Queues between processors (e.g., ExecuteSQL → SplitRecord) are in-memory or local disk. No port config needed; just connect via NiFi UI.
- **Input/Output Ports (between groups)**: If you have multiple Process Groups (e.g., MSSQL_Extraction, Postgres_Extraction), connect them via Output Port (from source group) → Input Port (to target group). These are logical ports in NiFi; data flows locally on the host.
- **HDFS Integration**:
  - PutHDFS processor uses HDFSClient service, which connects to localhost:9000.
  - Best Practice: Test HDFS connectivity: `hdfs dfs -ls /` (after configuring client).

- **Other Processor Implications**:
  - ExecuteSQL: Connect to DBs (ensure DB ports open, e.g., MSSQL 1433). If DBs are on same host or accessible.

## Other Considerations
- **Data Flow Path**: DB → NiFi VM → NameNode VM → DataNode VM. Monitor network saturation.
- **Error Handling**: Add RetryFlowFile for transient HDFS issues (e.g., NameNode down).
- **Testing**: Start small; use `hdfs dfs -put` from NiFi VM to verify writes.
- **Costs**: 3 VMs increase infra costs; consider consolidating if not HA-critical.
- **Alternatives**: For quick tests, run all on 1 VM with pseudo-distributed HDFS.

## Suitability for Large Data (~1TB)
Yes, this setup can handle ~1TB of data with proper tuning, but it's not ideal for production due to lack of HA and limited scalability. HDFS is designed for large-scale data, but:

- **Pros**: Simple, cost-effective for dev/test. With SSDs and tuned block sizes (e.g., 256MB), it can ingest/process 1TB efficiently via NiFi.
- **Cons**: No fault tolerance (replication=1); host failure risks data loss. No network bottlenecks since all on localhost.
- **Recommendations**: For 1TB, use for ETL testing. For production, add HA (2+ NameNodes, 3+ DataNodes) and consider cloud storage (e.g., S3) for better durability/scalability.
- **Alternatives**: If HA isn't needed immediately, this works; otherwise, scale to multi-node cluster.
   - Hadoop Configuration Resources: `C:\Tools\nifi\conf\hadoop\core-site.xml`, `C:\Tools\nifi\conf\hadoop\hdfs-site.xml`

### Processors (Same for each Process Group)

#### 1) GenerateFlowFile
- **Run Schedule**: `0 0 * * * ?` (daily at midnight, adjust as needed)
- **Custom Text**: Empty (triggers the flow)

#### 2) ExecuteSQL (Get Table List)
- **Database Connection Pooling Service**: Source DBCPConnectionPool
- **SQL select query**:
  - MSSQL: `SELECT TABLE_NAME FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_SCHEMA = 'dbo' AND TABLE_TYPE = 'BASE TABLE';`
  - PostgreSQL: `SELECT tablename FROM pg_tables WHERE schemaname = 'public';`
  - Oracle: `SELECT table_name FROM all_tables WHERE owner = 'YOUR_SCHEMA';`
- **Fetch Size**: 1000
- **Output Format**: CSV

#### 3) SplitRecord
- **Record Reader**: CSVReader
- **Record Writer**: AvroRecordSetWriter
- **Records Per Split**: 1 (one flowfile per table)

#### 4) UpdateAttribute
- Add attributes:
  - `table_name` = `${TABLE_NAME}`
  - `source_system` = `mssql` (or `postgres`, `oracle` depending on group)

#### 5) ExecuteSQL (Extract Data)
- **Database Connection Pooling Service**: Source DBCPConnectionPool
- **SQL select query**:
  ```sql
  SELECT * FROM ${table_name} WHERE LastModified >= '${yesterday:format('yyyy-MM-dd')}' ORDER BY ID;
  ```
  (Adjust table reference: `dbo.${table_name}` for MSSQL, `${table_name}` for PostgreSQL/Oracle. If no LastModified, remove WHERE clause)
- **Fetch Size**: 1000
- **Output Format**: Avro

#### 6) ConvertRecord
- **Record Reader**: AvroReader
- **Record Writer**: AvroRecordSetWriter (or ParquetRecordSetWriter for Parquet output)
- (Optional: Transform data if needed)

#### 7) UpdateAttribute (Add Metadata)
- Add attributes:
  - `extract_ts`: `${now():format('yyyy-MM-dd HH:mm:ss')}`
  - `partition_date`: `${now():format('yyyy-MM-dd')}`

#### 8) PutHDFS
- **Hadoop Configuration Resources**: Use HDFSClient (points to NameNode for metadata; data is written to DataNodes)
- **Directory**: `/bronze/${source_system}/${table_name}/dt=${partition_date}/`
- **Conflict Resolution**: replace

## Setup Steps

1. **Configure HDFS Directories**:
   Ensure HDFS has the bronze directory structure:
   ```bash
   hdfs dfs -mkdir -p /bronze/mssql /bronze/postgres /bronze/oracle
   ```

2. **Create Process Groups**:
   - Create a Process Group for each source DB (MSSQL_Extraction, etc.).
   - Inside each, add the processors as listed above.
   - Configure DBCPConnectionPool for each source DB.
   - Adjust the table list query in ExecuteSQL (Get Table List) per DB type.

3. **Configure Controller Services**:
   - Enable DBCPConnectionPool, AvroRecordSetWriter, AvroReader, CSVReader, and HDFSClient.
   - Ensure HDFSClient points to correct config files.

4. **Connect and Configure Processors**:
   - Connect processors in sequence.
   - Set properties as specified for each processor.
   - For UpdateAttribute (step 4), set source_system appropriately per group.

5. **Enable Services and Start Processors**:
   - Enable all Controller Services.
   - Start all processors in each group.

6. **Test the Flow**:
   - Run GenerateFlowFile manually in one group.
   - Check HDFS for output files: `/bronze/{source_system}/{table_name}/dt={date}/`
   - Verify data integrity and schema.

## Notes
- This setup dynamically extracts all tables from each configured DB source to HDFS.
- Output is in Avro format by default; switch to ParquetRecordSetWriter for Parquet.
- Partitioning by date allows for incremental loads and time-based queries.
- For selective tables, modify the table list query (e.g., add `AND TABLE_NAME IN ('table1', 'table2')`).
- Add error handling (e.g., RetryFlowFile) and monitoring for production.
- Ensure NiFi has access to HDFS and source DBs.
- This is the "Bronze" layer; proceed to Iceberg tables (see 03_iceberg_tables.md) and Spark transforms (see spark/04_spark_transform.py) for further processing.

## Quick Start for Localhost Pseudo-Distributed Setup
Since NameNode and DataNode are on the same localhost host, follow these steps to get HDFS running:

1. **Install Hadoop**:
   - Hadoop is installed at `C:\Tools\hadoop-3.4.2`. Ensure JAVA_HOME and HADOOP_HOME are set in environment variables.

2. **Format NameNode**:
   - Run: `hdfs namenode -format`

3. **Start HDFS Services**:
   - Start NameNode: `hdfs --daemon start namenode`
   - Start DataNode: `hdfs --daemon start datanode`
   - Verify: `jps` (should show NameNode and DataNode)

4. **Test Cluster**:
   - Run: `hdfs dfs -mkdir /test && hdfs dfs -ls /`
   - Check web UI: `http://localhost:9870`

5. **Configure NiFi**:
   - Assuming NiFi installed at `C:\Tools\nifi`, copy `core-site.xml` and `hdfs-site.xml` from `C:\Tools\hadoop-3.4.2\etc\hadoop\` to `C:\Tools\nifi\conf\hadoop\`
   - Ensure `dfs.replication=1` in `hdfs-site.xml`
   - Enable HDFSClient in NiFi and test PutHDFS.

This matches the localhost setup. Once running, proceed to NiFi flow setup. Let me know if you hit issues!