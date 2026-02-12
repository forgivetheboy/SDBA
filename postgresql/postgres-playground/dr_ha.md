**DR / HA Notes — Quick Reference**

This file summarizes practical DR/HA approaches and quick commands to test locally.

- **Streaming replication (synchronous/asynchronous):**
  - Enable `wal_level = replica`, set `max_wal_senders`, and configure `pg_hba.conf` to allow replication user.
  - Create a replication role: `CREATE ROLE replica WITH REPLICATION LOGIN PASSWORD 'secret';`
  - Use `pg_basebackup` from replica to create a standby data directory:

```bash
pg_basebackup -h primary -D /var/lib/postgresql/12/main -U replica -P -R
```

  - Newer PG uses a `standby.signal` file and `primary_conninfo` in `postgresql.conf` for standby.

- **WAL archiving + PITR:**
  - Configure `archive_mode = on` and `archive_command` to push WAL files to object storage or file share.
  - To restore to a point-in-time, restore base backup, add `recovery.signal` and `restore_command` to fetch WALs.

- **Tools for orchestration:**
  - `repmgr` — cluster management and automated failover for many environments.
  - `Patroni` — uses Etcd/Consul to orchestrate PostgreSQL HA with automatic failover.

- **Simple DR test (local):**
  1. Run the primary (see docker-compose).
  2. Create replication user (use `docker exec` into primary and run SQL).
  3. On the replica host: stop postgres, clear data dir, run `pg_basebackup` against primary.
  4. Create `standby.signal` and add `primary_conninfo = 'host=primary port=5432 user=replica password=secret'`.
  5. Start postgres on replica — it will connect and stream WALs.

- **Failover checklist:**
  - Promote replica via `pg_ctl promote` or `pg_promote()`.
  - Repoint clients using load balancer or DNS.
  - Reconfigure old primary as replica (rebase via basebackup) to rejoin cluster.

For step-by-step automation, we can add a small Docker-based two-node example and init scripts — tell me if you want that and which PG version to target.
