
-- PostgreSQL DBA Playground Script
-- Generated for learning & practice
-- NOTE:
-- Lines starting with '#' are OS/terminal commands (not executed in psql)

/* =========================================================
   SECTION 1: LOGGING INTO POSTGRESQL (OS SHELL)
   ========================================================= */

# psql -h localhost -p 5432 -U postgres
# psql -h localhost -p 5432 -U postgres -d mydb
# psql -U postgres -W


/* =========================================================
   SECTION 2: CONNECTION CONTEXT
   ========================================================= */

\conninfo
SELECT current_user;
SELECT current_database();
SELECT inet_server_addr() AS server_ip, inet_client_addr() AS client_ip;
SELECT version();


/* =========================================================
   SECTION 3: USERS / ROLES
   ========================================================= */

CREATE ROLE sdba
LOGIN
PASSWORD 'Areuroot@3212';

GRANT CONNECT ON DATABASE postgres TO sdba;
GRANT USAGE ON SCHEMA public TO sdba;

GRANT SELECT, INSERT, UPDATE, DELETE
ON ALL TABLES IN SCHEMA public
TO sdba;

ALTER DEFAULT PRIVILEGES IN SCHEMA public
GRANT SELECT, INSERT, UPDATE, DELETE ON TABLES TO sdba;

\du

-- REVOKE ALL PRIVILEGES ON DATABASE mydb FROM sdba;
-- DROP ROLE sdba;


/* =========================================================
   SECTION 4: OBJECT DISCOVERY
   ========================================================= */

\l
\dn
\dt
\dt *.*
\dv
\df
\di


/* =========================================================
   SECTION 5: STORAGE & SIZE
   ========================================================= */

SELECT pg_size_pretty(pg_database_size(current_database())) AS db_size;

SELECT
  schemaname,
  tablename,
  pg_size_pretty(pg_total_relation_size(schemaname||'.'||tablename)) AS table_size
FROM pg_tables
WHERE schemaname NOT IN ('pg_catalog','information_schema')
ORDER BY pg_total_relation_size(schemaname||'.'||tablename) DESC;


/* =========================================================
   SECTION 6: PLAYGROUND DATA
   ========================================================= */

CREATE TABLE IF NOT EXISTS playground_users (
  id SERIAL PRIMARY KEY,
  username TEXT NOT NULL,
  created_at TIMESTAMP DEFAULT now()
);

INSERT INTO playground_users (username)
VALUES ('alice'), ('bob'), ('charlie');

SELECT * FROM playground_users;


/* =========================================================
   SECTION 7: ACTIVITY & LOCKS
   ========================================================= */

SELECT pid, usename, datname, client_addr, state
FROM pg_stat_activity
WHERE datname = current_database();

SELECT
  locktype,
  relation::regclass,
  mode,
  granted
FROM pg_locks
WHERE database = (SELECT oid FROM pg_database WHERE datname = current_database());


/* =========================================================
   SECTION 8: HA / REPLICATION
   ========================================================= */

SELECT pg_is_in_recovery();

SELECT client_addr, state, sync_state, write_lag, replay_lag
FROM pg_stat_replication;

SELECT status, receive_lsn, replay_lsn
FROM pg_stat_wal_receiver;


/* =========================================================
   SECTION 9: BACKUP (OS SHELL)
   ========================================================= */

# pg_dump -U postgres -F c -b -v -f /backups/mydb_full.bak mydb
# pg_dump -U postgres -s mydb > /backups/mydb_schema.sql
# pg_dump -U postgres -a mydb > /backups/mydb_data.sql


/* =========================================================
   SECTION 10: RESTORE (OS SHELL)
   ========================================================= */

# createdb -U postgres mydb_restore
# pg_restore -U postgres -d mydb_restore -v /backups/mydb_full.bak


/* =========================================================
   SECTION 11: PITR
   ========================================================= */

-- wal_level = replica
-- archive_mode = on
-- archive_command = 'cp %p /wal_archive/%f'

# pg_basebackup -U postgres -D /pg_basebackup -Fp -Xs -P

-- restore_command = 'cp /wal_archive/%f %p'
-- recovery_target_time = '2026-01-14 14:30:00'
-- recovery_target_action = promote


/* =========================================================
   SECTION 12: ENCRYPTION
   ========================================================= */

SHOW password_encryption;

CREATE EXTENSION IF NOT EXISTS pgcrypto;

INSERT INTO playground_users (username)
VALUES (encode(digest('secret_user','sha256'),'hex'));


/* =========================================================
   SECTION 13: MAINTENANCE
   ========================================================= */

VACUUM playground_users;
ANALYZE playground_users;


/* =========================================================
   SECTION 14: EXIT
   ========================================================= */

\q
