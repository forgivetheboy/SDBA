# dbt Models (PostgreSQL Staging)

## Example Workflow
```bash
cd /opt/dbt/projects/staging_warehouse
/dbt/venv/bin/dbt run
/dbt/venv/bin/dbt test
```

## profiles.yml (example)
```yaml
staging_warehouse:
  target: dev
  outputs:
    dev:
      type: postgres
      host: postgres-staging
      user: staging_user
      password: StrongPassword
      port: 5432
      dbname: staging
      schema: public
      threads: 4
```
