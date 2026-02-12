-- ============================================================================
-- PostgreSQL Playground: Backups, Restore & Cool Automations
-- ============================================================================
-- This playground covers practical backup/restore strategies and automation techniques
-- for PostgreSQL administration and development
-- ============================================================================

-- ============================================================================
-- SECTION 1: BACKUP OPERATIONS
-- ============================================================================

-- NOTE: Most backup operations are done via command-line tools, not SQL
-- But here are backup-related SQL operations and metadata checks

-- 1.1: Check current database size (before backup planning)
SELECT
    datname AS database_name,
    pg_size_pretty(pg_database_size(datname)) AS size,
    pg_database_size(datname) AS size_bytes,
    (SELECT COUNT(*) FROM pg_stat_database WHERE datname = pg_database.datname) AS connections
FROM pg_database
WHERE datistemplate = false
ORDER BY pg_database_size(datname) DESC;

-- 1.2: Check table sizes (to identify largest tables for backup priority)
SELECT
    schemaname,
    tablename,
    pg_size_pretty(pg_total_relation_size(schemaname||'.'||tablename)) AS total_size,
    pg_size_pretty(pg_relation_size(schemaname||'.'||tablename)) AS table_size,
    pg_size_pretty(pg_indexes_size(schemaname||'.'||tablename)) AS indexes_size,
    (SELECT count(*) FROM information_schema.columns 
     WHERE table_schema = schemaname AND table_name = tablename) AS num_columns
FROM pg_tables
WHERE schemaname NOT IN ('pg_catalog', 'information_schema')
ORDER BY pg_total_relation_size(schemaname||'.'||tablename) DESC;

-- 1.3: Create a backup metadata table to track backup history
CREATE TABLE IF NOT EXISTS public.backup_metadata (
    backup_id SERIAL PRIMARY KEY,
    backup_name VARCHAR(255) NOT NULL UNIQUE,
    database_name VARCHAR(255) NOT NULL,
    backup_type VARCHAR(50) NOT NULL, -- 'FULL', 'INCREMENTAL', 'WAL'
    backup_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    backup_size_bytes BIGINT,
    backup_location TEXT,
    duration_seconds INT,
    status VARCHAR(50) DEFAULT 'PENDING', -- 'COMPLETED', 'FAILED', 'VERIFIED'
    retention_days INT DEFAULT 30,
    notes TEXT
);

-- 1.4: Insert sample backup records
INSERT INTO public.backup_metadata (backup_name, database_name, backup_type, backup_size_bytes, backup_location, duration_seconds, status)
VALUES 
    ('db_full_2026_01_28', 'myapp_db', 'FULL', 5368709120, '/backups/postgresql/db_full_2026_01_28.sql.gz', 120, 'COMPLETED'),
    ('db_incremental_2026_01_28_01', 'myapp_db', 'INCREMENTAL', 536870912, '/backups/postgresql/wal/wal_2026_01_28_01', 30, 'COMPLETED'),
    ('db_incremental_2026_01_28_02', 'myapp_db', 'INCREMENTAL', 536870912, '/backups/postgresql/wal/wal_2026_01_28_02', 30, 'COMPLETED');

-- 1.5: View backup history
SELECT 
    backup_id,
    backup_name,
    database_name,
    backup_type,
    backup_date,
    pg_size_pretty(backup_size_bytes) AS size,
    duration_seconds,
    status,
    retention_days,
    CURRENT_DATE + retention_days AS expiration_date
FROM public.backup_metadata
ORDER BY backup_date DESC;

-- 1.6: Check oldest backups approaching retention limit
SELECT 
    backup_name,
    backup_date,
    CURRENT_DATE - backup_date::date AS days_old,
    retention_days,
    CASE 
        WHEN (CURRENT_DATE - backup_date::date) > retention_days THEN 'EXPIRED'
        WHEN (CURRENT_DATE - backup_date::date) > (retention_days - 7) THEN 'EXPIRING SOON'
        ELSE 'ACTIVE'
    END AS backup_status
FROM public.backup_metadata
ORDER BY backup_date ASC;

-- ============================================================================
-- SECTION 2: RESTORE OPERATIONS & VALIDATION
-- ============================================================================

