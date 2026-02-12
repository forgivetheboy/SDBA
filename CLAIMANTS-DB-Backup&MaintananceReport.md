# CLAIMANTS-DB PostgreSQL Backup & Maintenance Report

## Executive Summary

This document provides a comprehensive overview of the PostgreSQL monitoring, backup, and maintenance automation system implemented for the claimants-db server. The system includes real-time monitoring, automated backups, maintenance scheduling, and email alerting capabilities.

**System Overview:**
- **Database**: PostgreSQL 16
- **Server**: Ubuntu 24.04 LTS
- **Monitoring**: 6 automated health checks (every 5 minutes)
- **Backup**: Daily full backups + continuous WAL archiving
- **Maintenance**: Daily and weekly automated tasks
- **Alerting**: Email notifications via msmtp/mutt with operator groups

---

## 1. System Architecture

### Database Configuration
- **PostgreSQL Version**: 16.x
- **Extensions**: pg_stat_statements, pg_buffercache, pg_stat_user_tables
- **Schema**: dba_ops (operator management)
- **Authentication**: Password-based with role-based access

### Server Environment
- **OS**: Ubuntu 24.04 LTS
- **User**: sdba (system DBA account)
- **Scripts Location**: `/opt/postgresql-backup/`
- **Logs Location**: `/var/log/postgresql-backup/`
- **Backup Storage**: SMB/CIFS network share (`//server/backup/postgresql/`)

---

## 2. Monitoring System

### Active Monitors (Running every 5 minutes via cron)

#### 1. Database Connectivity Monitor (`monitor_db_down.sh`)
**Purpose**: Detects database service outages
**Threshold**: Connection failure triggers alert
**Action**: Immediate email alert to DBA team
**Dependencies**: PostgreSQL client tools, email configuration

#### 2. Disk Space Monitor (`monitor_disk_space.sh`)
**Purpose**: Monitors filesystem utilization
**Threshold**: >85% usage triggers warning, >95% critical
**Action**: Email alerts with disk usage details
**Dependencies**: df command, email configuration

#### 3. CPU/Memory Monitor (`monitor_cpu_memory.sh`)
**Purpose**: System resource utilization tracking
**Threshold**: CPU >80%, Memory >85% triggers alerts
**Action**: Email alerts with top processes
**Dependencies**: top, free commands, email configuration

#### 4. Failed Login Monitor (`monitor_failed_logins.sh`)
**Purpose**: Security monitoring for authentication failures
**Threshold**: Any failed login attempts in last 5 minutes
**Action**: Security alert emails with details
**Dependencies**: PostgreSQL logs, email configuration

#### 5. Temporary Files Monitor (`monitor_temp_files.sh`)
**Purpose**: Cleanup of temporary database files
**Threshold**: Files older than 24 hours
**Action**: Automatic cleanup + email report
**Dependencies**: find command, PostgreSQL permissions

#### 6. Backup Age Monitor (`monitor_backup_age.sh`)
**Purpose**: Ensures backup currency
**Threshold**: Last backup >25 hours old
**Action**: Critical alert to DBA team
**Dependencies**: Backup log files, email configuration

### Monitoring Infrastructure
- **Scheduler**: Cron daemon (`/etc/cron.d/postgresql-backup`)
- **Log Rotation**: Daily log rotation with compression
- **Alert Groups**: DBA, Security, System operators
- **Email Format**: HTML with color-coded severity levels

---

## 3. Backup System

### Full Backup (`pg_basebackup.sh`)
**Schedule**: Daily at 23:59
**Method**: pg_basebackup with compression
**Retention**: 90 days rolling retention
**Storage**: Local `/opt/postgresql-backup/basebackups/` + SMB sync
**Compression**: gzip level 6
**Verification**: Checksum validation post-backup

### WAL Archiving (`wal_sync.sh`)
**Schedule**: Continuous (archive_command)
**Method**: WAL file synchronization to SMB share
**Retention**: 90 days rolling retention
**Storage**: `//server/backup/postgresql/wal/`
**Compression**: Enabled for network transfer
**Recovery**: Point-in-time recovery capability

### Backup Verification
- **Integrity Checks**: pg_verifybackup for base backups
- **Restore Testing**: Monthly restore validation
- **Monitoring**: Backup age monitoring (25-hour threshold)
- **Reporting**: Daily backup status emails

---

## 4. Maintenance Automation

### Daily Maintenance (`daily_maintenance.sh`)
**Schedule**: 03:00 daily
**Tasks**:
- VACUUM ANALYZE on all user tables
- REINDEX on system catalogs
- Update table statistics
- Log cleanup (>30 days)
- Temp file cleanup

### Weekly Maintenance (`weekly_index_maintenance.sh`)
**Schedule**: Sundays at 04:00
**Tasks**:
- REINDEX on all indexes
- ANALYZE on all tables
- Index bloat analysis
- Performance optimization recommendations

### Log Rotation (`log_rotation.sh`)
**Schedule**: Daily at 01:00
**Tasks**:
- Compress logs older than 7 days
- Remove logs older than 90 days
- Rotate PostgreSQL logs
- Update log file permissions

### WAL Cleanup (`wal_cleanup.sh`)
**Schedule**: Weekly at 04:30 on Sundays
**Tasks**:
- Remove WAL files older than 90 days (local)
- Remove WAL files older than 90 days (SMB share)
- Log cleanup operations and statistics
- Ensure BCP compliance for archive retention

---

## 5. Email Alerting System

