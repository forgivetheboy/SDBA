# HDFS Setup (Ubuntu 22.04 LTS Server GUI)

## Install Java
```bash
sudo apt update
sudo apt install -y openjdk-11-jdk
java -version
```

## Install Hadoop
```bash
sudo useradd -m -s /bin/bash hadoop
sudo mkdir -p /opt/hadoop
sudo chown -R hadoop:hadoop /opt/hadoop

cd /tmp
wget https://archive.apache.org/dist/hadoop/common/hadoop-3.4.2/hadoop-3.4.2.tar.gz
sudo tar -xzf hadoop-3.4.2.tar.gz -C /opt
sudo ln -s /opt/hadoop-3.4.2 /opt/hadoop
sudo chown -R hadoop:hadoop /opt/hadoop-3.4.2
```

## Configure core-site.xml
`/opt/hadoop/etc/hadoop/core-site.xml`
```xml
<configuration>
  <property>
    <name>fs.defaultFS</name>
    <value>hdfs://namenode:8020</value>
  </property>
</configuration>
```

## Configure hdfs-site.xml
NameNode:
```xml
<configuration>
  <property>
    <name>dfs.namenode.name.dir</name>
    <value>/data/hdfs/namenode</value>
  </property>
  <property>
    <name>dfs.namenode.http-address</name>
    <value>0.0.0.0:9870</value>
  </property>
</configuration>
```

DataNode:
```xml
<configuration>
  <property>
    <name>dfs.datanode.data.dir</name>
    <value>/data/hdfs/datanode</value>
  </property>
  <property>
    <name>dfs.datanode.http.address</name>
    <value>0.0.0.0:9864</value>
  </property>
</configuration>
```

## Format NameNode
```bash
/opt/hadoop/bin/hdfs namenode -format
```

## Start HDFS
```bash
/opt/hadoop/sbin/start-dfs.sh
```

## UI
- NameNode: http://<namenode-host>:9870
- DataNode: http://<datanode-host>:9864
