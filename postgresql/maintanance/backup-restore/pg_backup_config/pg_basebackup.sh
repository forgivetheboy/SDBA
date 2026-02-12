#!/bin/bash
#
# PostgreSQL Base Backup Script
# Runs daily at 5:20 PM via cron
# Creates tar format backups with 14-day retention
#

set -e

# Configuration
BACKUP_DIR="/var/backups/postgresql/base"
LOG_FILE="/var/log/postgresql/pg_basebackup.log"
RETENTION_DAYS=14
DATE=$(date +%Y-%m-%d_%H%M%S)
BACKUP_NAME="basebackup_${DATE}"

# SMB Configuration for remote copy
SMB_CRED_FILE="/root/.smbcred_backup"
SMB_SHARE="//192.168.180.161/db_backups$"
SMB_MOUNT_POINT="/mnt/db_backup_share"
REMOTE_BACKUP_DIR="${SMB_MOUNT_POINT}/CLAIMANTSDB-TEST"

# Logging function
log() {
    echo "$(date '+%Y-%m-%d %H:%M:%S') - $1" >> "$LOG_FILE"
    echo "$(date '+%Y-%m-%d %H:%M:%S') - $1"
}

# Create directories if needed
mkdir -p "$(dirname "$LOG_FILE")"
mkdir -p "${BACKUP_DIR}"
touch "$LOG_FILE"
chmod 666 "$LOG_FILE"
chown -R postgres:postgres "${BACKUP_DIR}"

log "========== Starting Base Backup =========="
log "Backup name: ${BACKUP_NAME}"

# Create backup directory
mkdir -p "${BACKUP_DIR}/${BACKUP_NAME}"
chown postgres:postgres "${BACKUP_DIR}/${BACKUP_NAME}"

# Run pg_basebackup as postgres user
log "Running pg_basebackup..."
sudo -u postgres pg_basebackup \
    -D "${BACKUP_DIR}/${BACKUP_NAME}" \
    -Ft \
    -z \
    -Xs \
    -P \
    -v >> "$LOG_FILE" 2>&1

# Verify backup
if [ -f "${BACKUP_DIR}/${BACKUP_NAME}/base.tar.gz" ]; then
    BACKUP_SIZE=$(du -sh "${BACKUP_DIR}/${BACKUP_NAME}" | cut -f1)
    log "Backup completed successfully. Size: ${BACKUP_SIZE}"
else
    log "ERROR: Backup verification failed!"
    exit 1
fi

# Copy to SMB share if credentials exist
if [ -f "$SMB_CRED_FILE" ]; then
    log "Copying backup to remote share..."
    mkdir -p "$SMB_MOUNT_POINT"
    
    # Mount SMB share
    if mount -t cifs "$SMB_SHARE" "$SMB_MOUNT_POINT" -o credentials="$SMB_CRED_FILE",vers=3.0,sec=ntlmssp >> "$LOG_FILE" 2>&1; then
        mkdir -p "$REMOTE_BACKUP_DIR"
        cp -r "${BACKUP_DIR}/${BACKUP_NAME}" "$REMOTE_BACKUP_DIR/" >> "$LOG_FILE" 2>&1
        log "Backup copied to remote share: ${REMOTE_BACKUP_DIR}/${BACKUP_NAME}"
        umount "$SMB_MOUNT_POINT"
    else
        log "WARNING: Could not mount SMB share. Backup remains local only."
    fi
else
    log "No SMB credentials found. Backup stored locally only."
fi

# Cleanup old backups (local)
log "Cleaning up backups older than ${RETENTION_DAYS} days..."
find "$BACKUP_DIR" -maxdepth 1 -type d -name "basebackup_*" -mtime +${RETENTION_DAYS} -exec rm -rf {} \; >> "$LOG_FILE" 2>&1
DELETED_COUNT=$(find "$BACKUP_DIR" -maxdepth 1 -type d -name "basebackup_*" -mtime +${RETENTION_DAYS} 2>/dev/null | wc -l)
log "Deleted ${DELETED_COUNT} old backup(s)"

# List current backups
log "Current backups:"
ls -lh "$BACKUP_DIR" >> "$LOG_FILE" 2>&1

log "========== Base Backup Complete =========="
