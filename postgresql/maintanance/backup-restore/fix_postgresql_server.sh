#!/bin/bash
#
# PostgreSQL pg_hba.conf Configuration Fix
# Run this script on the PostgreSQL server (192.168.180.166) as bob.wabusa
#
# This script adds an entry to allow the user 192.168.3.106 to connect

echo "=========================================="
echo "PostgreSQL pg_hba.conf Configuration Fix"
echo "=========================================="
echo ""

# Configuration
PG_VERSION="15"
PG_MAIN="/etc/postgresql/${PG_VERSION}/main"
PG_HBA_CONF="${PG_MAIN}/pg_hba.conf"
CLIENT_IP="192.168.3.106"
DB_USER="claimant_user"
DB_NAME="claimant_db"

echo "[*] PostgreSQL Version: ${PG_VERSION}"
echo "[*] Client IP: ${CLIENT_IP}"
echo "[*] Database User: ${DB_USER}"
echo "[*] Database: ${DB_NAME}"
echo ""

# Backup pg_hba.conf
echo "[*] Creating backup of pg_hba.conf..."
sudo cp ${PG_HBA_CONF} ${PG_HBA_CONF}.backup
echo "[+] Backup created: ${PG_HBA_CONF}.backup"
echo ""

# Check if entry already exists
echo "[*] Checking for existing entry..."
if sudo grep -q "host.*${DB_NAME}.*${DB_USER}.*${CLIENT_IP}" ${PG_HBA_CONF}; then
    echo "[!] Entry already exists in pg_hba.conf"
else
    echo "[*] Adding new entry to pg_hba.conf..."
    # Add the new entry
    NEW_ENTRY="host    ${DB_NAME}     ${DB_USER}    ${CLIENT_IP}/32        md5"
    echo "${NEW_ENTRY}" | sudo tee -a ${PG_HBA_CONF} > /dev/null
    echo "[+] Entry added: ${NEW_ENTRY}"
fi
echo ""

# Verify the entry
echo "[*] Verifying pg_hba.conf..."
echo "Last 10 lines of pg_hba.conf:"
sudo tail -10 ${PG_HBA_CONF}
echo ""

# Reload PostgreSQL
echo "[*] Reloading PostgreSQL configuration..."
sudo systemctl reload postgresql
if [ $? -eq 0 ]; then
    echo "[+] PostgreSQL reloaded successfully!"
else
    echo "[!] Error reloading PostgreSQL"
    exit 1
fi
echo ""

# Verify PostgreSQL is still running
echo "[*] Verifying PostgreSQL is running..."
sudo systemctl status postgresql --no-pager
echo ""

echo "=========================================="
echo "[+] Configuration complete!"
echo "=========================================="
echo ""
echo "Next steps:"
echo "1. Try connecting from your client (192.168.3.106):"
echo "   psql -h 192.168.180.166 -U ${DB_USER} -d ${DB_NAME}"
echo ""
echo "2. If you still get SSL errors, modify the client connection:"
echo "   psql 'host=192.168.180.166 port=5432 dbname=${DB_NAME} user=${DB_USER} sslmode=disable'"
echo ""
echo "If something goes wrong, restore from backup:"
echo "   sudo cp ${PG_HBA_CONF}.backup ${PG_HBA_CONF}"
echo "   sudo systemctl reload postgresql"
echo ""
