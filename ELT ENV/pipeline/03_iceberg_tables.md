# 03 — Iceberg (Silver)

## Spark SQL (Iceberg Catalog)
```
-- spark-defaults.conf
spark.sql.catalog.local=org.apache.iceberg.spark.SparkCatalog
spark.sql.catalog.local.type=hadoop
spark.sql.catalog.local.warehouse=hdfs://namenode:8020/warehouse/iceberg
```

## Create Iceberg Table from Bronze
```sql
CREATE TABLE local.silver_orders (
  order_id BIGINT,
  customer_id BIGINT,
  order_ts TIMESTAMP,
  amount DECIMAL(12,2),
  dt DATE
)
USING iceberg
PARTITIONED BY (dt);

INSERT INTO local.silver_orders
SELECT
  CAST(order_id AS BIGINT) AS order_id,
  CAST(customer_id AS BIGINT) AS customer_id,
  CAST(order_ts AS TIMESTAMP) AS order_ts,
  CAST(amount AS DECIMAL(12,2)) AS amount,
  CAST(dt AS DATE) AS dt
FROM parquet.`hdfs://namenode:8020/bronze/mssql/orders/`;
```

## ACID Notes
- Iceberg handles **snapshot isolation**, **schema evolution**, and **time travel**.
- Use `MERGE INTO` for upserts when supported.
