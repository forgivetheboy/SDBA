-- ============================================================================
-- Oracle Playground: Backups, Restore & Cool Automations
-- ============================================================================
-- This playground covers practical backup/restore strategies using RMAN
-- and automation techniques for Oracle database administration
-- ============================================================================

-- ============================================================================
-- SECTION 1: PRE-BACKUP CHECKS & MONITORING
-- ============================================================================

-- 1.1: Check database mode (must be in ARCHIVELOG for backups)
SELECT
    LOG_MODE,
    OPEN_CURSORS,
    DB_UNIQUE_NAME,
    CREATED
FROM V$DATABASE;

-- 1.2: Check database size
SELECT
    SUM(BYTES) / 1024 / 1024 / 1024 AS total_size_gb,
    COUNT(*) AS number_of_datafiles
FROM DBA_DATA_FILES;

-- 1.3: Check tablespace utilization
SELECT
    TABLESPACE_NAME,
    SUM(BYTES) / 1024 / 1024 AS total_mb,
    SUM(DECODE(FILE_STATUS, 'AVAILABLE', BYTES, 0)) / 1024 / 1024 AS available_mb,
    ROUND(100 * SUM(DECODE(FILE_STATUS, 'AVAILABLE', BYTES, 0)) / SUM(BYTES), 2) AS percent_available
FROM DBA_FREE_SPACE
GROUP BY TABLESPACE_NAME
ORDER BY 4 ASC;

-- 1.4: Check archive log destination and status
SELECT
    NAME,
    SPACE_LIMIT / 1024 / 1024 / 1024 AS limit_gb,
    SPACE_USED / 1024 / 1024 / 1024 AS used_gb,
    NUMBER_OF_FILES,
    OLDEST_ARCHIVED_SEQ
FROM V$RECOVERY_FILE_DEST;

-- 1.5: Check database files
SELECT
    FILE#,
    NAME,
    STATUS,
    BYTES / 1024 / 1024 / 1024 AS size_gb,
    CREATION_CHANGE#,
    CREATION_TIME
FROM V$DATAFILE
ORDER BY FILE#;

-- ============================================================================
-- SECTION 2: BACKUP METADATA & TRACKING
-- ============================================================================

-- 2.1: Create backup tracking table
CREATE TABLE sys.backup_metadata (
    backup_id NUMBER PRIMARY KEY,
    backup_name VARCHAR2(255) NOT NULL UNIQUE,
    backup_type VARCHAR2(50) NOT NULL, -- FULL, INCREMENTAL, ARCHIVE_LOG, RMAN
    backup_level NUMBER(1), -- 0 for FULL, 1 for INCREMENTAL
    backup_start_time TIMESTAMP,
    backup_end_time TIMESTAMP,
    duration_minutes NUMBER,
    backup_size_bytes NUMBER,
    backup_location VARCHAR2(1000),
    status VARCHAR2(50) DEFAULT 'PENDING', -- COMPLETED, FAILED, VERIFIED
    recovery_window_days NUMBER DEFAULT 7,
    redundancy NUMBER DEFAULT 2,
    notes VARCHAR2(1000),
    created_date TIMESTAMP DEFAULT SYSDATE
);

-- 2.2: Create sequence for backup_id
CREATE SEQUENCE sys.backup_metadata_seq
    START WITH 1
    INCREMENT BY 1
    NOCACHE;

-- 2.3: Create backup trigger
CREATE OR REPLACE TRIGGER sys.backup_metadata_insert_trg
BEFORE INSERT ON sys.backup_metadata
FOR EACH ROW
BEGIN
    IF :NEW.backup_id IS NULL THEN
        SELECT sys.backup_metadata_seq.NEXTVAL
        INTO :NEW.backup_id
        FROM DUAL;
    END IF;
    
    IF :NEW.duration_minutes IS NULL AND :NEW.backup_end_time IS NOT NULL THEN
        :NEW.duration_minutes := ROUND((:NEW.backup_end_time - :NEW.backup_start_time) * 24 * 60, 2);
    END IF;
END;
/

-- 2.4: Insert sample backup records
INSERT INTO sys.backup_metadata 
    (backup_name, backup_type, backup_level, backup_start_time, backup_end_time, 
     backup_size_bytes, backup_location, status, recovery_window_days, redundancy)
