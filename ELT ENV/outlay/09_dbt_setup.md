# dbt Setup (Ubuntu 22.04 LTS)

## Install dbt (Postgres)
```bash
python3 -m venv /opt/dbt/venv
source /opt/dbt/venv/bin/activate
pip install --upgrade pip
pip install dbt-postgres
```

## Initialize Project
```bash
mkdir -p /opt/dbt/projects
cd /opt/dbt/projects
/dbt/venv/bin/dbt init staging_warehouse
```

## profiles.yml
`~/.dbt/profiles.yml`
```yaml
staging_warehouse:
  target: dev
  outputs:
    dev:
      type: postgres
      host: <postgres-host>
      user: staging_user
      password: StrongPassword
      port: 5432
      dbname: staging
      schema: public
      threads: 4
```

## Run
```bash
/dbt/venv/bin/dbt debug
/dbt/venv/bin/dbt run
```
