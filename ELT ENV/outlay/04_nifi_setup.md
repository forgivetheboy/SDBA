# NiFi Setup (Ubuntu 22.04 LTS Server GUI)

## Install Java
```bash
sudo apt update
sudo apt install -y openjdk-17-jdk
java -version
```

## Install NiFi
```bash
sudo useradd -m -s /bin/bash nifi
sudo mkdir -p /opt/nifi
sudo chown -R nifi:nifi /opt/nifi

# Download
cd /tmp
wget https://archive.apache.org/dist/nifi/2.7.2/nifi-2.7.2-bin.zip
sudo apt install -y unzip
sudo unzip nifi-2.7.2-bin.zip -d /opt
sudo ln -s /opt/nifi-2.7.2 /opt/nifi
sudo chown -R nifi:nifi /opt/nifi-2.7.2
```

## Repositories
```bash
sudo mkdir -p /data/nifi/{content_repository,flowfile_repository,provenance_repository,database_repository}
sudo chown -R nifi:nifi /data/nifi
```

## Configure
Edit `/opt/nifi/conf/nifi.properties`:
```
nifi.web.https.port=8443
nifi.content.repository.directory=/data/nifi/content_repository
nifi.flowfile.repository.directory=/data/nifi/flowfile_repository
nifi.provenance.repository.directory=/data/nifi/provenance_repository
nifi.database.repository.directory=/data/nifi/database_repository
```

## JDBC Drivers (NiFi lib)
Place these in `/opt/nifi/lib`:
- **SQL Server**: `mssql-jdbc-12.6.0.jre11.jar`
- **PostgreSQL**: `postgresql-42.7.1.jar`
- **Oracle**: `ojdbc11-23.x.jar` and `orai18n-23.x.jar`

> These JARs enable JDBC connectivity in NiFi processors like `ExecuteSQL` and `PutDatabaseRecord`.

## NARs
NiFi already bundles core processors. For extra capability:
- `nifi-hadoop-nar` (HDFS processors)
- `nifi-record-serialization-services-nar` (Avro/Parquet/JSON)

## Service (systemd)
Create `/etc/systemd/system/nifi.service`:
```
[Unit]
Description=Apache NiFi
After=network.target

[Service]
Type=forking
User=nifi
Group=nifi
ExecStart=/opt/nifi/bin/nifi.sh start
ExecStop=/opt/nifi/bin/nifi.sh stop
Restart=on-failure

[Install]
WantedBy=multi-user.target
```

Enable:
```bash
sudo systemctl daemon-reload
sudo systemctl enable nifi
sudo systemctl start nifi
```

## UI
- https://<nifi-host>:8443/nifi
