# Security & Operations

## Suggested Hardening
- Enforce TLS for NiFi, Postgres, Metabase
- Limit inbound ports via firewall
- Use SSH keys only
- Separate service users (nifi, hadoop, spark, postgres, metabase)

## Monitoring
- Prometheus + Grafana (optional)
- NiFi Provenance + Bulletin board
- Spark History Server
- HDFS UI + DataNode logs

## Backups
- Postgres nightly dumps
- HDFS snapshots (if enabled)
- Iceberg table snapshots (built-in)

## JAR/NAR Checklist
**NiFi**:
- nifi-hadoop-nar
- nifi-record-serialization-services-nar
- mssql-jdbc-12.6.0.jre11.jar
- postgresql-42.7.1.jar
- ojdbc11-23.x.jar + orai18n-23.x.jar

**Spark**:
- iceberg-spark-runtime-3.4_2.12-<version>.jar

**Iceberg**:
- Uses Spark runtime JAR
