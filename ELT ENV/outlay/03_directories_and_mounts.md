# Directory Layouts & Mounts (Ubuntu 22.04 LTS Server GUI)

## Common Base
- `/opt` for applications
- `/data` for persistent data
- `/var/log` for logs
- `/etc` for configs

## NiFi VM
```
/opt/nifi
/data/nifi/content_repository
/data/nifi/flowfile_repository
/data/nifi/provenance_repository
/data/nifi/database_repository
/var/log/nifi
```

## HDFS NameNode
```
/opt/hadoop
/data/hdfs/namenode
/var/log/hadoop
```

## HDFS DataNode
```
/opt/hadoop
/data/hdfs/datanode
/var/log/hadoop
```

## Spark Master / History Server
```
/opt/spark
/data/spark/events
/var/log/spark
```

## Spark Worker
```
/opt/spark
/data/spark/work
/var/log/spark
```

## PostgreSQL Staging + dbt VM
```
/var/lib/postgresql/14/main
/opt/dbt
/var/log/postgresql
```

## Metabase VM
```
/opt/metabase
/data/metabase
/var/log/metabase
```

## Mount Suggestions
- `/data` on separate volume(s) for any disk-heavy service
- Use **ext4** or **xfs** with noatime for HDFS DataNode volumes
