# NiFi ELT Pipeline Setup: Multi-DB Extract to Remote HDFS

This guide walks you through setting up a modular NiFi pipeline to extract data from multiple RDBMS sources and ingest into HDFS on a remote VM. Each step includes key configuration details for each processor group.

**Architecture:** ELT (Extract → Load → Transform)
- Extract raw data from RDBMS sources
- Load data directly to HDFS (no transformation in NiFi)
- Transform data later in destination system (Spark, Hive, Presto, etc.)

**Key Difference from ETL:** Transformations happen in destination system, not in NiFi pipeline.

---

## ELT vs ETL: Architecture Comparison

### **ELT (Extract → Load → Transform) - Your Choice**
**When to Use:**
- Big data destinations (Hadoop, Spark, Snowflake)
- Complex transformations requiring distributed processing
- Raw data analytics and exploration
- Cost-effective use of existing big data tools

**Advantages:**
- ✅ **Faster Loading:** No transformation overhead in ingestion layer
- ✅ **Raw Data Preservation:** Original data structure maintained
- ✅ **Scalable Transformations:** Leverage destination system power
- ✅ **Flexible Processing:** Transform data multiple ways for different use cases
- ✅ **Cost Effective:** Use existing Spark/Hive/Presto infrastructure

**NiFi Pipeline:** ExecuteSQL → UpdateAttribute → PutHDFS

### **ETL (Extract → Transform → Load)**
**When to Use:**
- Data warehouse destinations (traditional RDBMS)
- Simple transformations (filtering, basic cleansing)
- Real-time data processing requirements
- Limited destination processing capabilities

**Advantages:**
- ✅ **Quality Data Loading:** Clean data before storage
- ✅ **Consistent Schema:** Transform to target schema during load
- ✅ **Reduced Storage:** Store only needed data
- ✅ **Immediate Usability:** Data ready for consumption

**NiFi Pipeline:** ExecuteSQL → ConvertRecord → PutHDFS

### **Choosing ELT for Your Use Case:**
- **HDFS/Spark Environment:** Perfect for ELT
- **Data Lake Architecture:** ELT enables schema-on-read
- **Multiple Consumers:** Different teams transform data differently
- **Complex Analytics:** Heavy transformations in Spark/Hive

---

## 1. Controller Services Setup

### a. DBCPConnectionPool (per RDBMS)

#### MSSQL DBCPConnectionPool Configuration:
- **Service Name:** `MSSQL_DBCP_Connection_Pool`
- **Database Connection URL:** `jdbc:sqlserver://locahost:1433;databaseName=Education;encrypt=true;trustServerCertificate=true`
  - Example: `jdbc:sqlserver://192.168.1.100:1433;databaseName=myapp;encrypt=true;trustServerCertificate=true`
- **Database Driver Class Name:** `com.microsoft.sqlserver.jdbc.SQLServerDriver`
- **Database Driver Location(s):** `C:\Tools\nifi-2.7.2\lib\mssql-jdbc.jar`
- **Database User:** `<username>`
- **Password:** `<password>`
- **Max Total Connections:** `10`
- **Max Idle Connections:** `5`
- **Max Connection Lifetime:** `30 minutes`
- **Validation Query:** `SELECT 1`

#### PostgreSQL DBCPConnectionPool Configuration:
- **Service Name:** `PostgreSQL_DBCP_Connection_Pool`
- **Database Connection URL:** `jdbc:postgresql://<host>:<port>/<database>?ssl=true&sslmode=require`
  - Example: `jdbc:postgresql://192.168.1.101:5432/myapp?ssl=true&sslmode=require`
- **Database Driver Class Name:** `org.postgresql.Driver`
- **Database Driver Location(s):** `C:\Tools\nifi-2.7.2\lib\postgresql-42.7.3.jar`
- **Database User:** `<username>`
- **Password:** `<password>`
- **Max Total Connections:** `10`
- **Max Idle Connections:** `5`
- **Max Connection Lifetime:** `30 minutes`
- **Validation Query:** `SELECT 1`

#### Oracle DBCPConnectionPool Configuration:
- **Service Name:** `Oracle_DBCP_Connection_Pool`
- **Database Connection URL:** `jdbc:oracle:thin:@<host>:<port>:<SID>`
  - Example: `jdbc:oracle:thin:@192.168.1.102:1521:ORCL`
  - For Oracle Service Name: `jdbc:oracle:thin:@//<host>:<port>/<service_name>`
- **Database Driver Class Name:** `oracle.jdbc.driver.OracleDriver`
- **Database Driver Location(s):** `C:\Tools\nifi-2.7.2\lib\ojdbc11.jar`
- **Database User:** `<username>`
- **Password:** `<password>`
- **Max Total Connections:** `10`
- **Max Idle Connections:** `5`
- **Max Connection Lifetime:** `30 minutes`
- **Validation Query:** `SELECT 1 FROM DUAL`

**Note:** Enable each DBCP service after configuration.

### b. Record Reader/Writer Services

**⚠️ IMPORTANT:** Record Readers and Writers are **NOT** controller services in NiFi. They are configured **directly on processors** (like ConvertRecord, ExecuteSQL) that need them. Do **NOT** create controller services for these.

#### Record Readers (configured on ExecuteSQL/ConvertRecord processors):
- **AvroReader:**
  - **Schema Access Strategy:** `Use 'Schema Text' Property`
  - **Schema Text:** Define your Avro schema or use `Schema Registry`
  - **Example Schema:**
    ```json
    {
      "type": "record",
      "name": "DataRecord",
      "fields": [
        {"name": "id", "type": "int"},
        {"name": "name", "type": "string"},
        {"name": "created_at", "type": "string"}
      ]
    }
    ```

- **JsonTreeReader:**
  - **Schema Access Strategy:** `Use 'Schema Text' Property`
  - **Schema Text:** JSON schema definition

#### Record Writers (configured on ConvertRecord processors):
- **AvroRecordSetWriter:**
  - **Schema Write Strategy:** `Set 'schema.name' and 'schema.version' attributes`
  - **Schema Access Strategy:** `Use 'Schema Text' Property`
  - **Compression Format:** `SNAPPY` or `DEFLATE`
  - **Schema Text:** Same as reader schema

