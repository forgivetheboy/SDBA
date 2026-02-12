# Metabase Setup (Ubuntu 22.04 LTS)

## Install Java
```bash
sudo apt update
sudo apt install -y openjdk-17-jre
```

## Install Metabase
```bash
sudo mkdir -p /opt/metabase
sudo mkdir -p /data/metabase
sudo chown -R $USER:$USER /opt/metabase /data/metabase

cd /opt/metabase
wget https://downloads.metabase.com/v0.48.6/metabase.jar
```

## Run (systemd)
Create `/etc/systemd/system/metabase.service`:
```
[Unit]
Description=Metabase
After=network.target

[Service]
User=metabase
Group=metabase
WorkingDirectory=/opt/metabase
ExecStart=/usr/bin/java -jar /opt/metabase/metabase.jar
Restart=always

[Install]
WantedBy=multi-user.target
```

Enable:
```bash
sudo useradd -r -s /bin/false metabase
sudo chown -R metabase:metabase /opt/metabase /data/metabase
sudo systemctl daemon-reload
sudo systemctl enable metabase
sudo systemctl start metabase
```

## UI
- http://<metabase-host>:3000
