**Postgres Playground — DBA Quick Walkthrough**

This small playground contains quick scripts and examples a DBA can use to test backups, restores, user administration, and simple DR/HA topics locally.

- **Location:** [postgres-playground/README.md](postgres-playground/README.md)
- **Quick files:**
  - [postgres-playground/scripts/backup.sh](postgres-playground/scripts/backup.sh)
  - [postgres-playground/scripts/restore.sh](postgres-playground/scripts/restore.sh)
  - [postgres-playground/scripts/user_admin.sh](postgres-playground/scripts/user_admin.sh)
  - [postgres-playground/sql/user_admin.sql](postgres-playground/sql/user_admin.sql)
  - [postgres-playground/powershell/backup.ps1](postgres-playground/powershell/backup.ps1)
  - [postgres-playground/powershell/restore.ps1](postgres-playground/powershell/restore.ps1)
  - [postgres-playground/docker/docker-compose.yml](postgres-playground/docker/docker-compose.yml)
  - [postgres-playground/dr_ha.md](postgres-playground/dr_ha.md)

**Quick start (Linux / WSL / Git Bash):**
1. Open a terminal in this folder: `cd postgres-playground`
2. Edit environment variables at top of scripts or export them, e.g.:

```bash
export PGHOST=localhost
export PGPORT=5432
export PGUSER=postgres
export PGPASSWORD=yourpw
```

3. Run a logical backup:

```bash
./scripts/backup.sh --logical
```

4. For a quick replication test, see the docker compose under `docker/` and follow the notes in `dr_ha.md`.

Want help running any step? Tell me which OS you want to test on and I can run through commands.