- **ParquetRecordSetWriter:**
  - **Schema Access Strategy:** `Use 'Schema Text' Property`
  - **Compression Type:** `SNAPPY`
  - **Row Group Size:** `128 MB`
  - **Page Size:** `1 MB`
  - **Dictionary Page Size:** `1 MB`

- **CSVRecordSetWriter:**
  - **Schema Access Strategy:** `Use 'Schema Text' Property`
  - **Include Header Line:** `true`
  - **Delimiter:** `,`
  - **Quote Character:** `"`
  - **Escape Character:** `\`
  - **Charset:** `UTF-8`

### c. Hadoop Configuration (PutHDFS)
**Important Note:** In NiFi 2.7.2, the HadoopConfigurationResources controller service may not be available. Instead, configure HDFS settings directly on the PutHDFS processor.

**Alternative: Configure HDFS directly on PutHDFS processor (Recommended for NiFi 2.7.2):**
- **Hadoop Configuration Resources:** 
  - `C:\Tools\core-site.xml` (copied for convenience)
  - `C:\Tools\hdfs-site.xml` (copied for convenience)
  - **OR** `C:\Tools\hadoop-3.4.2\etc\hadoop\core-site.xml` (original location)
  - **OR** `C:\Tools\hadoop-3.4.2\etc\hadoop\hdfs-site.xml` (original location)
- **Kerberos Configuration File:** (if using Kerberos)
  - `C:\Tools\hadoop-3.4.2\etc\hadoop\krb5.conf`
- **Kerberos Principal:** `<principal>@<REALM>` (if secured)
- **Kerberos Keytab:** `C:\Tools\hadoop-3.4.2\etc\hadoop\nifi.keytab` (if secured)
- **Additional Properties:**
  - `fs.hdfs.impl=org.apache.hadoop.hdfs.DistributedFileSystem`
  - `fs.file.impl=org.apache.hadoop.fs.LocalFileSystem`

**Legacy Controller Service Approach (if available):**
- **Service Name:** `HadoopConfigurationResources`
- **Type:** `org.apache.nifi.processors.hadoop.util.HadoopConfigurationResources`
- **Configuration Resources:** Same paths as above
- **Kerberos Configuration File:** Same as above
- **Kerberos Principal:** Same as above
- **Kerberos Keytab:** Same as above
- **Additional Properties:** Same as above

**Note:** If "HadoopConfigurationResources" doesn't appear in controller services:
1. HDFS NARs are loaded (verified - nifi-hadoop-nar-2.7.2.nar and nifi-hadoop-libraries-nar-2.7.2.nar loaded successfully)
2. Use the direct processor configuration approach instead (recommended)
3. The controller service may not be available in this NiFi version

### Troubleshooting HDFS Integration

**Issue: HadoopConfigurationResources controller service not available**
- **Root Cause:** In NiFi 2.7.2, this controller service may not be included or may be deprecated
- **Solution:** Configure HDFS settings directly on the PutHDFS processor (see section c. above)
- **Verification:** Check nifi-app.log for successful NAR loading:
  ```
  INFO [main] o.a.nifi.nar.NarClassLoaders Loaded NAR: nifi-hadoop-nar-2.7.2.nar
  INFO [main] o.a.nifi.nar.NarClassLoaders Loaded NAR: nifi-hadoop-libraries-nar-2.7.2.nar
  ```

**Issue: HDFS connection fails**
- **Check:** Hadoop configuration files exist at:
  - `C:\Tools\core-site.xml` and `C:\Tools\hdfs-site.xml` (convenient copies)
  - **OR** `C:\Tools\hadoop-3.4.2\etc\hadoop\core-site.xml` and `C:\Tools\hadoop-3.4.2\etc\hadoop\hdfs-site.xml` (original location)
- **Check:** Network connectivity to HDFS Namenode (localhost:9000)
- **Check:** Kerberos authentication if HDFS is secured
- **Test:** Use Hadoop CLI tools to verify connectivity before configuring NiFi
- **Access Data:** View uploaded files via HDFS Web UI at `http://localhost:9870/explorer.html#/data/your_source/`

### Accessing HDFS Data via Web UI

**HDFS Web Interface URL:** `http://localhost:9870`

**To view data uploaded to `/data/your_source/`:**
1. Open browser and navigate to: `http://localhost:9870/explorer.html`
2. Navigate to the `/data/your_source/` directory in the file browser
3. Click on files to view content or download
4. Use the "Browse Directory" feature to explore subdirectories

**Alternative URLs:**
- **File Browser:** `http://localhost:9870/explorer.html#/data/your_source/`
- **DataNode Information:** `http://localhost:9870/dfshealth.html`
- **NameNode Logs:** `http://localhost:9870/logs/`

**Note:** The HDFS web UI runs on port 9870 (configured in `dfs.namenode.http-address` in hdfs-site.xml)

---

## 2. Extract Processor Group (per source)

### a. ExecuteSQL - Detailed Configuration

**Required Properties:**
- **Database Connection Pooling Service:** Select your DBCP service (e.g., `MSSQL_DBCP`, `PostgreSQL_DBCP`, `Oracle_DBCP`)
- **SQL select query:** Your extraction SQL query with parameters
- **Max Wait Time:** `30 sec` (how long to wait for connection)
- **Query Timeout:** `0 sec` (0 = no timeout, or set to 300 for 5 minutes)

**Output Configuration:**
- **Output Format:** `Avro` (recommended for schema preservation)
- **Normalize Table/Column Names:** `false` (keep original case)
- **Use Avro Logical Types:** `true` (preserve date/timestamp types)
- **Default Decimal Precision:** `10`
- **Default Decimal Scale:** `2`

**Record Writer Configuration (Configure directly on processor):**
- **Record Writer:** `AvroRecordSetWriter`
- **Schema Access Strategy:** `Use 'Schema Text' Property`
- **Schema Text:** Define your Avro schema or use `Inherit Record Schema`
- **Compression Format:** `SNAPPY` (good compression/speed balance)
- **Cache Size:** `1000` (number of schemas to cache)

