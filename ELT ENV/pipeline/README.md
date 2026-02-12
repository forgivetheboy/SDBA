# ELT Pipeline Scripts (Sequential)

This folder provides a **step-by-step flow** for the ELT pipeline:

1. **NiFi ingestion → HDFS (Bronze)**
2. **Iceberg ACID tables on HDFS (Silver)**
3. **Spark transforms → PostgreSQL staging (Gold)**
4. **dbt models on staging**
5. **Metabase BI**

## Files
- [01_nifi_flow.md](01_nifi_flow.md)
- [02_hdfs_layout.md](02_hdfs_layout.md)
- [03_iceberg_tables.md](03_iceberg_tables.md)
- [spark/04_spark_transform.py](spark/04_spark_transform.py)
- [dbt/README.md](dbt/README.md)
- [dbt/models/stg_orders.sql](dbt/models/stg_orders.sql)
- [05_metabase_setup.md](05_metabase_setup.md)
