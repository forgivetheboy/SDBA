-- ============================================================================
-- ORACLE DATABASE 19c ADMIN CONCEPTS - LEARNING PLAYGROUND
-- ============================================================================
-- This is a guided walkthrough for learning basic Oracle 19c administration
-- concepts. Follow along section by section to understand key DBA tasks.
--
-- Prerequisites: Connected to Oracle 19c database with DBA privileges
-- Time to complete: 30-45 minutes

----Database Structure - Understanding instances vs. databases
--Users & Privileges - User management and security
--Tablespace Management - Storage organization and monitoring
--Tables & Segments - Object storage and space usage
--Index Management - Index creation, fragmentation, and optimization
--Schema Objects - Viewing and managing database objects
--Storage & Extents - How Oracle allocates space internally
--Storage Parameters - Table/index configuration tuning
--Dictionary Statistics - Optimizer statistics management
--Performance & Wait Events - Basic performance monitoring
--Recovery & Archiving - Backup and data protection
--Maintenance Tasks - Essential DBA activities with examples
--Diagnostic Queries - Troubleshooting common issues
--Quick Reference - Key data dictionary views
-- ============================================================================

-- ============================================================================        
-- SECTION 1: UNDERSTANDING THE DATABASE STRUCTURE
-- ============================================================================
-- Oracle's architecture is different from SQL Server. Let's start by 
-- understanding what we're working with.

-- 1.1: Get basic database information
SELECT 
    name AS db_name,
    --open_cursors AS max_open_cursors,
    db_unique_name
FROM v$database;

-- What you're seeing:
-- - name: The database name (DB_NAME parameter)
-- - open_cursors: Maximum number of cursors allowed per session
-- - db_unique_name: Unique identifier if using Data Guard

-- 1.2: Check your current database connection
SELECT 
    * 
FROM v$session 
WHERE sid = (SELECT DISTINCT sid FROM v$mystat);