**Scheduling & Execution:**
- **Run Schedule:** `0 sec` (trigger-based) or cron expression like `0 */5 * * * *` (every 5 min)
- **Execution Strategy:** `ONE_ROW_PER_FLOWFILE` (default - each row becomes a FlowFile)
- **Maximum Number of Fragments:** `0` (unlimited)
- **Fetch Size:** `1000` (rows per batch)

**Error Handling:**
- **Max Rows Per Flow File:** `10000` (split large result sets)
- **Output Batch Size:** `1` (how many FlowFiles to create per execution)
- **Auto-Terminate Relationships:**
  - `success` → `false` (route to next processor)
  - `failure` → `true` (terminate on failure)

**Advanced Settings:**
- **Additional WHERE clause:** (optional additional filtering)
- **SQL Pre-Query:** (optional setup query)
- **SQL Post-Query:** (optional cleanup query)

#### Handling Multiple Tables - Three Approaches:

##### **Approach 1: Multiple ExecuteSQL Processors (Recommended for Production)**
- Create one ExecuteSQL processor per table
- Each processor handles one table's data extraction
- Benefits: Isolated error handling, different schedules per table, easier monitoring
- Example queries:
  - MSSQL/PostgreSQL: `SELECT * FROM users WHERE last_modified > ?`
  - Oracle: `SELECT * FROM users WHERE last_modified > ?`

##### **Approach 2: Dynamic Table Selection with Parameters**
- Use a single ExecuteSQL with dynamic table names
- Feed table names via GenerateFlowFile or QueryDatabaseTable
- SQL: `SELECT * FROM ${table_name} WHERE last_modified > ?`
- Useful for metadata-driven ETL

##### **Approach 3: Union All Multiple Tables**
- Single ExecuteSQL with UNION ALL for similar tables
- SQL Example:
  ```sql
  SELECT 'users' as table_name, * FROM users WHERE last_modified > ?
  UNION ALL
  SELECT 'orders' as table_name, * FROM orders WHERE created_at > ?
  UNION ALL
  SELECT 'products' as table_name, * FROM products WHERE updated_at > ?
  ```
- Best for tables with identical schemas

##### **Approach 4: Metadata-Driven Extraction**
- Use QueryDatabaseTable to get table list
- Route to multiple ExecuteSQL processors dynamically
- Most flexible for changing table structures

#### **Incremental Loading Strategies:**
- **Timestamp-based:** `WHERE last_modified > ?` (requires timestamp columns)
- **ID-based:** `WHERE id > ?` (requires sequential IDs)
- **Change Data Capture:** Use database triggers/logs
- **Full refresh:** `SELECT * FROM table` (for small tables)

#### **Database-Specific Query Examples:**

**MSSQL:**
```sql
-- Incremental load with datetime
SELECT * FROM users 
WHERE last_modified > CONVERT(datetime, ?, 121)

-- With pagination
SELECT * FROM (
    SELECT *, ROW_NUMBER() OVER (ORDER BY id) as row_num 
    FROM users 
    WHERE last_modified > ?
) t WHERE row_num BETWEEN ? AND ?
```

**PostgreSQL:**
```sql
-- Incremental load with timestamp
SELECT * FROM users 
WHERE last_modified > $1::timestamp

-- With LIMIT/OFFSET for batching
SELECT * FROM users 
WHERE last_modified > $1 
ORDER BY id 
LIMIT $2 OFFSET $3
```

**Oracle:**
```sql
-- Incremental load with timestamp
SELECT * FROM users 
WHERE last_modified > TO_TIMESTAMP(?, 'YYYY-MM-DD HH24:MI:SS')

-- Using ROWNUM for pagination
SELECT * FROM (
    SELECT * FROM users 
    WHERE last_modified > TO_TIMESTAMP(?, 'YYYY-MM-DD HH24:MI:SS')
    ORDER BY id
) WHERE ROWNUM <= ?
```

### b. UpdateAttribute (Optional) - Detailed Configuration

**Purpose:** Set FlowFile attributes for metadata, routing, and file naming.