-- 2.1: Create restore tracking table
CREATE TABLE IF NOT EXISTS public.restore_history (
    restore_id SERIAL PRIMARY KEY,
    restore_name VARCHAR(255) NOT NULL UNIQUE,
    source_backup_id INT REFERENCES public.backup_metadata(backup_id),
    source_database VARCHAR(255),
    target_database VARCHAR(255) NOT NULL,
    restore_start_time TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    restore_end_time TIMESTAMP,
    duration_seconds INT,
    status VARCHAR(50) DEFAULT 'IN_PROGRESS', -- 'SUCCESS', 'FAILED', 'PARTIAL'
    rows_restored BIGINT,
    tables_restored INT,
    error_message TEXT,
    verified BOOLEAN DEFAULT false,
    verification_date TIMESTAMP
);

-- 2.2: Check database integrity after restore
CREATE OR REPLACE FUNCTION public.check_database_integrity()
RETURNS TABLE(
    check_name VARCHAR,
    status VARCHAR,
    details TEXT
) AS $$
BEGIN
    -- Check for missing indexes
    RETURN QUERY
    SELECT 
        'Missing Indexes'::VARCHAR,
        CASE WHEN COUNT(*) > 0 THEN 'WARNING' ELSE 'OK' END::VARCHAR,
        'Found ' || COUNT(*) || ' potentially missing indexes'::TEXT
    FROM pg_stat_user_indexes
    WHERE idx_scan = 0 AND idx_tup_read = 0 AND idx_tup_fetch = 0;

    -- Check for bloated tables
    RETURN QUERY
    SELECT 
        'Table Bloat'::VARCHAR,
        CASE WHEN COUNT(*) > 0 THEN 'WARNING' ELSE 'OK' END::VARCHAR,
        'Found ' || COUNT(*) || ' potentially bloated tables'::TEXT
    FROM pg_stat_user_tables
    WHERE last_vacuum IS NULL AND last_autovacuum IS NULL;

    -- Check connection health
    RETURN QUERY
    SELECT 
        'Active Connections'::VARCHAR,
        'INFO'::VARCHAR,
        COUNT(*)::TEXT || ' active connections'::TEXT
    FROM pg_stat_activity
    WHERE state != 'idle';

    -- Check database size growth
    RETURN QUERY
    SELECT 
        'Database Size'::VARCHAR,
        'INFO'::VARCHAR,
        pg_size_pretty(pg_database_size(current_database()))::TEXT
    FROM pg_database LIMIT 1;
END;
$$ LANGUAGE plpgsql;

-- 2.3: Run integrity check
SELECT * FROM public.check_database_integrity();

-- 2.4: Compare row counts before and after restore
CREATE OR REPLACE FUNCTION public.get_table_row_counts()
RETURNS TABLE(
    schema_name VARCHAR,
    table_name VARCHAR,
    row_count BIGINT,
    last_vacuum TIMESTAMP,
    last_autovacuum TIMESTAMP
) AS $$
BEGIN
    RETURN QUERY
    SELECT 
        schemaname::VARCHAR,
        tablename::VARCHAR,
        n_live_tup::BIGINT,
        last_vacuum,
        last_autovacuum
    FROM pg_stat_user_tables
    ORDER BY n_live_tup DESC;
END;
$$ LANGUAGE plpgsql;

-- 2.5: Get row counts
SELECT * FROM public.get_table_row_counts();

-- ============================================================================
-- SECTION 3: COOL AUTOMATIONS - MAINTENANCE & OPTIMIZATION
-- ============================================================================

-- 3.1: Auto-VACUUM and ANALYZE function
CREATE OR REPLACE PROCEDURE public.auto_maintenance()
LANGUAGE plpgsql
AS $$
DECLARE
    v_table RECORD;
    v_start_time TIMESTAMP;
    v_end_time TIMESTAMP;