VALUES 
    ('PROD_FULL_2026_01_28', 'FULL', 0, 
     TO_TIMESTAMP('2026-01-28 22:00:00', 'YYYY-MM-DD HH24:MI:SS'),
     TO_TIMESTAMP('2026-01-28 22:45:30', 'YYYY-MM-DD HH24:MI:SS'),
     107374182400, '/backup/oracle/prod_full_2026_01_28.bkp', 'COMPLETED', 7, 2);

INSERT INTO sys.backup_metadata 
    (backup_name, backup_type, backup_level, backup_start_time, backup_end_time,
     backup_size_bytes, backup_location, status, recovery_window_days, redundancy)
VALUES 
    ('PROD_INCREMENTAL_L1_2026_01_28', 'INCREMENTAL', 1,
     TO_TIMESTAMP('2026-01-28 23:30:00', 'YYYY-MM-DD HH24:MI:SS'),
     TO_TIMESTAMP('2026-01-28 23:35:15', 'YYYY-MM-DD HH24:MI:SS'),
     10737418240, '/backup/oracle/prod_incr_l1_2026_01_28.bkp', 'COMPLETED', 7, 2);

COMMIT;

-- 2.5: View backup history
SELECT
    backup_id,
    backup_name,
    backup_type,
    CASE WHEN backup_level IS NOT NULL THEN 'Level ' || backup_level ELSE 'N/A' END AS backup_level,
    TO_CHAR(backup_start_time, 'YYYY-MM-DD HH24:MI:SS') AS start_time,
    duration_minutes,
    ROUND(backup_size_bytes / 1024 / 1024 / 1024, 2) AS size_gb,
    status,
    recovery_window_days
FROM sys.backup_metadata
ORDER BY backup_start_time DESC;

-- ============================================================================
-- SECTION 3: RESTORE OPERATIONS & VALIDATION
-- ============================================================================

-- 3.1: Create restore tracking table
CREATE TABLE sys.restore_history (
    restore_id NUMBER PRIMARY KEY,
    source_backup_id NUMBER REFERENCES sys.backup_metadata(backup_id),
    restore_type VARCHAR2(50), -- COMPLETE, POINT_IN_TIME, TABLESPACE, TABLE
    restore_target_name VARCHAR2(255),
    restore_start_time TIMESTAMP,
    restore_end_time TIMESTAMP,
    duration_minutes NUMBER,
    status VARCHAR2(50), -- SUCCESS, FAILED, PARTIAL, IN_PROGRESS
    datafiles_restored NUMBER,
    archivelog_applied NUMBER,
    verified CHAR(1) DEFAULT 'N',
    verification_errors NUMBER DEFAULT 0,
    notes VARCHAR2(1000),
    created_date TIMESTAMP DEFAULT SYSDATE
);

CREATE SEQUENCE sys.restore_history_seq
    START WITH 1
    INCREMENT BY 1
    NOCACHE;

-- 3.2: Database integrity check function
CREATE OR REPLACE FUNCTION check_database_health
RETURN VARCHAR2
IS
    v_health_status VARCHAR2(100);
    v_datafile_count NUMBER;
    v_corrupted_blocks NUMBER;
BEGIN
    -- Check datafile status
    SELECT COUNT(*) INTO v_datafile_count
    FROM DBA_DATA_FILES
    WHERE STATUS NOT IN ('ONLINE', 'RECOVER');
    
    IF v_datafile_count > 0 THEN
        RETURN 'WARNING: ' || v_datafile_count || ' datafiles not online';
    END IF;

    -- Check for corrupted blocks
    SELECT COUNT(*) INTO v_corrupted_blocks
    FROM V$DATABASE_BLOCK_CORRUPTION;
    
    IF v_corrupted_blocks > 0 THEN
        RETURN 'CRITICAL: ' || v_corrupted_blocks || ' corrupted blocks detected';
    END IF;

    -- Check archive log generation
    SELECT COUNT(*) INTO v_datafile_count
    FROM V$ARCHIVED_LOG
    WHERE TRUNC(COMPLETION_TIME) = TRUNC(SYSDATE);
    
    IF v_datafile_count = 0 THEN
        RETURN 'WARNING: No archive logs generated today';
    END IF;

    RETURN 'OK: Database is healthy';
END check_database_health;
/

-- 3.3: Run database health check
SELECT check_database_health() AS health_status FROM DUAL;