-- What this shows:
-- - Your session info (who you are, what you're doing)
-- - SID (Session ID) - unique identifier for your connection

-- 1.3: Understand the instance
SELECT 
    instance_name,
    host_name,
    startup_time,
    status
FROM v$instance;

-- Key concept: Instance = Running Oracle processes + Memory structures
--              Database = Physical files (datafiles, control files, redo logs)
-- One database can be mounted by multiple instances (Real Application Cluster)



-- ============================================================================
-- SECTION 2: MANAGING USERS & PRIVILEGES
-- ============================================================================
-- Unlike SQL Server logins/users, Oracle separates the concepts clearly.

-- 2.1: View existing users
SELECT 
    username,
    user_id,
    account_status,
    created,
    lock_date,
    expiry_date
FROM dba_users
ORDER BY created DESC;

-- Key points:
-- - account_status: OPEN, LOCKED, EXPIRED, etc.
-- - lock_date: When account was locked (if locked)
-- - expiry_date: Password expiration date

-- 2.2: Create a new user (example - don't run unless you want to create this user)
-- CREATE USER sdba IDENTIFIED BY "SecurePassword123" 
-- DEFAULT TABLESPACE users 
-- QUOTA UNLIMITED ON users;

-- 2.3: View user privileges
SELECT 
    grantee,
    privilege,
    admin_option
FROM dba_sys_privs
WHERE grantee IN ('SDBA', 'SYSTEM', 'SYS')
ORDER BY grantee, privilege;

-- 2.4: Grant basic privileges (example - for a read-only user)
-- GRANT CREATE SESSION TO demo_user;
-- GRANT SELECT ANY TABLE TO demo_user;

-- 2.5: View role assignments
SELECT 
    grantee,
    granted_role,
    admin_option
FROM dba_role_privs
WHERE grantee IN ('DEMO_USER', 'SYSTEM')
ORDER BY grantee;

-- Common roles:
-- - DBA: Full administrative access
-- - CONNECT: Create session + resource privileges
-- - RESOURCE: Create objects in assigned tablespaces
-- - SELECT_CATALOG_ROLE: Read-only access to data dictionary



-- ============================================================================
-- SECTION 3: TABLESPACE MANAGEMENT
-- ============================================================================
-- Tablespaces are Oracle's way of organizing storage (similar to filegroups in SQL Server)

-- 3.1: View all tablespaces
SELECT 
    tablespace_name,
    extent_management,
    allocation_type,
    segment_space_management,
    status
FROM dba_tablespaces
ORDER BY tablespace_name;

-- Key concepts:
-- - extent_management: LOCAL (preferred) vs DICTIONARY
-- - allocation_type: UNIFORM vs AUTOALLOCATE
-- - status: ONLINE, OFFLINE, READ ONLY, etc.

-- 3.2: Check tablespace space usage
SELECT 
    ts.tablespace_name,
    ROUND(SUM(ts.bytes)/1024/1024, 2) AS total_size_mb,
    ROUND(SUM(CASE WHEN fs.bytes IS NULL THEN 0 ELSE fs.bytes END)/1024/1024, 2) AS free_space_mb,
    ROUND((1 - (SUM(CASE WHEN fs.bytes IS NULL THEN 0 ELSE fs.bytes END) / SUM(ts.bytes)))*100, 2) AS used_percent
FROM dba_data_files ts
LEFT JOIN dba_free_space fs ON ts.tablespace_name = fs.tablespace_name 
    AND ts.file_id = fs.file_id
GROUP BY ts.tablespace_name
ORDER BY used_percent DESC;

-- This shows:
-- - Total size of each tablespace
-- - Free space available
-- - Used percentage (alert if > 90%)

-- 3.3: View datafiles (physical files that make up tablespaces)
SELECT 
    file_id,
    tablespace_name,
    file_name,
    bytes / 1024 / 1024 AS size_mb,
    status
FROM dba_data_files
ORDER BY tablespace_name, file_id;

-- 3.4: Check for auto-extend settings
SELECT 
    file_id,
    file_name,
    autoextensible,
    maxbytes / 1024 / 1024 AS max_size_mb
FROM dba_data_files
WHERE tablespace_name = 'USERS'
ORDER BY file_id;



-- ============================================================================
-- SECTION 4: TABLE & SEGMENT MANAGEMENT
-- ============================================================================
-- Understanding what objects consume space in your database

-- 4.1: Find the largest tables
SELECT 
    owner,
    segment_name,
    segment_type,
    ROUND(bytes/1024/1024, 2) AS size_mb
FROM dba_segments
WHERE segment_type IN ('TABLE', 'TABLE PARTITION')
ORDER BY bytes DESC
FETCH FIRST 20 ROWS ONLY;

-- 4.2: Check table structure
SELECT 
    owner,
    table_name,
    num_rows,
    blocks,
    avg_row_len
FROM dba_tables
WHERE owner NOT IN ('SYS', 'SYSTEM', 'SYSAUX')
ORDER BY num_rows DESC
FETCH FIRST 10 ROWS ONLY;

-- Key metrics:
-- - num_rows: Row count (may be stale if stats not updated)
-- - blocks: Number of database blocks allocated
-- - avg_row_len: Average row length in bytes

-- 4.3: Check column information
SELECT 
    owner,
    table_name,
    column_id,
    column_name,
    data_type,
    data_length,
    nullable
FROM dba_tab_columns
WHERE owner NOT IN ('SYS', 'SYSTEM', 'SYSAUX')
    AND table_name = 'EMPLOYEES'  -- Replace with your table name
ORDER BY column_id;



-- ============================================================================
-- SECTION 5: INDEX MANAGEMENT
-- ============================================================================
-- Indexes are crucial for performance tuning

-- 5.1: View all indexes
SELECT 
    owner,
    index_name,
    table_name,
    index_type,
    uniqueness
FROM dba_indexes
WHERE owner NOT IN ('SYS', 'SYSTEM', 'SYSAUX')
ORDER BY owner, table_name;

-- 5.2: Check index fragmentation
SELECT 
    owner,
    index_name,
    blevel,
    leaf_blocks,
    num_rows,
    ROUND((blevel * leaf_blocks) / num_rows, 2) AS height_to_rows_ratio
FROM dba_indexes
WHERE owner NOT IN ('SYS', 'SYSTEM', 'SYSAUX')
    AND num_rows > 1000
ORDER BY blevel DESC, leaf_blocks DESC;

-- Interpretation:
-- - blevel: B-tree height (0 = single leaf block, higher = deeper tree)
-- - leaf_blocks: Number of leaf blocks
-- - height_to_rows_ratio: Lower is better

-- 5.3: Find unused indexes (potential space savers)
SELECT 
    o.owner,
    o.object_name,
    io.leaf_blocks
FROM dba_objects o
LEFT JOIN v$object_usage v ON o.object_id = v.object_id
JOIN dba_indexes io ON o.object_name = io.index_name 
    AND o.owner = io.owner
WHERE o.object_type = 'INDEX'
    AND o.owner NOT IN ('SYS', 'SYSTEM', 'SYSAUX')
    AND v.object_id IS NULL;

-- Note: v$object_usage only tracks indexes used since last startup



-- ============================================================================
-- SECTION 6: SCHEMA OBJECTS & DEPENDENCIES
-- ============================================================================
-- Understanding what exists in your database

-- 6.1: Count objects by type
SELECT 
    object_type,
    COUNT(*) AS object_count
FROM dba_objects
WHERE owner NOT IN ('SYS', 'SYSTEM', 'SYSAUX')
GROUP BY object_type
ORDER BY object_count DESC;

-- 6.2: Find invalid objects
SELECT 
    owner,
    object_type,
    object_name,
    status
FROM dba_objects
WHERE status = 'INVALID'
    AND owner NOT IN ('SYS', 'SYSTEM', 'SYSAUX')
ORDER BY owner, object_type;

-- Invalid objects = Compilation errors (procedures, functions, views)
-- You can fix with: ALTER <object_type> <object_name> COMPILE;

-- 6.3: View object dependencies
SELECT 
    owner,
    name,
    type,
    referenced_owner,
    referenced_name,
    referenced_type
FROM dba_dependencies
WHERE owner = 'DEMO_SCHEMA'  -- Replace with your schema
    AND name = 'SOME_VIEW'    -- Replace with your object
ORDER BY referenced_owner, referenced_name;



-- ============================================================================
-- SECTION 7: STORAGE & EXTENT MANAGEMENT
-- ============================================================================
-- Understanding how Oracle allocates space

-- 7.1: Check segment extents
SELECT 
    tablespace_name,
    owner,
    segment_name,
    extent_id,
    block_id,
    blocks,
    bytes / 1024 / 1024 AS extent_mb
FROM dba_extents
WHERE owner NOT IN ('SYS', 'SYSTEM', 'SYSAUX')
    AND segment_name = 'EMPLOYEES'  -- Replace with your table
ORDER BY extent_id;

-- Extent = Contiguous space allocation
-- Multiple extents = One segment (table/index)

-- 7.2: Check for high extent fragmentation
SELECT 
    owner,
    segment_name,
    segment_type,
    COUNT(*) AS extent_count,
    ROUND(SUM(bytes)/1024/1024, 2) AS total_mb
FROM dba_extents
WHERE owner NOT IN ('SYS', 'SYSTEM', 'SYSAUX')
GROUP BY owner, segment_name, segment_type
HAVING COUNT(*) > 10
ORDER BY extent_count DESC;

-- High extent count = Potential fragmentation (though less critical in modern Oracle)



-- ============================================================================
-- SECTION 8: STORAGE PARAMETERS
-- ============================================================================
-- Understanding table and index parameters

-- 8.1: View table storage parameters
SELECT 
    owner,
    table_name,
    pct_free,
    pct_used,
    ini_trans,
    max_trans,
    initial_extent / 1024 AS initial_extent_kb,
    next_extent / 1024 AS next_extent_kb
FROM dba_tables
WHERE owner NOT IN ('SYS', 'SYSTEM', 'SYSAUX')
FETCH FIRST 10 ROWS ONLY;

-- Key parameters:
-- - pct_free: % of block reserved for updates (default 10)
-- - pct_used: % of block below which inserts stop (default 40)
-- - ini_trans: Initial transaction slots per block
-- - max_trans: Maximum transaction slots per block

-- 8.2: View index storage parameters
SELECT 
    owner,
    index_name,
    pct_free,
    ini_trans,
    max_trans
FROM dba_indexes
WHERE owner NOT IN ('SYS', 'SYSTEM', 'SYSAUX')
FETCH FIRST 10 ROWS ONLY;



-- ============================================================================
-- SECTION 9: DICTIONARY STATISTICS
-- ============================================================================
-- The data dictionary tracks everything about your database

-- 9.1: When was dictionary last analyzed?
SELECT 
    owner,
    table_name,
    num_rows,
    last_analyzed,
    sample_size
FROM dba_tables
WHERE owner NOT IN ('SYS', 'SYSTEM', 'SYSAUX')
ORDER BY last_analyzed DESC NULLS LAST;

-- Recent last_analyzed = Current statistics
-- NULL = Never analyzed = Optimizer uses default estimates

-- 9.2: Check column statistics
SELECT 
    owner,
    table_name,
    column_name,
    num_distinct,
    density,
    num_nulls,
    last_analyzed
FROM dba_tab_columns
WHERE owner NOT IN ('SYS', 'SYSTEM', 'SYSAUX')
    AND table_name = 'EMPLOYEES'
ORDER BY column_id;

-- 9.3: Gather fresh statistics (if needed)
-- EXEC DBMS_STATS.GATHER_TABLE_STATS('DEMO_SCHEMA', 'EMPLOYEES');

-- Better: Use automatic stats gathering (default in Oracle 19c)
-- SELECT * FROM DBA_AUTOTASK_CLIENT WHERE CLIENT_NAME = 'auto optimizer stats collection';



-- ============================================================================
-- SECTION 10: PERFORMANCE & WAIT EVENTS
-- ============================================================================
-- Basic performance monitoring

-- 10.1: Current active sessions
SELECT 
    sid,
    serial#,
    username,
    status,
    osuser,
    machine,
    logon_time
FROM v$session
WHERE type = 'USER'
    AND username IS NOT NULL
ORDER BY logon_time;

-- 10.2: Top wait events
SELECT 
    event,
    total_waits,
    total_timeouts,
    time_waited,
    average_wait
FROM v$system_event
WHERE event NOT IN ('SQL*Net message from client', 'pmon timer', 'smon timer')
ORDER BY time_waited DESC
FETCH FIRST 15 ROWS ONLY;

-- Key wait events to watch:
-- - db file sequential read: Index lookups waiting for I/O
-- - db file scattered read: Full table scans waiting for I/O
-- - direct path read: Large sorts/hash joins
-- - latch free: Contention on internal Oracle structures

-- 10.3: Check locks
SELECT 
    l.sid,
    l.type,
    l.lmode,
    l.request,
    s.username,
    s.osuser,
    s.machine
FROM v$lock l
JOIN v$session s ON l.sid = s.sid
WHERE l.request > 0
ORDER BY l.sid;

-- lmode: Lock mode held (2=row share, 3=row exclusive, 4=share, 6=exclusive)
-- request: Lock mode being requested (0 = no request)



-- ============================================================================
-- SECTION 11: RECOVERY & ARCHIVING
-- ============================================================================
-- Critical for data protection

-- 11.1: Check database archive mode
SELECT 
    log_mode,
    archivelog_change#,
    archive_change#
FROM v$database;

-- ARCHIVELOG = Point-in-time recovery enabled
-- NOARCHIVELOG = Only recovery to last backup

-- 11.2: View redo logs
SELECT 
    group#,
    type,
    member,
    status
FROM v$logfile
ORDER BY group#, type, member;

-- Redo logs record all database changes
-- Used for recovery and replication

-- 11.3: Check archive logs
SELECT 
    name,
    recid,
    stamp
FROM v$archived_log
ORDER BY recid DESC
FETCH FIRST 20 ROWS ONLY;

-- 11.4: Recovery-related parameters
SHOW PARAMETER db_recovery_file_dest;
SHOW PARAMETER log_archive_dest;

-- These control where backups and archive logs are stored



-- ============================================================================
-- SECTION 12: ESSENTIAL MAINTENANCE TASKS
-- ============================================================================
-- Key DBA activities

-- 12.1: Update statistics on a table
-- EXEC DBMS_STATS.GATHER_TABLE_STATS('SCHEMA_NAME', 'TABLE_NAME');

-- 12.2: Rebuild a fragmented index
-- ALTER INDEX schema_name.index_name REBUILD;

-- 12.3: Add a new datafile
-- ALTER TABLESPACE users ADD DATAFILE '/path/to/new_file.dbf' SIZE 100M;

-- 12.4: Resize a datafile
-- ALTER DATABASE DATAFILE '/path/to/file.dbf' RESIZE 500M;

-- 12.5: Enable/disable autoextend
-- ALTER DATABASE DATAFILE '/path/to/file.dbf' AUTOEXTEND ON MAXSIZE 1000M;

-- 12.6: Move a table to different tablespace
-- ALTER TABLE schema_name.table_name MOVE TABLESPACE new_tablespace;

-- 12.7: Truncate (delete all rows + deallocate space)
-- TRUNCATE TABLE schema_name.table_name;

-- 12.8: Create a basic backup (RMAN)
-- RMAN> BACKUP DATABASE PLUS ARCHIVELOG;

-- 12.9: Check space in TEMP tablespace
SELECT 
    tablespace_name,
    ROUND(SUM(bytes)/1024/1024, 2) AS size_mb,
    ROUND(ROUND(SUM(free_blocks)*8)/1024, 2) AS free_space_mb
FROM dba_temp_free_space
GROUP BY tablespace_name;

-- TEMP is used for sorts, hash aggregations, etc.
-- Monitor to prevent ORA-01652: unable to extend temp segment errors



-- ============================================================================
-- SECTION 13: COMMON DIAGNOSTIC QUERIES
-- ============================================================================
-- Troubleshooting tools

-- 13.1: Find blocking sessions
SELECT 
    w.sid waiting_sid,
    w.serial# w_serial,
    w.event,
    h.sid holding_sid,
    h.serial# h_serial
FROM v$lock lw, v$lock lh, v$session w, v$session h
WHERE lw.ltype = lh.ltype
    AND lw.id1 = lh.id1
    AND lw.id2 = lh.id2
    AND lw.block = 1
    AND lh.block = 0
    AND w.sid = lw.sid
    AND h.sid = lh.sid;

-- 13.2: Find long-running queries
SELECT 
    sid,
    sql_id,
    elapsed_seconds,
    cpu_time / 1000000 AS cpu_sec,
    buffer_gets,
    disk_reads
FROM v$sql_monitor
WHERE elapsed_seconds > 60
ORDER BY elapsed_seconds DESC;

-- 13.3: Check alert log for errors
-- Unix/Linux: tail -100 $ORACLE_BASE/diag/rdbms/<db_name>/<instance_name>/trace/alert_<instance_name>.log
-- Windows: Check Oracle Enterprise Manager or review alert.log in TRACE directory

-- 13.4: Find tables without primary keys (data quality issue)
SELECT 
    owner,
    table_name
FROM dba_tables t
WHERE owner NOT IN ('SYS', 'SYSTEM', 'SYSAUX')
    AND NOT EXISTS (
        SELECT 1 FROM dba_constraints c 
        WHERE c.table_name = t.table_name 
            AND c.owner = t.owner 
            AND c.constraint_type = 'P'
    )
ORDER BY owner, table_name;



-- ============================================================================
-- SECTION 14: QUICK REFERENCE - KEY VIEWS
-- ============================================================================
-- Common data dictionary views you'll use regularly

-- v$database      - Database-wide information
-- v$instance      - Instance status and startup info
-- v$session       - Connected sessions
-- v$sqlarea       - SQL statements in library cache
-- v$sql           - Detailed SQL performance metrics
-- v$lock          - Locks held and requested
-- dba_users       - Database users
-- dba_tables      - Table metadata and stats
-- dba_indexes     - Index information
-- dba_segments    - Space allocated to objects
-- dba_extents     - Extent information
-- dba_tablespaces - Tablespace definitions
-- dba_datafiles   - Datafiles and their locations



-- ============================================================================
-- PRACTICE EXERCISES
-- ============================================================================
-- Try these on your own database:

-- Exercise 1: Find your largest 5 tables and their space usage
-- SELECT owner, segment_name, ROUND(bytes/1024/1024/1024, 2) AS size_gb
-- FROM dba_segments WHERE segment_type = 'TABLE'
-- ORDER BY bytes DESC FETCH FIRST 5 ROWS ONLY;

-- Exercise 2: List all tables with no recent statistics
-- SELECT owner, table_name FROM dba_tables 
-- WHERE last_analyzed < TRUNC(SYSDATE) - 30
-- AND owner NOT IN ('SYS', 'SYSTEM', 'SYSAUX');

-- Exercise 3: Find all indexes on a specific table
-- SELECT index_name, uniqueness 
-- FROM dba_indexes WHERE table_name = 'EMPLOYEES' AND owner = 'HR';

-- Exercise 4: Check space growth over time
-- SELECT snap_id, to_date(time_collected,'MM/DD/YYYY HH24:MI:SS') as collection_time
-- FROM dba_hist_snapshot ORDER BY snap_id DESC FETCH FIRST 5 ROWS ONLY;



-- ============================================================================
-- NEXT STEPS TO DEEPEN YOUR KNOWLEDGE
-- ============================================================================
-- 1. Enable query tracing: ALTER SESSION SET STATISTICS_LEVEL=ALL;
-- 2. Use SQL*Plus EXPLAIN PLAN to understand query execution
-- 3. Monitor via Oracle Enterprise Manager (if available)
-- 4. Study initialization parameters: SHOW PARAMETER %param_name%;
-- 5. Practice RMAN backup/recovery procedures in a test environment
-- 6. Learn AWR (Automatic Workload Repository) reports
-- 7. Study Oracle's optimizer hints for query tuning
-- 8. Master partition strategies for large tables

-- ============================================================================
-- END OF PLAYGROUND
-- ============================================================================