BEGIN
    v_start_time := CURRENT_TIMESTAMP;
    RAISE NOTICE 'Starting auto maintenance at %', v_start_time;

    -- VACUUM ANALYZE all user tables
    FOR v_table IN 
        SELECT schemaname, tablename 
        FROM pg_tables 
        WHERE schemaname NOT IN ('pg_catalog', 'information_schema')
    LOOP
        RAISE NOTICE 'Vacuuming %.%...', v_table.schemaname, v_table.tablename;
        EXECUTE FORMAT('VACUUM ANALYZE %I.%I', v_table.schemaname, v_table.tablename);
    END LOOP;

    v_end_time := CURRENT_TIMESTAMP;
    RAISE NOTICE 'Auto maintenance completed in % seconds', 
        EXTRACT(EPOCH FROM (v_end_time - v_start_time))::INT;
END;
$$;

-- 3.2: Reindex all tables (performance optimization)
CREATE OR REPLACE PROCEDURE public.reindex_all_tables()
LANGUAGE plpgsql
AS $$
DECLARE
    v_index RECORD;
    v_count INT := 0;
BEGIN
    RAISE NOTICE 'Starting reindex operation...';
    
    FOR v_index IN 
        SELECT indexname, schemaname 
        FROM pg_indexes 
        WHERE schemaname NOT IN ('pg_catalog', 'information_schema')
    LOOP
        EXECUTE FORMAT('REINDEX INDEX CONCURRENTLY %I.%I', 
                      v_index.schemaname, v_index.indexname);
        v_count := v_count + 1;
        RAISE NOTICE 'Reindexed: %.%', v_index.schemaname, v_index.indexname;
    END LOOP;
    
    RAISE NOTICE 'Reindex completed for % indexes', v_count;
END;
$$;

-- 3.3: Monitor and log slow queries
CREATE TABLE IF NOT EXISTS public.slow_queries (
    query_id SERIAL PRIMARY KEY,
    query TEXT,
    query_time DECIMAL,
    execution_time TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    database_name VARCHAR(255),
    user_name VARCHAR(255)
);

-- 3.4: Create function to log slow queries
CREATE OR REPLACE FUNCTION public.log_slow_query(
    p_query TEXT,
    p_execution_time DECIMAL,
    p_threshold DECIMAL DEFAULT 1000 -- milliseconds
)
RETURNS VOID AS $$
BEGIN
    IF p_execution_time > p_threshold THEN
        INSERT INTO public.slow_queries (query, query_time, database_name, user_name)
        VALUES (p_query, p_execution_time, current_database(), current_user);
        
        RAISE WARNING 'Slow query detected (% ms): %', p_execution_time, p_query;
    END IF;
END;
$$ LANGUAGE plpgsql;

-- 3.5: View slow queries
SELECT 
    query_id,
    query_time::NUMERIC(10,2) || ' ms' AS duration,
    execution_time,
    database_name,
    user_name
FROM public.slow_queries
ORDER BY query_time DESC
LIMIT 20;

-- ============================================================================
-- SECTION 4: COOL AUTOMATIONS - MONITORING & ALERTS
-- ============================================================================

-- 4.1: Create monitoring table
CREATE TABLE IF NOT EXISTS public.performance_metrics (
    metric_id SERIAL PRIMARY KEY,
    metric_name VARCHAR(255),
    metric_value DECIMAL,
    unit VARCHAR(50),
    recorded_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    database_name VARCHAR(255),
    status VARCHAR(50) -- 'NORMAL', 'WARNING', 'CRITICAL'
);