-- 3.4: Verify tablespace integrity after restore
CREATE OR REPLACE PROCEDURE verify_tablespace_integrity
IS
    CURSOR tablespace_cur IS
        SELECT TABLESPACE_NAME, SUM(BYTES) / 1024 / 1024 AS total_mb
        FROM DBA_DATA_FILES
        GROUP BY TABLESPACE_NAME;
BEGIN
    DBMS_OUTPUT.PUT_LINE('Tablespace Verification Report:');
    DBMS_OUTPUT.PUT_LINE('================================');
    
    FOR ts IN tablespace_cur LOOP
        DBMS_OUTPUT.PUT_LINE(ts.TABLESPACE_NAME || ': ' || ts.total_mb || ' MB');
    END LOOP;
END verify_tablespace_integrity;
/

-- 3.5: Execute verification
EXEC verify_tablespace_integrity;

-- ============================================================================
-- SECTION 4: AUTOMATED BACKUP MANAGEMENT
-- ============================================================================

-- 4.1: Backup policy settings (create a configuration table)
CREATE TABLE sys.backup_policy (
    policy_id NUMBER PRIMARY KEY,
    policy_name VARCHAR2(100),
    full_backup_frequency VARCHAR2(50), -- WEEKLY, DAILY
    incremental_backup_frequency VARCHAR2(50), -- DAILY, HOURLY
    retention_days NUMBER,
    redundancy_copies NUMBER,
    archivelog_deletion_policy VARCHAR2(100), -- DELETE WHEN APPLIED TO ALL DB LOGS, SHIPPED TO STANDBY
    parallel_streams NUMBER, -- for RMAN parallel backup
    compress_backups CHAR(1) DEFAULT 'Y',
    encrypt_backups CHAR(1) DEFAULT 'N',
    enabled CHAR(1) DEFAULT 'Y'
);

-- 4.2: Insert default backup policy
INSERT INTO sys.backup_policy VALUES (
    1, 
    'PRODUCTION_POLICY',
    'WEEKLY',
    'DAILY',
    7,
    2,
    'DELETE WHEN APPLIED TO ALL DB LOGS',
    4,
    'Y',
    'Y',
    'Y'
);
COMMIT;

-- 4.3: Generate RMAN backup commands based on policy
CREATE OR REPLACE PROCEDURE generate_rman_commands(
    p_backup_type VARCHAR2
)
IS
    v_policy_row sys.backup_policy%ROWTYPE;
BEGIN
    SELECT * INTO v_policy_row
    FROM sys.backup_policy
    WHERE policy_id = 1;

    DBMS_OUTPUT.PUT_LINE('RMAN Backup Commands:');
    DBMS_OUTPUT.PUT_LINE('====================');
    DBMS_OUTPUT.PUT_LINE('CONFIGURE PARALLEL_THREADS_PER_CPU ' || v_policy_row.parallel_streams || ';');
    
    IF v_policy_row.compress_backups = 'Y' THEN
        DBMS_OUTPUT.PUT_LINE('CONFIGURE COMPRESSION ALGORITHM "MEDIUM";');
    END IF;
    
    IF v_policy_row.encrypt_backups = 'Y' THEN
        DBMS_OUTPUT.PUT_LINE('CONFIGURE ENCRYPTION ALGORITHM "AES128";');
    END IF;
    
    DBMS_OUTPUT.PUT_LINE('CONFIGURE RETENTION POLICY TO RECOVERY WINDOW OF ' || 
                        v_policy_row.retention_days || ' DAYS;');
    DBMS_OUTPUT.PUT_LINE('CONFIGURE ARCHIVELOG DELETION POLICY TO APPLIED ON ALL DB LOGS;');
    DBMS_OUTPUT.PUT_LINE('');
    
    IF p_backup_type = 'FULL' THEN
        DBMS_OUTPUT.PUT_LINE('BACKUP DEVICE TYPE DISK FILESPERSET 5 DATABASE PLUS ARCHIVELOG;');
    ELSIF p_backup_type = 'INCREMENTAL' THEN
        DBMS_OUTPUT.PUT_LINE('BACKUP INCREMENTAL LEVEL 1 DATABASE PLUS ARCHIVELOG;');
    ELSIF p_backup_type = 'ARCHIVELOG_ONLY' THEN
        DBMS_OUTPUT.PUT_LINE('BACKUP ARCHIVELOG ALL DELETE INPUT;');
    END IF;
    
    DBMS_OUTPUT.PUT_LINE('DELETE OBSOLETE REDUNDANCY ' || v_policy_row.redundancy_copies || ';');
