# Apache Iceberg Setup (HDFS)

## Iceberg + Spark Architecture
Iceberg tables live in HDFS. Spark reads/writes using Iceberg runtime JARs.

## Iceberg Catalog (Hadoop Catalog)
Example Spark config:
```
spark.sql.catalog.local=org.apache.iceberg.spark.SparkCatalog
spark.sql.catalog.local.type=hadoop
spark.sql.catalog.local.warehouse=hdfs://namenode:8020/warehouse/iceberg
```

## Warehouse Directory
```bash
hdfs dfs -mkdir -p /warehouse/iceberg
hdfs dfs -chmod -R 775 /warehouse/iceberg
```

## Required JARs (on Spark nodes)
Copy to `/opt/spark/jars`:
- `iceberg-spark-runtime-3.4_2.12-<version>.jar`
- `hadoop-common-3.4.2.jar` (usually bundled)

> Use the Iceberg runtime version compatible with Spark 3.4.x.