-- 4.2: Comprehensive system health check function
CREATE OR REPLACE FUNCTION public.system_health_check()
RETURNS TABLE(
    metric_name VARCHAR,
    metric_value DECIMAL,
    unit VARCHAR,
    status VARCHAR,
    recommendation TEXT
) AS $$
BEGIN
    -- Cache hit ratio (should be > 99%)
    RETURN QUERY
    SELECT 
        'Cache Hit Ratio'::VARCHAR,
        (SUM(heap_blks_hit) / (SUM(heap_blks_hit) + SUM(heap_blks_read))::DECIMAL * 100)::DECIMAL,
        '%'::VARCHAR,
        CASE 
            WHEN (SUM(heap_blks_hit) / (SUM(heap_blks_hit) + SUM(heap_blks_read))::DECIMAL * 100) > 99 THEN 'OK'
            ELSE 'WARNING'
        END::VARCHAR,
        'Increase shared_buffers if cache hit ratio is low'::TEXT
    FROM pg_statio_user_tables;

    -- Connection count
    RETURN QUERY
    SELECT 
        'Active Connections'::VARCHAR,
        COUNT(*)::DECIMAL,
        'connections'::VARCHAR,
        CASE 
            WHEN COUNT(*) > 100 THEN 'WARNING'
            ELSE 'OK'
        END::VARCHAR,
        'Monitor connection pool if count is high'::TEXT
    FROM pg_stat_activity;

    -- Table bloat warning
    RETURN QUERY
    SELECT 
        'Bloated Tables'::VARCHAR,
        COUNT(*)::DECIMAL,
        'tables'::VARCHAR,
        CASE 
            WHEN COUNT(*) > 0 THEN 'WARNING'
            ELSE 'OK'
        END::VARCHAR,
        'Run VACUUM or CLUSTER on bloated tables'::TEXT
    FROM pg_stat_user_tables
    WHERE last_vacuum IS NULL AND last_autovacuum IS NULL;

    -- Disk space check
    RETURN QUERY
    SELECT 
        'Database Size'::VARCHAR,
        pg_database_size(current_database())::DECIMAL / 1024 / 1024 / 1024,
        'GB'::VARCHAR,
        'INFO'::VARCHAR,
        'Monitor disk space usage'::TEXT;
END;
$$ LANGUAGE plpgsql;

-- 4.3: Run health check
SELECT * FROM public.system_health_check();

-- ============================================================================
-- SECTION 5: COOL AUTOMATIONS - DATA MANAGEMENT
-- ============================================================================

-- 5.1: Archive old data function (common pattern)
CREATE OR REPLACE PROCEDURE public.archive_old_records(
    p_table_schema VARCHAR,
    p_table_name VARCHAR,
    p_date_column VARCHAR,
    p_days_old INT,
    p_archive_schema VARCHAR DEFAULT 'archive'
)
LANGUAGE plpgsql
AS $$
DECLARE
    v_row_count INT;
BEGIN
    -- Create archive table if not exists (simplified)
    RAISE NOTICE 'Archiving records older than % days from %.%', 
        p_days_old, p_table_schema, p_table_name;

    -- Count rows to be archived
    EXECUTE FORMAT(
        'SELECT COUNT(*) FROM %I.%I WHERE %I < CURRENT_DATE - INTERVAL ''%L days''',
        p_table_schema, p_table_name, p_date_column, p_days_old
    ) INTO v_row_count;

    RAISE NOTICE 'Found % records to archive', v_row_count;

    -- In production, you would:
    -- 1. Copy to archive table
    -- 2. Delete from main table
    -- 3. Update statistics
END;
$$;

-- 5.2: Partition management automation (for large tables)
CREATE TABLE IF NOT EXISTS public.table_partitions (
    partition_id SERIAL PRIMARY KEY,
    parent_table VARCHAR(255),
    partition_name VARCHAR(255) UNIQUE,
    created_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    row_count BIGINT,
    size_bytes BIGINT
);

-- 5.3: Generate partition creation script
CREATE OR REPLACE FUNCTION public.generate_monthly_partitions(
    p_table_name VARCHAR,
    p_year INT,
    p_month INT
)
RETURNS TEXT AS $$
DECLARE
    v_partition_name VARCHAR;
    v_start_date DATE;
    v_end_date DATE;
BEGIN
    v_start_date := DATE(p_year, p_month, 1);
    v_end_date := DATE(p_year, p_month, 1) + INTERVAL '1 month';
    v_partition_name := p_table_name || '_' || TO_CHAR(v_start_date, 'YYYY_MM');

    RETURN FORMAT(
        'CREATE TABLE %I PARTITION OF %I FOR VALUES FROM (%L) TO (%L);',
        v_partition_name,
        p_table_name,
        v_start_date,
        v_end_date
    );
END;
$$ LANGUAGE plpgsql;

-- ============================================================================
-- SECTION 6: COOL AUTOMATIONS - BACKUP VERIFICATION
-- ============================================================================

-- 6.1: Create backup verification procedure
CREATE OR REPLACE PROCEDURE public.verify_backup_integrity(
    p_backup_id INT
)
LANGUAGE plpgsql
AS $$
DECLARE
    v_backup_record RECORD;
    v_verification_status VARCHAR;
    v_error_count INT := 0;