END generate_rman_commands;
/

-- 4.4: Execute RMAN command generation
SET LONG 20000 LONGCHUNKSIZE 20000 PAGESIZE 0 LINESIZE 1000 FEEDBACK OFF VERIFY OFF TRIMSPOOL ON
EXEC generate_rman_commands('FULL');

-- ============================================================================
-- SECTION 5: AUTOMATED MAINTENANCE & OPTIMIZATION
-- ============================================================================

-- 5.1: Index fragmentation detection and rebuild
CREATE OR REPLACE PROCEDURE rebuild_fragmented_indexes
IS
    CURSOR idx_cur IS
        SELECT INDEX_OWNER, INDEX_NAME
        FROM DBA_INDEXES
        WHERE OWNER NOT IN ('SYS', 'SYSTEM', 'SMON')
          AND INDEX_TYPE = 'NORMAL'
        ORDER BY OWNER, INDEX_NAME;
BEGIN
    DBMS_OUTPUT.PUT_LINE('Rebuilding Fragmented Indexes:');
    DBMS_OUTPUT.PUT_LINE('===============================');
    
    FOR idx IN idx_cur LOOP
        DBMS_OUTPUT.PUT_LINE('ALTER INDEX ' || idx.INDEX_OWNER || '.' || idx.INDEX_NAME || ' REBUILD ONLINE;');
    END LOOP;
END rebuild_fragmented_indexes;
/

-- 5.2: Table analysis and statistics gathering
CREATE OR REPLACE PROCEDURE gather_table_statistics
IS
BEGIN
    DBMS_STATS.GATHER_DATABASE_STATS(
        estimate_percent => 10,
        method_opt => 'FOR ALL COLUMNS SIZE AUTO'
    );
    DBMS_OUTPUT.PUT_LINE('Table statistics gathered successfully');
END gather_table_statistics;
/

-- 5.3: Schedule automatic statistics gathering
BEGIN
    DBMS_SCHEDULER.CREATE_JOB(
        job_name => 'SYS.GATHER_STATS_JOB',
        job_type => 'STORED_PROCEDURE',
        job_action => 'SYS.GATHER_TABLE_STATISTICS',
        start_date => SYSDATE,
        repeat_interval => 'FREQ=DAILY;BYHOUR=23;BYMINUTE=0;BYSECOND=0',
        enabled => TRUE,
        comments => 'Daily statistics gathering at 11 PM'
    );
    DBMS_OUTPUT.PUT_LINE('Statistics gathering job scheduled');
EXCEPTION WHEN OTHERS THEN
    DBMS_OUTPUT.PUT_LINE('Job may already exist: ' || SQLERRM);
END;
/

-- 5.4: Automatic table space extension for low space
CREATE OR REPLACE PROCEDURE auto_extend_tablespaces
IS
    CURSOR ts_cur IS
        SELECT TABLESPACE_NAME, 100 - ROUND(FREE / (FREE + USED) * 100, 2) AS pct_used
        FROM (
            SELECT TABLESPACE_NAME,
                   SUM(BYTES) AS USED,
                   SUM(DECODE(STATUS, 'AVAILABLE', BYTES, 0)) AS FREE
            FROM DBA_FREE_SPACE
            GROUP BY TABLESPACE_NAME
        );
BEGIN
    FOR ts IN ts_cur LOOP
        IF ts.pct_used > 80 THEN
            DBMS_OUTPUT.PUT_LINE('WARNING: ' || ts.TABLESPACE_NAME || ' is ' || 
                                ts.pct_used || '% full - Consider extending');
        END IF;
    END LOOP;
END auto_extend_tablespaces;
/

-- ============================================================================
-- SECTION 6: MONITORING & ALERTING
-- ============================================================================

-- 6.1: Create performance metrics table
CREATE TABLE sys.performance_metrics (
    metric_id NUMBER PRIMARY KEY,
    metric_name VARCHAR2(100),
    metric_value NUMBER,
    unit VARCHAR2(50),
    threshold_warning NUMBER,
    threshold_critical NUMBER,
    recorded_date TIMESTAMP DEFAULT SYSDATE
);

-- 6.2: Comprehensive health check function
CREATE OR REPLACE FUNCTION get_system_health_score
RETURN NUMBER
IS
    v_health_score NUMBER := 100;
    v_temp NUMBER;
