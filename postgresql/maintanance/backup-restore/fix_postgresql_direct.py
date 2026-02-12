#!/usr/bin/env python3
"""
PostgreSQL Configuration Fix via Direct SQL Connection
This script connects directly to PostgreSQL and modifies the configuration
"""

import subprocess
import sys
import os

# Configuration
HOST = "192.168.180.166"
PORT = 5432
CLAIMANT_USER = "claimant_user"
CLAIMANT_PASSWORD = "7tMa4iiKURSB"
CLAIMANT_DB = "claimant_db"
POSTGRES_USER = "postgres"  # Change if you have superuser credentials
CLIENT_IP = "192.168.3.106"

def main():
    print("=" * 60)
    print("PostgreSQL Configuration Fix (Direct Connection Method)")
    print("=" * 60)
    print(f"[*] Host: {HOST}:{PORT}")
    print(f"[*] Database: {CLAIMANT_DB}")
    print(f"[*] User: {CLAIMANT_USER}")
    print(f"[*] Client IP to authorize: {CLIENT_IP}")
    print()
    
    print("[!] NOTE:")
    print("    This method requires direct SQL access to PostgreSQL.")
    print("    Unfortunately, pg_hba.conf cannot be modified via SQL.")
    print("    You MUST manually add this line on the server:")
    print()
    print(f"    host    {CLAIMANT_DB}     {CLAIMANT_USER}    {CLIENT_IP}/32        md5")
    print()
    print("    Location: /etc/postgresql/15/main/pg_hba.conf")
    print()
    print("    Command to add it (run on server as root/sudo):")
    print()
    print(f"    echo 'host    {CLAIMANT_DB}     {CLAIMANT_USER}    {CLIENT_IP}/32        md5' | sudo tee -a /etc/postgresql/15/main/pg_hba.conf")
    print("    sudo systemctl reload postgresql")
    print()
    print("=" * 60)
    print()
    
    print("[*] Alternatively, try connecting with these connection strings:")
    print()
    print("Option 1 (with SSL disabled):")
    print(f'  psql "host={HOST} port={PORT} dbname={CLAIMANT_DB} user={CLAIMANT_USER} sslmode=disable"')
    print()
    print("Option 2 (allow invalid SSL certificate):")
    print(f'  psql "host={HOST} port={PORT} dbname={CLAIMANT_DB} user={CLAIMANT_USER} sslmode=allow"')
    print()
    print("Option 3 (with environment variable):")
    print(f'  export PGPASSWORD="{CLAIMANT_PASSWORD}"')
    print(f'  psql -h {HOST} -p {PORT} -d {CLAIMANT_DB} -U {CLAIMANT_USER} -c "SELECT version();"')
    print()
    
    # Try a test connection with subprocess
    print("[*] Testing connection with sslmode=disable...")
    
    env = os.environ.copy()
    env['PGPASSWORD'] = CLAIMANT_PASSWORD
    
    psql_commands = [
        # Try different SSL modes
        [
            'psql', '-h', HOST, '-p', str(PORT), '-d', CLAIMANT_DB, 
            '-U', CLAIMANT_USER, '-c', 'SELECT version();', '-v', 'sslmode=disable'
        ],
        [
            'psql', '-h', HOST, '-p', str(PORT), '-d', CLAIMANT_DB, 
            '-U', CLAIMANT_USER, '-c', 'SELECT version();'
        ]
    ]
    
    for cmd in psql_commands:
        try:
            result = subprocess.run(
                cmd,
                env=env,
                capture_output=True,
                text=True,
                timeout=10
            )
            
            if result.returncode == 0:
                print("[+] Connection successful!")
                print(result.stdout)
                return True
            else:
                print(f"[!] Connection failed:")
                print(result.stderr if result.stderr else result.stdout)
        
        except FileNotFoundError:
            print("[!] psql command not found. Please install PostgreSQL client tools.")
            return False
        except subprocess.TimeoutExpired:
            print("[!] Connection timed out.")
        except Exception as e:
            print(f"[!] Error: {e}")
    
    return False

if __name__ == "__main__":
    try:
        main()
    except KeyboardInterrupt:
        print("\n[!] Interrupted by user")
        sys.exit(1)
    except Exception as e:
        print(f"[!] Unexpected error: {e}")
        sys.exit(1)
