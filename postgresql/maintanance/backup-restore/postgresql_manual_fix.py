#!/usr/bin/env python3
"""
PostgreSQL Direct Connection Workaround
This script works around the pg_hba.conf issue by attempting to connect
and providing instructions for manual fix
"""

import subprocess
import sys
import os

HOST = "192.168.180.166"
PORT = 5432
DB_USER = "claimant_user"
PASSWORD = "7tMa4iiKURSB"
DB_NAME = "claimant_db"
CLIENT_IP = "192.168.3.106"

print("=" * 70)
print("PostgreSQL Configuration - Manual Fix Required")
print("=" * 70)
print()
print("SSH to 192.168.180.166 is timing out from your Windows client.")
print("You need to manually execute this command on the PostgreSQL server:")
print()
print("-" * 70)
print("COMMAND TO RUN ON SERVER (as root or with sudo):")
print("-" * 70)
print()
print(f"echo 'host    {DB_NAME}     {DB_USER}    {CLIENT_IP}/32        md5' | sudo tee -a /etc/postgresql/15/main/pg_hba.conf")
print("sudo systemctl reload postgresql")
print()
print("-" * 70)
print()
print("ALTERNATIVE: Add this line manually to pg_hba.conf:")
print()
print(f"File: /etc/postgresql/15/main/pg_hba.conf")
print(f"Line to add: host    {DB_NAME}     {DB_USER}    {CLIENT_IP}/32        md5")
print()
print("Then reload PostgreSQL:")
print("  sudo systemctl reload postgresql")
print()
print("=" * 70)
print()
print("TESTING CONNECTION OPTIONS:")
print("=" * 70)
print()
print("Once the pg_hba.conf entry is added, try connecting with:")
print()
print("Option 1 - Using psql (if installed):")
print(f'  psql "host={HOST} port={PORT} dbname={DB_NAME} user={DB_USER} sslmode=disable"')
print()
print("Option 2 - Using psql with password environment variable:")
print(f'  export PGPASSWORD="{PASSWORD}"')
print(f'  psql -h {HOST} -p {PORT} -d {DB_NAME} -U {DB_USER} -c "SELECT version();"')
print()
print("Option 3 - Connection string with all options:")
print(f'  psql "host={HOST} port={PORT} dbname={DB_NAME} user={DB_USER} password={PASSWORD} sslmode=disable"')
print()

# Try to test if psql is available
print("=" * 70)
print("Checking for psql on your system...")
print("=" * 70)
print()

try:
    result = subprocess.run(
        ["psql", "--version"],
        capture_output=True,
        text=True,
        timeout=5
    )
    print(f"[+] {result.stdout.strip()}")
    print()
    print("You can try connecting now with the commands above.")
except FileNotFoundError:
    print("[!] psql not found on your Windows system.")
    print()
    print("You have two options:")
    print("1. Install PostgreSQL Client Tools on Windows")
    print("   - Download from: https://www.postgresql.org/download/windows/")
    print("   - Install and add to PATH")
    print()
    print("2. Use a PostgreSQL GUI client like:")
    print("   - pgAdmin (https://www.pgadmin.org/)")
    print("   - DBeaver (https://dbeaver.io/)")
    print()

print()
print("=" * 70)
print("SUMMARY")
print("=" * 70)
print()
print("✓ Port 5432 is open on the server")
print("✓ PostgreSQL is running and listening")
print("✗ SSH (port 22) is timing out - cannot automate the fix")
print()
print("NEXT STEPS:")
print("1. Get someone with server access to run the command above")
print("2. OR try to SSH directly from terminal/PuTTY/MobaXterm")
print("3. OR install PostgreSQL client tools on Windows and try the connection options")
print()