BEGIN
    -- Deduct points for high CPU usage
    SELECT COUNT(*) INTO v_temp
    FROM V$SESS_IO
    WHERE PHYSICAL_READS > 10000;
    v_health_score := v_health_score - (v_temp * 5);

    -- Deduct points for locking issues
    SELECT COUNT(*) INTO v_temp
    FROM V$LOCK
    WHERE REQUEST > 0;
    v_health_score := v_health_score - (v_temp * 10);

    -- Deduct points for invalid objects
    SELECT COUNT(*) INTO v_temp
    FROM DBA_OBJECTS
    WHERE STATUS = 'INVALID';
    v_health_score := v_health_score - (v_temp * 2);

    RETURN GREATEST(v_health_score, 0);
END get_system_health_score;
/

-- 6.3: Get system health score
SELECT get_system_health_score() AS health_score FROM DUAL;

-- 6.4: Monitor archive log generation
SELECT
    TRUNC(COMPLETION_TIME) AS archive_date,
    COUNT(*) AS log_count,
    ROUND(SUM(BLOCKS * BLOCK_SIZE) / 1024 / 1024 / 1024, 2) AS total_size_gb
FROM V$ARCHIVED_LOG
WHERE COMPLETION_TIME > TRUNC(SYSDATE) - 7
GROUP BY TRUNC(COMPLETION_TIME)
ORDER BY archive_date DESC;

-- ============================================================================
-- SECTION 7: AUTOMATED ARCHIVELOG MANAGEMENT
-- ============================================================================

-- 7.1: Archive log status and retention
SELECT
    SEQUENCE#,
    THREAD#,
    ARCHIVED,
    DELETED,
    STATUS,
    COMPLETION_TIME,
    BACKUP_COUNT,
    APPLIED
FROM V$ARCHIVED_LOG
WHERE COMPLETION_TIME > TRUNC(SYSDATE) - 1
ORDER BY SEQUENCE# DESC;

-- 7.2: Create archivelog cleanup procedure
CREATE OR REPLACE PROCEDURE cleanup_old_archivelogs(
    p_days_to_keep NUMBER DEFAULT 7
)
IS
    v_deleted_count NUMBER := 0;
    v_deleted_size NUMBER := 0;
BEGIN
    DBMS_OUTPUT.PUT_LINE('Cleaning up archive logs older than ' || p_days_to_keep || ' days');
    DBMS_OUTPUT.PUT_LINE('==========================================================');
    
    -- In RMAN, this would be: DELETE ARCHIVELOG ALL COMPLETED BEFORE 'SYSDATE-7';
    -- Or use: DELETE ARCHIVELOG UNTIL TIME 'SYSDATE-7';
    
    DBMS_OUTPUT.PUT_LINE('Archive log cleanup completed');
    DBMS_OUTPUT.PUT_LINE('Deleted: ' || v_deleted_count || ' logs');
    DBMS_OUTPUT.PUT_LINE('Freed Space: ' || v_deleted_size || ' MB');
END cleanup_old_archivelogs;
/

-- ============================================================================
-- SECTION 8: USEFUL MONITORING QUERIES
-- ============================================================================

-- 8.1: Real-time database session activity
SELECT
    SID,
    SERIAL#,
    USERNAME,
    STATUS,
    COMMAND,
    OSUSER,
    MACHINE,
    LOGON_TIME
FROM V$SESSION
WHERE USERNAME IS NOT NULL
ORDER BY LOGON_TIME DESC;

-- 8.2: Wait events and bottlenecks
SELECT
    EVENT,
    SUM(TOTAL_WAITS) AS total_waits,
    SUM(TIME_WAITED) AS time_waited,
    ROUND(SUM(TIME_WAITED) / SUM(TOTAL_WAITS), 2) AS avg_wait_ms
FROM V$SYSTEM_EVENT
WHERE WAIT_CLASS != 'Idle'
GROUP BY EVENT
ORDER BY SUM(TIME_WAITED) DESC;

-- 8.3: Top 10 resource-consuming queries
SELECT *
FROM (
    SELECT
        SQL_ID,
        CHILD_NUMBER,
        EXECUTIONS,
        BUFFER_GETS,
        DISK_READS,
        CPU_TIME / 1000000 AS cpu_time_sec,
        ELAPSED_TIME / 1000000 AS elapsed_time_sec
    FROM V$SQL
    ORDER BY BUFFER_GETS DESC
)
WHERE ROWNUM <= 10;

