# Apache Spark Setup (Ubuntu 22.04 LTS)

## Install Spark
```bash
sudo useradd -m -s /bin/bash spark
sudo mkdir -p /opt/spark
sudo chown -R spark:spark /opt/spark

cd /tmp
wget https://archive.apache.org/dist/spark/spark-3.4.2/spark-3.4.2-bin-hadoop3.tgz
sudo tar -xzf spark-3.4.2-bin-hadoop3.tgz -C /opt
sudo ln -s /opt/spark-3.4.2-bin-hadoop3 /opt/spark
sudo chown -R spark:spark /opt/spark-3.4.2-bin-hadoop3
```

## Spark Config
`/opt/spark/conf/spark-defaults.conf`
```
spark.master                     spark://spark-master:7077
spark.eventLog.enabled            true
spark.eventLog.dir                /data/spark/events
spark.history.fs.logDirectory     /data/spark/events

# Iceberg
spark.sql.catalog.local           org.apache.iceberg.spark.SparkCatalog
spark.sql.catalog.local.type      hadoop
spark.sql.catalog.local.warehouse hdfs://namenode:8020/warehouse/iceberg
```

## Start Master/Worker
```bash
/opt/spark/sbin/start-master.sh
/opt/spark/sbin/start-worker.sh spark://spark-master:7077
```

## Spark UI
- Master UI: http://<spark-master>:8080
- History: http://<spark-master>:18080