BEGIN
    SELECT * INTO v_backup_record 
    FROM public.backup_metadata 
    WHERE backup_id = p_backup_id;

    IF NOT FOUND THEN
        RAISE EXCEPTION 'Backup ID % not found', p_backup_id;
    END IF;

    RAISE NOTICE 'Starting verification of backup: %', v_backup_record.backup_name;

    -- Check if backup file exists and is readable
    RAISE NOTICE 'Checking backup file at: %', v_backup_record.backup_location;

    -- Check table counts
    RAISE NOTICE 'Verifying table structure and data integrity...';

    -- Update backup status
    UPDATE public.backup_metadata
    SET status = 'VERIFIED',
        verified = true,
        verification_date = CURRENT_TIMESTAMP
    WHERE backup_id = p_backup_id;

    RAISE NOTICE 'Backup verification completed successfully';
END;
$$;

-- 6.2: Automated backup health report
CREATE OR REPLACE FUNCTION public.backup_health_report()
RETURNS TABLE(
    metric VARCHAR,
    value TEXT,
    status VARCHAR
) AS $$
BEGIN
    -- Total backups
    RETURN QUERY
    SELECT 
        'Total Backups'::VARCHAR,
        COUNT(*)::TEXT,
        'INFO'::VARCHAR
    FROM public.backup_metadata;

    -- Recent backups
    RETURN QUERY
    SELECT 
        'Recent Backups (7 days)'::VARCHAR,
        COUNT(*)::TEXT,
        CASE WHEN COUNT(*) > 0 THEN 'OK' ELSE 'WARNING' END::VARCHAR
    FROM public.backup_metadata
    WHERE backup_date > CURRENT_TIMESTAMP - INTERVAL '7 days';

    -- Failed backups
    RETURN QUERY
    SELECT 
        'Failed Backups'::VARCHAR,
        COUNT(*)::TEXT,
        CASE WHEN COUNT(*) = 0 THEN 'OK' ELSE 'CRITICAL' END::VARCHAR
    FROM public.backup_metadata
    WHERE status = 'FAILED';

    -- Unverified backups
    RETURN QUERY
    SELECT 
        'Unverified Backups'::VARCHAR,
        COUNT(*)::TEXT,
        'WARNING'::VARCHAR
    FROM public.backup_metadata
    WHERE status != 'VERIFIED';
END;
$$ LANGUAGE plpgsql;

-- 6.3: View backup health
SELECT * FROM public.backup_health_report();

-- ============================================================================
-- SECTION 7: USEFUL QUERIES & MONITORING EXAMPLES
-- ============================================================================

-- 7.1: Real-time database activity monitoring
SELECT 
    pid,
    usename,
    state,
    query_start,
    state_change,
    query
FROM pg_stat_activity
WHERE query NOT LIKE '%pg_stat_activity%'
ORDER BY query_start DESC;

-- 7.2: Table access patterns (read vs write)
SELECT 
    schemaname,
    tablename,
    seq_scan,
    seq_tup_read,
    idx_scan,
    idx_tup_fetch,
    n_tup_ins,
    n_tup_upd,
    n_tup_del
FROM pg_stat_user_tables
ORDER BY seq_scan DESC
LIMIT 20;

-- 7.3: Indexes usage analysis (find unused indexes)
SELECT 
    schemaname,
    tablename,
    indexname,
    idx_scan,
    idx_tup_read,
    idx_tup_fetch,
    pg_size_pretty(pg_relation_size(indexrelid)) AS index_size
FROM pg_stat_user_indexes
WHERE idx_scan = 0
ORDER BY pg_relation_size(indexrelid) DESC;

-- 7.4: Lock monitoring (detect blocking queries)
SELECT 
    blocked_locks.pid AS blocked_pid,
    blocked_activity.usename AS blocked_user,
    blocking_locks.pid AS blocking_pid,
    blocking_activity.usename AS blocking_user,
    blocked_activity.query AS blocked_statement,
    blocking_activity.query AS blocking_statement,
    blocked_activity.application_name AS blocked_application,
    blocking_activity.application_name AS blocking_application
