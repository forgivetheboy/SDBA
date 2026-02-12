#!/bin/bash
#
# PostgreSQL WAL Archive Cleanup Script
# Runs daily to remove WAL archives older than retention period
# Also copies WAL archives to remote SMB share
#

set -e

# Configuration
WAL_ARCHIVE_DIR="/var/backups/postgresql/wal_archive"
LOG_FILE="/var/log/postgresql/wal_cleanup.log"
RETENTION_DAYS=14

# SMB Configuration for remote copy
SMB_CRED_FILE="/root/.smbcred_backup"
SMB_SHARE="//192.168.180.161/db_backups$"
SMB_MOUNT_POINT="/mnt/db_backup_share"
REMOTE_WAL_DIR="${SMB_MOUNT_POINT}/CLAIMANTSDB-TEST/wal_archive"

# Logging function
log() {
    echo "$(date '+%Y-%m-%d %H:%M:%S') - $1" | tee -a "$LOG_FILE"
}

# Create log directory if needed
mkdir -p "$(dirname "$LOG_FILE")"
touch "$LOG_FILE"

log "========== Starting WAL Archive Maintenance =========="

# Count current WAL files
CURRENT_COUNT=$(find "$WAL_ARCHIVE_DIR" -name "*.gz" 2>/dev/null | wc -l)
CURRENT_SIZE=$(du -sh "$WAL_ARCHIVE_DIR" 2>/dev/null | cut -f1)
log "Current WAL archives: ${CURRENT_COUNT} files, ${CURRENT_SIZE}"

# Sync to SMB share if credentials exist
if [ -f "$SMB_CRED_FILE" ]; then
    log "Syncing WAL archives to remote share..."
    mkdir -p "$SMB_MOUNT_POINT"
    
    mount -t cifs "$SMB_SHARE" "$SMB_MOUNT_POINT" -o credentials="$SMB_CRED_FILE",vers=3.0,sec=ntlmssp 2>&1 || {
        log "WARNING: Could not mount SMB share."
    }
    
    if mountpoint -q "$SMB_MOUNT_POINT"; then
        mkdir -p "$REMOTE_WAL_DIR"
        # Sync new WAL files to remote
        rsync -av --ignore-existing "$WAL_ARCHIVE_DIR/"*.gz "$REMOTE_WAL_DIR/" 2>&1 | tee -a "$LOG_FILE" || true
        
        # Cleanup old WAL files on remote share
        find "$REMOTE_WAL_DIR" -name "*.gz" -mtime +${RETENTION_DAYS} -delete 2>&1 | tee -a "$LOG_FILE" || true
        
        log "WAL archives synced to remote share"
        umount "$SMB_MOUNT_POINT"
    fi
fi

# Cleanup old WAL archives (local)
log "Cleaning up WAL archives older than ${RETENTION_DAYS} days..."
BEFORE_COUNT=$(find "$WAL_ARCHIVE_DIR" -name "*.gz" 2>/dev/null | wc -l)
find "$WAL_ARCHIVE_DIR" -name "*.gz" -mtime +${RETENTION_DAYS} -delete 2>&1 | tee -a "$LOG_FILE"
AFTER_COUNT=$(find "$WAL_ARCHIVE_DIR" -name "*.gz" 2>/dev/null | wc -l)
DELETED=$((BEFORE_COUNT - AFTER_COUNT))
log "Deleted ${DELETED} old WAL archive(s)"

# Final status
FINAL_SIZE=$(du -sh "$WAL_ARCHIVE_DIR" 2>/dev/null | cut -f1)
log "Final WAL archives: ${AFTER_COUNT} files, ${FINAL_SIZE}"

log "========== WAL Archive Maintenance Complete =========="