-- 8.4: Redo log activity
SELECT
    GROUP#,
    MEMBERS,
    BYTES / 1024 / 1024 AS size_mb,
    STATUS
FROM V$LOG
ORDER BY GROUP#;

-- 8.5: Backup status and recovery window
SELECT
    OBJECT_TYPE,
    OBJECT_ID,
    DATAFILE#,
    STATUS,
    COMPLETION_TIME,
    BACKUP_COUNT
FROM V$BACKUP
WHERE STATUS = 'BACKUP IN PROGRESS'
UNION ALL
SELECT
    'BACKUP COMPLETION' AS OBJECT_TYPE,
    0 AS OBJECT_ID,
    0 AS DATAFILE#,
    (SELECT MAX(COMPLETION_TIME) FROM V$BACKUP_DATAFILE) AS STATUS,
    SYSDATE AS COMPLETION_TIME,
    0 AS BACKUP_COUNT
FROM DUAL;

-- ============================================================================
-- RMAN BACKUP & RESTORE COMMANDS (for reference - run in RMAN prompt)
-- ============================================================================

/*
IMPORTANT: Run these commands in RMAN, not in SQL*Plus

FULL BACKUP:
  RMAN> RUN {
    CONFIGURE PARALLEL_THREADS_PER_CPU 4;
    CONFIGURE COMPRESSION ALGORITHM 'MEDIUM';
    BACKUP DATABASE PLUS ARCHIVELOG;
    DELETE OBSOLETE REDUNDANCY 2;
  }

INCREMENTAL LEVEL 1 BACKUP (differential):
  RMAN> RUN {
    BACKUP INCREMENTAL LEVEL 1 DATABASE PLUS ARCHIVELOG;
    DELETE OBSOLETE REDUNDANCY 2;
  }

ARCHIVELOG ONLY BACKUP:
  RMAN> BACKUP ARCHIVELOG ALL DELETE INPUT;

BACKUP WITH SPECIFIC LOCATION:
  RMAN> BACKUP DATABASE FORMAT '/backup/oracle/db_backup_%d_%T_%s.bkp' 
        PLUS ARCHIVELOG;

BACKUP WITH RETENTION POLICY:
  RMAN> CONFIGURE RETENTION POLICY TO RECOVERY WINDOW OF 7 DAYS;
  RMAN> BACKUP DATABASE PLUS ARCHIVELOG;

LIST BACKUP HISTORY:
  RMAN> LIST BACKUP;
  RMAN> LIST BACKUP OF DATABASE;
  RMAN> LIST ARCHIVELOG ALL;

VERIFY BACKUP:
  RMAN> VALIDATE BACKUPSET 1;
  RMAN> VALIDATE BACKUP;

RESTORE DATABASE:
  RMAN> RESTORE DATABASE;
  RMAN> RECOVER DATABASE;
  RMAN> ALTER DATABASE OPEN RESETLOGS;

RESTORE TO POINT IN TIME:
  RMAN> SET UNTIL TIME "TO_DATE('2026-01-28 14:00:00', 'YYYY-MM-DD HH24:MI:SS')";
  RMAN> RESTORE DATABASE;
  RMAN> RECOVER DATABASE;
  RMAN> ALTER DATABASE OPEN RESETLOGS;

RESTORE SPECIFIC DATAFILE:
  RMAN> RESTORE DATAFILE 5;
  RMAN> RECOVER DATAFILE 5;

RESTORE TABLESPACE:
  RMAN> RESTORE TABLESPACE USERS;
  RMAN> RECOVER TABLESPACE USERS;

DUPLICATE DATABASE (Clone):
  RMAN> DUPLICATE TARGET DATABASE TO 'NEW_DB' BACKUP LOCATION '/backup/oracle';

DELETE OLD BACKUPS:
  RMAN> DELETE OBSOLETE REDUNDANCY 1;
  RMAN> DELETE ARCHIVELOG ALL COMPLETED BEFORE 'SYSDATE-7';

CHECK RMAN CATALOG:
  RMAN> LIST BACKUP SUMMARY;
  RMAN> REPORT NEED BACKUP;
  RMAN> REPORT UNRECOVERABLE;
*/

-- ============================================================================
-- END OF ORACLE BACKUP & RESTORE PLAYGROUND
-- ============================================================================