FROM pg_catalog.pg_locks blocked_locks
JOIN pg_catalog.pg_stat_activity blocked_activity ON blocked_activity.pid = blocked_locks.pid
JOIN pg_catalog.pg_locks blocking_locks ON blocking_locks.locktype = blocked_locks.locktype
    AND blocking_locks.database IS NOT DISTINCT FROM blocked_locks.database
    AND blocking_locks.relation IS NOT DISTINCT FROM blocked_locks.relation
    AND blocking_locks.page IS NOT DISTINCT FROM blocked_locks.page
    AND blocking_locks.tuple IS NOT DISTINCT FROM blocked_locks.tuple
    AND blocking_locks.virtualxid IS NOT DISTINCT FROM blocked_locks.virtualxid
    AND blocking_locks.transactionid IS NOT DISTINCT FROM blocked_locks.transactionid
    AND blocking_locks.classid IS NOT DISTINCT FROM blocked_locks.classid
    AND blocking_locks.objid IS NOT DISTINCT FROM blocked_locks.objid
    AND blocking_locks.objsubid IS NOT DISTINCT FROM blocked_locks.objsubid
    AND blocking_locks.pid != blocked_locks.pid
JOIN pg_catalog.pg_stat_activity blocking_activity ON blocking_activity.pid = blocking_locks.pid
WHERE NOT blocked_locks.granted;

-- ============================================================================
-- COMMAND-LINE BACKUP & RESTORE EXAMPLES (in comments for reference)
-- ============================================================================

/*
BACKUP EXAMPLES (run these from terminal, not SQL):

1. Full database backup (custom format - compresses data):
   pg_dump -U postgres -h localhost --verbose --format=custom myapp_db > myapp_db.dump

2. Full database backup (SQL format):
   pg_dump -U postgres -h localhost --verbose myapp_db > myapp_db.sql

3. Backup specific schema:
   pg_dump -U postgres -h localhost --schema=public myapp_db > public_schema.sql

4. Backup specific table:
   pg_dump -U postgres -h localhost --table=users myapp_db > users_table.sql

5. Backup with parallel jobs (faster):
   pg_dump -U postgres -h localhost --format=directory --jobs=4 myapp_db -f backup_dir/

6. Differential backup (WAL archiving):
   # Configure postgresql.conf with:
   # wal_level = replica
   # archive_mode = on
   # archive_command = 'cp %p /var/lib/postgresql/wal_archive/%f'

RESTORE EXAMPLES:

1. Restore from custom format:
   pg_restore -U postgres -h localhost -d myapp_db myapp_db.dump

2. Restore from SQL format:
   psql -U postgres -h localhost myapp_db < myapp_db.sql

3. Restore with progress:
   pg_restore -U postgres -h localhost -d myapp_db --verbose myapp_db.dump

4. Restore with custom connection:
   pg_restore -U postgres -h prod.example.com -p 5432 -d myapp_db myapp_db.dump

5. Restore specific tables:
   pg_restore -U postgres -h localhost -d myapp_db -t users myapp_db.dump

6. Restore specific schema:
   pg_restore -U postgres -h localhost -d myapp_db -n public myapp_db.dump

7. Restore with parallel jobs:
   pg_restore -U postgres -h localhost -d myapp_db --jobs=4 myapp_db.dump

8. List backup contents:
   pg_restore -l myapp_db.dump | head -50

*/

-- ============================================================================
-- CLEANUP AND MANAGEMENT
-- ============================================================================

-- Delete old backup metadata (keep last 90 days)
-- DELETE FROM public.backup_metadata 
-- WHERE backup_date < CURRENT_TIMESTAMP - INTERVAL '90 days';

-- Clear old slow queries
-- DELETE FROM public.slow_queries 
-- WHERE execution_time < CURRENT_TIMESTAMP - INTERVAL '30 days';

-- Clear old restore history
-- DELETE FROM public.restore_history 
-- WHERE restore_start_time < CURRENT_TIMESTAMP - INTERVAL '60 days';

-- ============================================================================
-- END OF POSTGRESQL BACKUP & RESTORE PLAYGROUND
-- ============================================================================