### Configuration
- **MTA**: msmtp (SMTP client)
- **MUA**: mutt (email formatting)
- **SMTP Server**: smtp.gmail.com:587
- **Authentication**: OAuth2/App password
- **Security**: TLS encryption

### Operator Groups
**Database**: DBA team alerts (outages, backup failures)
**Security**: Authentication failures, security events
**System**: Resource alerts, maintenance notifications

### Email Templates
- **Subject Lines**: [DB-ALERT] [SECURITY] [SYSTEM] prefixes
- **HTML Format**: Color-coded severity (Red=Critical, Yellow=Warning)
- **Attachments**: Performance reports, log excerpts
- **Recipients**: Multiple operators per group

---

## 6. Performance Reporting

### Daily Performance Report (`db_daily_perf_report.sh`)
**Schedule**: 06:00 daily
**Sections**:
1. Database uptime and version
2. Connection statistics
3. Top 10 slowest queries
4. Table bloat analysis
5. Index usage statistics
6. Lock contention analysis
7. Checkpoint statistics
8. WAL generation rate
9. Buffer cache hit ratio
10. System resource utilization

**Format**: HTML email with charts and tables
**Recipients**: DBA team
**Retention**: Reports archived for 90 days

---

## 7. Configuration Files

### Cron Schedule (`/etc/cron.d/postgresql-backup`)
```
# PostgreSQL monitoring and backup automation
*/5 * * * * sdba /opt/postgresql-backup/monitor_db_down.sh
*/5 * * * * sdba /opt/postgresql-backup/monitor_disk_space.sh
*/5 * * * * sdba /opt/postgresql-backup/monitor_cpu_memory.sh
*/5 * * * * sdba /opt/postgresql-backup/monitor_failed_logins.sh
*/5 * * * * sdba /opt/postgresql-backup/monitor_temp_files.sh
*/5 * * * * sdba /opt/postgresql-backup/monitor_backup_age.sh
59 23 * * * sdba /opt/postgresql-backup/pg_basebackup.sh
0 3 * * * sdba /opt/postgresql-backup/daily_maintenance.sh
0 4 * * 0 sdba /opt/postgresql-backup/weekly_index_maintenance.sh
30 4 * * 0 sdba /opt/postgresql-backup/wal_cleanup.sh
0 1 * * * sdba /opt/postgresql-backup/log_rotation.sh
0 6 * * * sdba /opt/postgresql-backup/db_daily_perf_report.sh
```

### Email Configuration
- **msmtp**: `/etc/msmtprc` (SMTP settings)
- **mutt**: `/etc/Muttrc` (formatting options)
- **Authentication**: App password stored securely

### Database Schema
```sql
-- Operator management schema
CREATE SCHEMA dba_ops;

CREATE TABLE dba_ops.operator_groups (
    group_name VARCHAR(50) PRIMARY KEY,
    description TEXT,
    active BOOLEAN DEFAULT true
);

CREATE TABLE dba_ops.operators (
    operator_id SERIAL PRIMARY KEY,
    group_name VARCHAR(50) REFERENCES dba_ops.operator_groups(group_name),
    email VARCHAR(255) NOT NULL,
    name VARCHAR(100),
    active BOOLEAN DEFAULT true
);
```

---

## 8. Security Considerations

### Access Control
- **Database**: Role-based access with least privilege
- **Files**: Proper permissions (600 for config files)
- **Backups**: Encrypted storage on network share
- **Logs**: Restricted access, automatic rotation

### Monitoring
- **Authentication**: Failed login detection
- **Integrity**: File permission monitoring
- **Network**: SMB credential security
- **Audit**: All actions logged with timestamps

---

## 9. Troubleshooting Guide

### Common Issues
1. **Email failures**: Check msmtp configuration and credentials
2. **Backup failures**: Verify SMB connectivity and permissions
3. **Monitor alerts**: Check PostgreSQL service status
4. **Performance issues**: Review daily performance reports

### Log Locations
- **Application Logs**: `/var/log/postgresql-backup/`
- **PostgreSQL Logs**: `/var/log/postgresql/`
- **System Logs**: `/var/log/syslog`
- **Cron Logs**: `/var/log/cron`

### Recovery Procedures
- **Database Restore**: Use pg_basebackup + WAL files
- **Configuration Restore**: Backup config files weekly
- **Service Restart**: Standard PostgreSQL restart procedures

---

## 10. Maintenance Checklist

### Daily
- [ ] Monitor alert emails received
- [ ] Backup completion verification
- [ ] Performance report review
- [ ] Log file size monitoring

### Weekly
- [ ] Index maintenance completion
- [ ] Backup integrity testing
- [ ] Configuration file backups
- [ ] Operator contact updates

### Monthly
- [ ] Full restore testing
- [ ] Performance baseline updates
- [ ] Security patch applications
- [ ] Documentation updates

---

## 11. Contact Information

### Primary DBA
- **Name**: Systems DBA
- **Email**: dba@company.com
- **Phone**: (555) 123-4567

### Secondary Contacts
- **DevOps Team**: devops@company.com
- **Security Team**: security@company.com
- **Management**: mgmt@company.com

---

## 12. Change Log

| Date | Change | Author |
|------|--------|--------|
| 2024-02-06 | Initial system implementation | SDBA |
| 2024-02-06 | Monitoring system activation | SDBA |
| 2024-02-06 | Backup automation deployment | SDBA |
| 2024-02-06 | Email alerting configuration | SDBA |
| 2024-02-06 | Documentation completion | SDBA |
| 2026-02-06 | Updated backup retention to 90 days per BCP | SDBA |

---

*This document is automatically generated and should be reviewed monthly for accuracy and completeness.*