**Key Properties:**
- **Delete Attributes Expression:** (leave empty - don't delete any attributes)
- **Store State:** `Do not store state` (default)
- **Stateful Variables Initial Value:** (leave empty)

**Common Attribute Rules to Add:**

1. **Table Name Attribute:**
   - **Property Name:** `table.name`
   - **Property Value:** `${sql.table.name:toLower()}` (gets table name from SQL)

2. **Database Type Attribute:**
   - **Property Name:** `db.type`
   - **Property Value:** `mssql` (or `postgresql`, `oracle`)

3. **Timestamp Attributes:**
   - **Property Name:** `extract.timestamp`
   - **Property Value:** `${now():format('yyyy-MM-dd_HH-mm-ss')}`
   - **Property Name:** `extract.date`
   - **Property Value:** `${now():format('yyyy-MM-dd')}`

4. **File Naming:**
   - **Property Name:** `filename`
   - **Property Value:** `${table.name}_${extract.timestamp}.avro`

5. **Record Count (if available):**
   - **Property Name:** `record.count`
   - **Property Value:** `${record.count}` (from ExecuteSQL)

6. **HDFS Directory Path:**
   - **Property Name:** `hdfs.directory`
   - **Property Value:** `/data/${db.type}/${table.name}/`

**Advanced Attribute Rules:**

7. **Dynamic Filename with Table:**
   - **Property Name:** `filename`
   - **Property Value:** `${sql.table.name:toLower()}_${now():format('yyyyMMdd_HHmmss')}.avro`

8. **Partitioned Directory Path:**
   - **Property Name:** `hdfs.directory`
   - **Property Value:** `/data/${db.type}/${table.name}/year=${now():format('yyyy')}/month=${now():format('MM')}/day=${now():format('dd')}/`

9. **Size-based Naming:**
   - **Property Name:** `file.size`
   - **Property Value:** `${fileSize}`
   - **Property Name:** `filename`
   - **Property Value:** `${table.name}_${extract.date}_${file.size}.avro`

**Execution Settings:**
- **Auto-Terminate Relationships:**
  - `success` → `false` (continue to next processor)
  - `failure` → `true` (terminate on failure)

**Use Cases:**
- **File Naming:** Create meaningful filenames for HDFS storage
- **Routing:** Use RouteOnAttribute for conditional processing
- **Metadata:** Track source, timestamp, and processing info
- **Monitoring:** Add attributes for provenance tracking

### c. ConvertRecord - SKIP for ELT Architecture

**ELT Note:** In ELT pipelines, we skip transformation in NiFi. Data is loaded raw to HDFS and transformed later in the destination system (Spark, Hive, etc.).

**When to Use ConvertRecord:**
- ETL pipelines (transform in NiFi)
- Schema validation/conversion needed before loading
- Format changes required (Avro → Parquet in NiFi)

**ELT Approach:** Load data as-is to HDFS, transform later in destination.

### d. Output Port - Detailed Configuration

**Purpose:** Route processed data from extraction group to HDFS group.

**Port Configuration:**
- **Name:** `to-HDFS` (descriptive name for routing)
- **Comments:** `Routes processed data to HDFS storage group`

**Connection Settings:**
- **Max Number of Threads:** `1` (single-threaded routing)
- **Use Compression:** `false` (compression handled by ConvertRecord)
- **Back Pressure Object Threshold:** `10000` (max queued FlowFiles)
- **Back Pressure Data Size Threshold:** `1 GB` (max queued data size)

**Execution Settings:**
- **Auto-Terminate Relationships:** `false` (don't terminate - route to next group)
- **Yield Duration:** `1 sec` (wait time when no work available)
- **Bulletin Level:** `WARN` (log level for issues)

**Monitoring:**
- **FlowFiles In:** Track incoming data volume
- **FlowFiles Out:** Track data successfully routed
- **Bytes In/Out:** Monitor data throughput
- **Processing Time:** Track routing performance

**Connection Properties (when connecting to Input Port):**
- **Connection Name:** `from_${source_name}_to_hdfs` (e.g., `from_mssql_to_hdfs`)
- **FlowFile Expiration:** `0 sec` (never expire)
- **Back Pressure Object Threshold:** `10000`
- **Back Pressure Data Size Threshold:** `1 GB`
- **Load Balance Strategy:** `Round Robin` (distribute load)
- **Partitioning Attribute:** (leave empty for default)

**Use Cases:**
- **Routing:** Send data to specific HDFS storage group
- **Load Balancing:** Distribute across multiple HDFS destinations
- **Monitoring:** Track data flow between processor groups
- **Error Handling:** Route failed extractions to error handling

---

### **Extraction Processor Group - Complete Configuration Summary**

**Your Exact Setup:** ExecuteSQL → UpdateAttribute → Output Port (in each extraction group) → Input Port → PutHDFS (centralized in HDFS group)

**Processor Chain:** ExecuteSQL → UpdateAttribute → Output Port (in extraction groups) → Input Port → PutHDFS (in HDFS group)

**ELT Architecture Benefits:**
- **Faster Loading:** No transformation overhead in NiFi
- **Raw Data Preservation:** Original data structure maintained
- **Flexible Transformations:** Transform in destination (Spark, Hive, Presto)
- **Scalable:** Destination systems handle heavy transformations
- **Cost Effective:** Leverage existing big data processing tools

**ExecuteSQL (Required):**
- Database Connection Pooling Service: Select your DBCP service
- SQL select query: Your extraction query with parameters
- Output Format: Avro (or your preferred format)
- Record Writer: AvroRecordSetWriter (configured on processor)
- Run Schedule: 0 sec (trigger-based) or cron expression

**Controller Services for ExecuteSQL:**
- **DBCPConnectionPool** (Required) - Database connection pooling service

**UpdateAttribute (Optional but Recommended):**
- table.name: ${sql.table.name:toLower()}
- extract.timestamp: ${now():format('yyyy-MM-dd_HH-mm-ss')}
- filename: ${table.name}_${extract.timestamp}.avro

**Controller Services for UpdateAttribute:**
- None required (processor-only configuration)

**ConvertRecord: SKIP for ELT**
- Not used in ELT - transformations happen in destination system

**Output Port (Required for Your Setup):**
- Name: to-HDFS
- Connects to: HDFS processor group's input port
- Back Pressure: 10000 FlowFiles / 1 GB

**Controller Services for Output Port:**
- None required (port-only configuration)

**PutHDFS (Centralized in HDFS Group):**
- Hadoop Configuration Resources: C:\Tools\core-site.xml, C:\Tools\hdfs-site.xml
- Directory: /data/${db.type}/${table.name}/ (dynamic path based on attributes)
- All other HDFS settings as configured

---

### **Controller Services Configuration Guide**

#### **1. DBCPConnectionPool Controller Service (Required for ExecuteSQL)**

**Service Type:** `org.apache.nifi.dbcp.DBCPConnectionPool`

**Database-Specific Configurations:**

**MSSQL Configuration:**
- **Database Connection URL:** `jdbc:sqlserver://localhost:1433;databaseName=your_db;encrypt=false;trustServerCertificate=true`
- **Database Driver Class Name:** `com.microsoft.sqlserver.jdbc.SQLServerDriver`
- **Database Driver Location(s):** `C:\Tools\mssql-jdbc.jar`
- **Database User:** `your_username`
- **Password:** `your_password`
- **Max Total Connections:** `10`
- **Max Idle Connections:** `5`
- **Max Connection Lifetime:** `30 min`
- **Validation Query:** `SELECT 1`

**PostgreSQL Configuration:**
- **Database Connection URL:** `jdbc:postgresql://localhost:5432/your_db`
- **Database Driver Class Name:** `org.postgresql.Driver`
- **Database Driver Location(s):** `C:\Tools\postgresql-42.7.3.jar`
- **Database User:** `your_username`
- **Password:** `your_password`
- **Max Total Connections:** `10`
- **Max Idle Connections:** `5`
- **Max Connection Lifetime:** `30 min`
- **Validation Query:** `SELECT 1`

**Oracle Configuration:**
- **Database Connection URL:** `jdbc:oracle:thin:@localhost:1521:your_sid`
- **Database Driver Class Name:** `oracle.jdbc.OracleDriver`
- **Database Driver Location(s):** `C:\Tools\ojdbc11.jar`
- **Database User:** `your_username`
- **Password:** `your_password`
- **Max Total Connections:** `10`
- **Max Idle Connections:** `5`
- **Max Connection Lifetime:** `30 min`
- **Validation Query:** `SELECT 1 FROM DUAL`

**Common DBCP Settings:**
- **Connection Properties:** (leave empty for defaults)
- **Minimum Idle Connections:** `0`
- **Max Wait Time:** `30 sec`
- **Time Between Eviction Runs:** `10 min`
- **Soft Min Eviction Idle Time:** `30 min`
- **Test On Borrow:** `true`
- **Test On Return:** `false`
- **Test While Idle:** `true`

#### **2. Record Readers/Writers - Processor vs Controller Service**

**Important Note:** In this ETL setup, Record Readers and Writers are configured **directly on processors** (not as controller services). This approach is:

- **Simpler** for single-purpose processors
- **More flexible** for processor-specific configurations
- **Easier to manage** in development environments
- **Recommended** for ETL pipelines

**When to Use Controller Services for Readers/Writers:**
- **Multi-processor reuse:** Same reader/writer used by multiple processors
- **Complex configurations:** Shared schemas across the flow
- **Enterprise environments:** Centralized configuration management
- **High-throughput scenarios:** Optimized resource sharing

**Current Setup (Processor-Configured):**
- ✅ **AvroReader:** Configured directly on ConvertRecord processor
- ✅ **ParquetRecordSetWriter:** Configured directly on ConvertRecord processor
- ✅ **AvroRecordSetWriter:** Configured directly on ExecuteSQL processor

#### **3. Controller Service Management**

**Starting Controller Services:**
1. Go to NiFi UI → Controller Services tab
2. Select your DBCP service
3. Click the lightning bolt (⚡) to enable
4. Wait for "Enabled" status

**Controller Service Dependencies:**
- DBCP services must be enabled before starting ExecuteSQL processors
- Service status shown in processor configuration (green = enabled)

**Troubleshooting Controller Services:**
- **Connection Failed:** Check database credentials and network connectivity
- **Driver Not Found:** Verify JDBC driver JAR paths
- **Timeout Issues:** Increase Max Wait Time and Max Connection Lifetime
- **Pool Exhausted:** Increase Max Total Connections

---

### **Controller Services by Processor - Quick Reference**

| Processor | Controller Services Required | Configuration Method |
|-----------|-----------------------------|---------------------|
| **ExecuteSQL** | ✅ DBCPConnectionPool | Select from dropdown |
| **UpdateAttribute** | ❌ None | Direct processor config |
| **ConvertRecord** | ❌ None | Direct processor config (Readers/Writers) |
| **Output Port** | ❌ None | Port configuration only |
| **PutHDFS** | ❌ None | Direct processor config (HDFS settings) |

**Note:** The `HadoopConfigurationResources` controller service is **not available** in NiFi 2.7.2. Configure HDFS settings directly on the PutHDFS processor instead.

**Key Points:**
- **Only ExecuteSQL requires a controller service** (DBCP for database connections)
- **Record Readers/Writers are configured directly on processors** (not as controller services)
- **HDFS configuration is done directly on PutHDFS processor** (no controller service needed)
- **Controller services are for shared resources** like connection pools
- **Processor configurations are for per-processor settings** like readers/writers

**Controller Service Lifecycle:**
1. **Create** controller service in Controller Services tab
2. **Configure** with database/driver settings
3. **Enable** the service (lightning bolt icon)
4. **Select** in processor dropdown
5. **Start** processors that use the service

---

### **Controller Service Management in NiFi UI**

#### **Creating a DBCP Controller Service:**

1. **Navigate to Controller Services:**
   - Click the "hamburger" menu (☰) in top-right
   - Select "Controller Services"

2. **Create New Service:**
   - Click "+" button
   - Search for "DBCPConnectionPool"
   - Select `org.apache.nifi.dbcp.DBCPConnectionPool`

3. **Configure Database Connection:**
   - **Name:** `MSSQL_DBCP` (or PostgreSQL_DBCP, Oracle_DBCP)
   - **Database Connection URL:** Your JDBC URL
   - **Database Driver Class Name:** Driver class
   - **Database Driver Location(s):** Path to JDBC JAR
   - **Database User/Password:** Credentials

4. **Configure Connection Pool:**
   - **Max Total Connections:** `10`
   - **Max Idle Connections:** `5`
   - **Validation Query:** `SELECT 1`

5. **Enable the Service:**
   - Click the lightning bolt (⚡) icon
   - Wait for status to show "Enabled"

#### **Using Controller Services in Processors:**

1. **Select the Service:**
   - In ExecuteSQL processor properties
   - Find "Database Connection Pooling Service"
   - Select your DBCP service from dropdown

2. **Service Status Indicators:**
   - **Green:** Service enabled and available
   - **Red:** Service disabled or error
   - **Yellow:** Service starting/stopping

#### **Controller Service Best Practices:**

- **Naming:** Use descriptive names (e.g., `Production_MSSQL_DBCP`)
- **Security:** Store passwords securely (not in plain text)
- **Monitoring:** Check service status regularly
- **Scaling:** Adjust connection pool sizes based on load
- **Backup:** Document service configurations

---

### **Database-Specific Extraction Configurations**

| Database | ExecuteSQL Service | UpdateAttribute db.type | HDFS Directory | JDBC Driver |
|----------|-------------------|------------------------|----------------|-------------|
| **MSSQL** | `MSSQL_DBCP` | `mssql` | `/data/mssql/${table.name}/` | `mssql-jdbc.jar` |
| **PostgreSQL** | `PostgreSQL_DBCP` | `postgresql` | `/data/postgresql/${table.name}/` | `postgresql-42.7.3.jar` |
| **Oracle** | `Oracle_DBCP` | `oracle` | `/data/oracle/${table.name}/` | `ojdbc11.jar` |

#### **1. MSSQL Extraction Group**

**ExecuteSQL Configuration:**
- **Database Connection Pooling Service:** `MSSQL_DBCP`
- **SQL select query:** `SELECT * FROM users WHERE last_modified > ?`
- **Query Parameter 1:** `${last.extraction.timestamp:orElse('1900-01-01')}`
- **Max Wait Time:** `30 sec`
- **Query Timeout:** `300 sec`
- **Output Format:** `Avro`
- **Normalize Table/Column Names:** `false`
- **Use Avro Logical Types:** `true`
- **Default Decimal Precision:** `18`
- **Default Decimal Scale:** `2`
- **Record Writer:** `AvroRecordSetWriter` (configured on processor)
- **Run Schedule:** `0 sec` (trigger-based)
- **Execution Strategy:** `ONE_ROW_PER_FLOWFILE`
- **Maximum Number of Fragments:** `0`
- **Fetch Size:** `1000`
- **Max Rows Per Flow File:** `10000`
- **Output Batch Size:** `1`

**UpdateAttribute Configuration:**
- **table.name:** `${sql.table.name:toLower()}`
- **db.type:** `mssql`
- **extract.timestamp:** `${now():format('yyyy-MM-dd_HH-mm-ss')}`
- **extract.date:** `${now():format('yyyy-MM-dd')}`
- **filename:** `${table.name}_${extract.timestamp}.avro`
- **hdfs.directory:** `/data/mssql/${table.name}/`
- **record.count:** `${record.count}`

**Output Port Configuration:**
- **Name:** `to-HDFS`
- **Comments:** `Routes MSSQL data to centralized HDFS loading`
- **Max Number of Threads:** `1`
- **Use Compression:** `false`
- **Back Pressure Object Threshold:** `10000`
- **Back Pressure Data Size Threshold:** `1 GB`

**Controller Service: MSSQL_DBCP**
- **Service Type:** `org.apache.nifi.dbcp.DBCPConnectionPool`
- **Database Connection URL:** `jdbc:sqlserver://localhost:1433;databaseName=your_db;encrypt=false;trustServerCertificate=true`
- **Database Driver Class Name:** `com.microsoft.sqlserver.jdbc.SQLServerDriver`
- **Database Driver Location(s):** `C:\Tools\mssql-jdbc.jar`
- **Database User:** `your_mssql_username`
- **Password:** `your_mssql_password`
- **Max Total Connections:** `10`
- **Max Idle Connections:** `5`
- **Max Connection Lifetime:** `30 min`
- **Validation Query:** `SELECT 1`

#### **2. PostgreSQL Extraction Group**

**ExecuteSQL Configuration:**
- **Database Connection Pooling Service:** `PostgreSQL_DBCP`
- **SQL select query:** `SELECT * FROM orders WHERE updated_at > $1`
- **Query Parameter 1:** `${last.extraction.timestamp:orElse('1900-01-01 00:00:00')}`
- **Max Wait Time:** `30 sec`
- **Query Timeout:** `300 sec`
- **Output Format:** `Avro`
- **Normalize Table/Column Names:** `false`
- **Use Avro Logical Types:** `true`
- **Default Decimal Precision:** `18`
- **Default Decimal Scale:** `2`
- **Record Writer:** `AvroRecordSetWriter` (configured on processor)
- **Run Schedule:** `0 sec` (trigger-based)
- **Execution Strategy:** `ONE_ROW_PER_FLOWFILE`
- **Maximum Number of Fragments:** `0`
- **Fetch Size:** `1000`
- **Max Rows Per Flow File:** `10000`
- **Output Batch Size:** `1`

**UpdateAttribute Configuration:**
- **table.name:** `${sql.table.name:toLower()}`
- **db.type:** `postgresql`
- **extract.timestamp:** `${now():format('yyyy-MM-dd_HH-mm-ss')}`
- **extract.date:** `${now():format('yyyy-MM-dd')}`
- **filename:** `${table.name}_${extract.timestamp}.avro`
- **hdfs.directory:** `/data/postgresql/${table.name}/`
- **record.count:** `${record.count}`

**Output Port Configuration:**
- **Name:** `to-HDFS`
- **Comments:** `Routes PostgreSQL data to centralized HDFS loading`
- **Max Number of Threads:** `1`
- **Use Compression:** `false`
- **Back Pressure Object Threshold:** `10000`
- **Back Pressure Data Size Threshold:** `1 GB`

**Controller Service: PostgreSQL_DBCP**
- **Service Type:** `org.apache.nifi.dbcp.DBCPConnectionPool`
- **Database Connection URL:** `jdbc:postgresql://localhost:5432/your_db`
- **Database Driver Class Name:** `org.postgresql.Driver`
- **Database Driver Location(s):** `C:\Tools\postgresql-42.7.3.jar`
- **Database User:** `your_postgres_username`
- **Password:** `your_postgres_password`
- **Max Total Connections:** `10`
- **Max Idle Connections:** `5`
- **Max Connection Lifetime:** `30 min`
- **Validation Query:** `SELECT 1`

#### **3. Oracle Extraction Group**

**ExecuteSQL Configuration:**
- **Database Connection Pooling Service:** `Oracle_DBCP`
- **SQL select query:** `SELECT * FROM products WHERE last_updated > TO_TIMESTAMP(?, 'YYYY-MM-DD HH24:MI:SS')`
- **Query Parameter 1:** `${last.extraction.timestamp:orElse('1900-01-01 00:00:00')}`
- **Max Wait Time:** `30 sec`
- **Query Timeout:** `300 sec`
- **Output Format:** `Avro`
- **Normalize Table/Column Names:** `false`
- **Use Avro Logical Types:** `true`
- **Default Decimal Precision:** `18`
- **Default Decimal Scale:** `2`
- **Record Writer:** `AvroRecordSetWriter` (configured on processor)
- **Run Schedule:** `0 sec` (trigger-based)
- **Execution Strategy:** `ONE_ROW_PER_FLOWFILE`
- **Maximum Number of Fragments:** `0`
- **Fetch Size:** `1000`
- **Max Rows Per Flow File:** `10000`
- **Output Batch Size:** `1`

**UpdateAttribute Configuration:**
- **table.name:** `${sql.table.name:toLower()}`
- **db.type:** `oracle`
- **extract.timestamp:** `${now():format('yyyy-MM-dd_HH-mm-ss')}`
- **extract.date:** `${now():format('yyyy-MM-dd')}`
- **filename:** `${table.name}_${extract.timestamp}.avro`
- **hdfs.directory:** `/data/oracle/${table.name}/`
- **record.count:** `${record.count}`

**Output Port Configuration:**
- **Name:** `to-HDFS`
- **Comments:** `Routes Oracle data to centralized HDFS loading`
- **Max Number of Threads:** `1`
- **Use Compression:** `false`
- **Back Pressure Object Threshold:** `10000`
- **Back Pressure Data Size Threshold:** `1 GB`

**Controller Service: Oracle_DBCP**
- **Service Type:** `org.apache.nifi.dbcp.DBCPConnectionPool`
- **Database Connection URL:** `jdbc:oracle:thin:@localhost:1521:your_sid`
- **Database Driver Class Name:** `oracle.jdbc.OracleDriver`
- **Database Driver Location(s):** `C:\Tools\ojdbc11.jar`
- **Database User:** `your_oracle_username`
- **Password:** `your_oracle_password`
- **Max Total Connections:** `10`
- **Max Idle Connections:** `5`
- **Max Connection Lifetime:** `30 min`
- **Validation Query:** `SELECT 1 FROM DUAL`

---

### **AvroRecordSetWriter Configuration (Used by All ExecuteSQL)**

**Schema Access Strategy:** `Use 'Schema Text' Property`
**Schema Text:** `${avro.schema}` (inherits schema from ExecuteSQL)
**Schema Registry:** (leave empty)
**Cache Size:** `1000`
**Compression Format:** `SNAPPY`
**Compression Level:** `6` (balanced compression/speed)

---

### **Common Settings for All Database Extractions**

**ExecuteSQL (All Databases):**
- **Max Wait Time:** `30 sec`
- **Query Timeout:** `300 sec`
- **Output Format:** `Avro`
- **Normalize Table/Column Names:** `false`
- **Use Avro Logical Types:** `true`
- **Run Schedule:** `0 sec` (trigger-based)
- **Execution Strategy:** `ONE_ROW_PER_FLOWFILE`
- **Fetch Size:** `1000`
- **Max Rows Per Flow File:** `10000`

**UpdateAttribute (All Databases):**
- **table.name:** `${sql.table.name:toLower()}`
- **extract.timestamp:** `${now():format('yyyy-MM-dd_HH-mm-ss')}`
- **extract.date:** `${now():format('yyyy-MM-dd')}`
- **filename:** `${table.name}_${extract.timestamp}.avro`
- **record.count:** `${record.count}`

**Output Port (All Databases):**
- **Name:** `to-HDFS`
- **Max Number of Threads:** `1`
- **Use Compression:** `false`
- **Back Pressure Object Threshold:** `10000`
- **Back Pressure Data Size Threshold:** `1 GB`

**Controller Services (All Databases):**
- **Max Total Connections:** `10`
- **Max Idle Connections:** `5`
- **Max Connection Lifetime:** `30 min`
- **Validation Query:** `SELECT 1` (or `SELECT 1 FROM DUAL` for Oracle)

---

### **Incremental Loading Setup**

**State Management for Incremental Extractions:**
- Use `UpdateAttribute` to store last extraction timestamp
- Create a state file or use NiFi state management
- Example: Store `${now():format('yyyy-MM-dd HH:mm:ss')}` as last extraction time

**Query Parameters for Incremental Loading:**
- **MSSQL:** `WHERE last_modified > ?` (parameter: `${last.extraction.timestamp:orElse('1900-01-01')}`)
- **PostgreSQL:** `WHERE updated_at > $1` (parameter: `${last.extraction.timestamp:orElse('1900-01-01 00:00:00')}`)
- **Oracle:** `WHERE last_updated > TO_TIMESTAMP(?, 'YYYY-MM-DD HH24:MI:SS')` (parameter: `${last.extraction.timestamp:orElse('1900-01-01 00:00:00')}`)

**State Persistence:**
- Use `UpdateAttribute` with state management properties
- Store state in NiFi's state directory or external storage
- Ensure state survives NiFi restarts

---

#### **Multi-Table Processor Group Organization (ELT Architecture):**

**Option A: Distributed PutHDFS (Each Group Has Its Own)**
```
Database_Group/
├── MSSQL_Extract_Group/
│   ├── ExecuteSQL (users table)
│   ├── UpdateAttribute (optional)
│   └── PutHDFS (direct load to /data/mssql/)
├── PostgreSQL_Extract_Group/
│   ├── ExecuteSQL (orders table)
│   ├── UpdateAttribute (optional)
│   └── PutHDFS (direct load to /data/postgres/)
└── Oracle_Extract_Group/
    ├── ExecuteSQL (products table)
    ├── UpdateAttribute (optional)
    └── PutHDFS (direct load to /data/oracle/)
```

**Option B: Centralized PutHDFS Group (Your Preference - Recommended)**
```
Database_Group/
├── MSSQL_Extract_Group/
│   ├── ExecuteSQL (users table)
│   ├── UpdateAttribute (optional)
│   └── Output Port (to-HDFS)
├── PostgreSQL_Extract_Group/
│   ├── ExecuteSQL (orders table)
│   ├── UpdateAttribute (optional)
│   └── Output Port (to-HDFS)
├── Oracle_Extract_Group/
│   ├── ExecuteSQL (products table)
│   ├── UpdateAttribute (optional)
│   └── Output Port (to-HDFS)
└── HDFS_Load_Group/
    ├── Input Port (from_extractors)
    └── PutHDFS (centralized loading)
```

**Your Choice (Option B) - ExecuteSQL → UpdateAttribute → Output Port in each extraction group, then centralized PutHDFS:**

**Benefits of Centralized PutHDFS:**
- ✅ **Single HDFS Configuration:** Manage HDFS settings in one place
- ✅ **Centralized Monitoring:** All HDFS operations in one group
- ✅ **Resource Management:** Shared HDFS connection pool
- ✅ **Easier Maintenance:** Update HDFS settings once for all sources
- ✅ **Unified Error Handling:** Single point for HDFS-related issues

**Option C: Single Group with Multiple ExecuteSQL (ELT)**
```
Database_Group/
├── ExecuteSQL_Users → UpdateAttribute → PutHDFS
├── ExecuteSQL_Orders → UpdateAttribute → PutHDFS
└── ExecuteSQL_Products → UpdateAttribute → PutHDFS
```

**Option D: Dynamic Table Processing (ELT)**
```
Database_Group/
├── QueryDatabaseTable (get table list)
├── SplitJson (split into individual table flows)
├── ExecuteSQL (dynamic table name)
├── UpdateAttribute (optional)
└── PutHDFS (direct load to HDFS)
```

**ELT Connection Pattern (Your Setup):**
- **Extraction Groups:** ExecuteSQL → UpdateAttribute → Output Port
- **HDFS Group:** Input Port → PutHDFS
- **Raw Data Load:** Load data as-is to HDFS
- **No ConvertRecord:** Skip transformation in NiFi

---

## 3. PutHDFS Processor Group

### a. Input Port
- Add an input port (e.g., `from_extractors`) to receive data from extract groups.

### b. PutHDFS (Centralized Configuration)
- **Hadoop Configuration Resources:** Path to `core-site.xml` and `hdfs-site.xml` from your HDFS NameNode:
  - `C:\Tools\core-site.xml` and `C:\Tools\hdfs-site.xml` (convenient copies)
  - **OR** `C:\Tools\hadoop-3.4.2\etc\hadoop\core-site.xml` and `C:\Tools\hadoop-3.4.2\etc\hadoop\hdfs-site.xml` (original location)
- **Directory:** Use dynamic paths based on UpdateAttribute metadata:
  - `/data/${db.type}/${table.name}/` (e.g., `/data/mssql/users/`)
  - **OR** `/data/${db.type}/${table.name}/year=${extract.date:substring(0,4)}/month=${extract.date:substring(5,7)}/` (partitioned)
- **Kerberos:** If your HDFS is secured, configure principal and keytab.
- **Conflict Resolution Strategy:** `replace` (overwrite existing files) or `ignore` (skip duplicates)
- **Block Size:** `128 MB` (HDFS block size)
- **IO Buffer Size:** `4 MB` (buffer for data transfer)
- **Replication:** `3` (HDFS replication factor)
- **Compression Codec:** `NONE` (let destination handle compression)

---

## 4. Connections (ELT with Centralized PutHDFS)

**Your Setup:** Extraction groups route to centralized HDFS loading group.

- **Extraction Groups:** Connect ExecuteSQL/UpdateAttribute → Output Port
- **HDFS Group:** Connect Input Port → PutHDFS processor
- **Inter-Group Connections:** Connect each extraction group's Output Port to the HDFS group's Input Port
- **Raw Data Flow:** Data flows from multiple sources to single HDFS destination

**Connection Benefits:**
- **Centralized Loading:** All data goes through one PutHDFS processor
- **Unified Monitoring:** Single point to monitor all HDFS operations
- **Consistent Configuration:** Same HDFS settings for all sources
- **Resource Efficiency:** Shared HDFS connection management

---

## 5. Start and Monitor (ELT with Centralized PutHDFS)
- Start controller services (DBCP services).
- Start processors in order: DBCP → ExecuteSQL → UpdateAttribute → Output Port (extraction groups) → Input Port → PutHDFS (HDFS group).
- Monitor provenance and logs for errors.
- Check HDFS web UI for loaded data files.

---

## ELT Tips & Best Practices

- **Raw Data Loading:** Load data as-is to HDFS - transform later in Spark/Hive
- **HDFS Partitioning:** Use UpdateAttribute to set partition paths (e.g., `/data/${table.name}/year=${extract.year}/month=${extract.month}/`)
- **File Formats:** Consider Avro for schema evolution, Parquet for analytics
- **Compression:** Use SNAPPY or GZIP for storage efficiency
- **JDBC Drivers:** Place drivers in NiFi's lib directory or reference in DBCP service
- **Kerberos:** Configure credentials if HDFS is secured
- **Testing:** Test each processor group independently before full deployment

#### **Multi-Table ELT Best Practices:**
- **Start Small:** Begin with 2-3 critical tables, then expand
- **Error Handling:** Use RouteOnAttribute for failed extractions
- **Monitoring:** Set up alerts for processor failures and data volume anomalies
- **Performance:** Use appropriate batch sizes (1000-10000 rows) to balance memory and throughput
- **Schema Evolution:** Plan for table schema changes - raw data allows flexibility
- **Dependencies:** If tables have foreign keys, extract parent tables first
- **Testing:** Use GenerateFlowFile with sample data to test HDFS ingestion before connecting to live databases
- **Backpressure:** Configure backpressure settings to prevent memory issues with large datasets
- **Destination Processing:** Plan transformations in Spark/Hive/Presto after loading

#### **ELT Architecture Benefits:**
- **Data Lake Ready:** Raw data enables multiple transformation approaches
- **Future-Proof:** Schema-on-read allows evolving analytics needs
- **Cost Optimization:** Leverage existing big data processing infrastructure
- **Scalability:** Destination systems handle heavy transformations
- **Flexibility:** Transform data differently for different use cases

---

**This setup ensures modular, scalable, and production-ready ELT from multiple RDBMS sources to HDFS. Data is loaded raw and transformed later in your big data processing platform (Spark, Hive, Presto, etc.).**
