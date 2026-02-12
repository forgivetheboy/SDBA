# 02 — HDFS Layout (Bronze)

```
/bronze/
  mssql/
    <table_name>/dt=YYYY-MM-DD/
  postgres/
    <table_name>/dt=YYYY-MM-DD/
  oracle/
    <table_name>/dt=YYYY-MM-DD/
```

## Example
```
hdfs dfs -mkdir -p /bronze/mssql/orders/dt=2026-01-30
hdfs dfs -mkdir -p /bronze/postgres/customers/dt=2026-01-30
hdfs dfs -mkdir -p /bronze/oracle/invoices/dt=2026-01-30
```

## File Format
- **Parquet** preferred for Iceberg
- Avro acceptable for raw ingestion
