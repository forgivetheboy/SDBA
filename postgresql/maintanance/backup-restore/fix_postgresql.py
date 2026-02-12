#!/usr/bin/env python3
"""
PostgreSQL pg_hba.conf Configuration Fix
Connects to the server and adds the necessary pg_hba.conf entry
"""

import subprocess
import json
import sys

# Configuration
HOST = "192.168.180.166"
USERNAME = "bob.wabusa"
PASSWORD = "BUSA123!"
PORT = 22
CLIENT_IP = "192.168.3.106"
DB_USER = "claimant_user"
DB_NAME = "claimant_db"
PG_HBA_CONF = "/etc/postgresql/15/main/pg_hba.conf"

def run_ssh_command(command, show_output=True):
    """Run a command on the remote server via SSH"""
    ssh_cmd = [
        "ssh",
        "-o", "StrictHostKeyChecking=no",
        "-o", "ConnectTimeout=20",
        "-o", "PasswordAuthentication=yes",
        f"{USERNAME}@{HOST}",
        command
    ]
    
    try:
        result = subprocess.run(
            ssh_cmd,
            capture_output=True,
            text=True,
            timeout=30
        )
        
        if show_output and result.stdout:
            print(result.stdout)
        
        if result.stderr and "warning" not in result.stderr.lower():
            if show_output:
                print(f"[!] {result.stderr}")
        
        return result.returncode == 0, result.stdout, result.stderr
    
    except subprocess.TimeoutExpired:
        print("[!] SSH command timed out")
        return False, "", "Timeout"
    except Exception as e:
        print(f"[!] Error running SSH command: {e}")
        return False, "", str(e)

def main():
    print("=" * 50)
    print("PostgreSQL pg_hba.conf Configuration Fix")
    print("=" * 50)
    print(f"[*] Host: {HOST}")
    print(f"[*] Username: {USERNAME}")
    print(f"[*] Client IP to allow: {CLIENT_IP}")
    print(f"[*] Database: {DB_NAME}")
    print(f"[*] User: {DB_USER}")
    print()
    
    # Step 1: Backup pg_hba.conf
    print("[1/5] Backing up pg_hba.conf...")
    success, _, _ = run_ssh_command(
        f"sudo cp {PG_HBA_CONF} {PG_HBA_CONF}.backup && echo '[+] Backup created'",
        show_output=False
    )
    if not success:
        print("[!] Could not create backup")
        return False
    print("[+] Backup created")
    print()
    
    # Step 2: Check for existing entry
    print("[2/5] Checking for existing entry...")
    success, output, _ = run_ssh_command(
        f"grep -c 'host.*{DB_NAME}.*{DB_USER}.*{CLIENT_IP}' {PG_HBA_CONF} || true",
        show_output=False
    )
    
    entry_exists = output.strip() != "0"
    if entry_exists:
        print("[!] Entry already exists")
    else:
        print("[+] Entry does not exist, adding...")
    print()
    
    # Step 3: Add new entry if needed
    if not entry_exists:
        print("[3/5] Adding new pg_hba.conf entry...")
        new_entry = f"host    {DB_NAME}     {DB_USER}    {CLIENT_IP}/32        md5"
        cmd = f"echo '{new_entry}' | sudo tee -a {PG_HBA_CONF} > /dev/null && echo '[+] Entry added'"
        success, _, _ = run_ssh_command(cmd, show_output=False)
        if not success:
            print("[!] Could not add entry")
            return False
        print(f"[+] Added: {new_entry}")
    else:
        print("[3/5] Skipping (entry already exists)")
    print()
    
    # Step 4: Verify entry
    print("[4/5] Verifying pg_hba.conf...")
    success, output, _ = run_ssh_command(
        f"sudo tail -5 {PG_HBA_CONF}",
        show_output=False
    )
    print("Last 5 lines of pg_hba.conf:")
    print(output)
    print()
    
    # Step 5: Reload PostgreSQL
    print("[5/5] Reloading PostgreSQL...")
    success, _, _ = run_ssh_command(
        "sudo systemctl reload postgresql && echo '[+] PostgreSQL reloaded'",
        show_output=False
    )
    if not success:
        print("[!] Could not reload PostgreSQL")
        return False
    print("[+] PostgreSQL reloaded successfully")
    print()
    
    print("=" * 50)
    print("[+] Configuration Complete!")
    print("=" * 50)
    print()
    print("Next Steps:")
    print("1. Try connecting from your client (192.168.3.106):")
    print(f"   psql -h {HOST} -U {DB_USER} -d {DB_NAME}")
    print()
    print("2. If SSL errors persist, try:")
    print(f"   psql 'host={HOST} port=5432 dbname={DB_NAME} user={DB_USER} sslmode=disable'")
    print()
    print("3. To restore from backup if needed:")
    print(f"   ssh {USERNAME}@{HOST} 'sudo cp {PG_HBA_CONF}.backup {PG_HBA_CONF} && sudo systemctl reload postgresql'")
    print()
    
    return True

if __name__ == "__main__":
    try:
        success = main()
        sys.exit(0 if success else 1)
    except KeyboardInterrupt:
        print("\n[!] Interrupted by user")
        sys.exit(1)
    except Exception as e:
        print(f"[!] Unexpected error: {e}")
        sys.exit(1)
