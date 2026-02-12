# PostgreSQL Staging Setup (Ubuntu 22.04 LTS)

## Install PostgreSQL
```bash
sudo apt update
sudo apt install -y postgresql postgresql-contrib
sudo systemctl enable postgresql
sudo systemctl start postgresql
```

## Create Database + User
```bash
sudo -u postgres psql <<'SQL'
CREATE DATABASE staging;
CREATE USER staging_user WITH PASSWORD 'StrongPassword';
GRANT ALL PRIVILEGES ON DATABASE staging TO staging_user;
SQL
```

## Network Access
Edit `/etc/postgresql/14/main/postgresql.conf`:
```
listen_addresses = '*'
```

Edit `/etc/postgresql/14/main/pg_hba.conf`:
```
host    all             all             0.0.0.0/0               md5
```

Restart:
```bash
sudo systemctl restart postgresql
```
