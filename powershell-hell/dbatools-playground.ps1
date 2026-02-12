<#
dbatools-playground.ps1
A quick interactive playground for dbatools demonstrating discovery, backups, copy/restore, login/job sync, and an example AlwaysOn AG setup flow.

Prereqs:
 - Run PowerShell as Administrator
 - Install dbatools: Install-Module dbatools -Scope CurrentUser -AllowClobber
 - Ensure Windows Failover Clustering & AlwaysOn are configured on the instances if you intend to actually create AGs

Usage: dot-source the file to import functions and run sections interactively:
. .\dbatools-playground.ps1

Author: GitHub Copilot (Raptor mini (Preview))
#>

# ---------------------------
# Config
# ---------------------------
$Primary = 'CHICCO-PC'
$Secondary = 'CHICCO-PC2'
$AGName = 'PlaygroundAG'
$ListenerName = 'PlaygroundAGListener'
$AGDatabases = @('PlaygroundDB')  # replace with DBs you want in the AG
$BackupPath = 'C:\Temp\Backups'  # adjust as needed

# ---------------------------
# Helpers
# ---------------------------
function Ensure-Dbatools {
    if (-not (Get-Module -ListAvailable -Name dbatools)) {
        Write-Warning "dbatools not found in this session. Installing to CurrentUser (requires internet)."
        Install-Module dbatools -Scope CurrentUser -Force -AllowClobber
    }
    Import-Module dbatools -Force
}

function Confirm-Action([string]$Message = 'Proceed?') {
    $r = Read-Host "$Message ([Y]es/[N]o)"
    return $r -match '^(y|Y|yes|Yes)$'
}

# Safe dry-run wrapper for potentially destructive operations
function Run-Safe([ScriptBlock]$Script, [string]$Prompt="Run this action") {
    Write-Host "\n--- ACTION PREVIEW ---" -ForegroundColor Yellow
    & $Script -WhatIf:$false 2>&1 | Out-Default
    if (Confirm-Action "$Prompt") {
        & $Script
    } else {
        Write-Host 'Skipped.' -ForegroundColor Cyan
    }
}

# ---------------------------
# 1) Discovery / Get commands
# ---------------------------
function Playground-Discovery {
    Ensure-Dbatools
    Write-Host "\n-> Instances" -ForegroundColor Green
    Get-DbaInstance -SqlInstance $Primary, $Secondary | Select ComputerName, Version, EngineEdition, Product

    Write-Host "\n-> Databases on Primary (summary)" -ForegroundColor Green
    Get-DbaDatabase -SqlInstance $Primary | Select Name, RecoveryModel, Status, Owner, LastBackupDate | Format-Table -AutoSize

    Write-Host "\n-> Availability Groups (if any)" -ForegroundColor Green
    Get-DbaAvailabilityGroup -SqlInstance $Primary -ErrorAction SilentlyContinue | Format-Table -AutoSize

    Write-Host "\n-> Backup history (recent)" -ForegroundColor Green
    Get-DbaBackupHistory -SqlInstance $Primary | Sort-Object BackupFinishDate -Descending | Select -First 10 | Format-Table -AutoSize

    Write-Host "\n-> Logins & Agent Jobs" -ForegroundColor Green
    Get-DbaLogin -SqlInstance $Primary | Select Name, LoginType
    Get-DbaAgentJob -SqlInstance $Primary | Select Name, Enabled
}

# ---------------------------
# 2) Backup -> Copy -> Restore flow (safe, interactive)
# ---------------------------
function Playground-BackupCopyRestore {
    Ensure-Dbatools

    $db = $AGDatabases[0]
    if (-not $db) { Write-Warning 'No database configured in $AGDatabases. Update the array and retry.'; return }

    Write-Host "\nBacking up $db on $Primary to $BackupPath" -ForegroundColor Green
    $backupCmd = { Backup-DbaDatabase -SqlInstance $Primary -Database $db -Type Full -Compress -Path $BackupPath -KeepFull -Confirm:$false }
    Run-Safe $backupCmd "Create backup of $db?"

    Write-Host "\nCopying backup to $Secondary and restoring (as standby/single user for join)" -ForegroundColor Green
    $copyCmd = { Copy-DbaDatabase -Source $Primary -Destination $Secondary -Database $db -BackupRestore -CompressBackup -NetworkSharePath $BackupPath -Force }
    Run-Safe $copyCmd "Copy and restore $db to secondary?"

    Write-Host "\nVerify database present on destination" -ForegroundColor Green
    Get-DbaDatabase -SqlInstance $Secondary -Database $db | Select Name, Status, RecoveryModel
}

# ---------------------------
# 3) Sync logins & jobs
# ---------------------------
function Playground-SyncLoginsAndJobs {
    Ensure-Dbatools

    Write-Host "\nSyncing logins from $Primary -> $Secondary" -ForegroundColor Green
    $syncLogins = { Sync-DbaLogin -Source $Primary -Destination $Secondary -Force }
    Run-Safe $syncLogins "Sync logins?"

    Write-Host "\nCopying SQL Agent jobs" -ForegroundColor Green
    $copyJobs = { Copy-DbaAgentJob -Source $Primary -Destination $Secondary -IncludeStepOutput -Force }
    Run-Safe $copyJobs "Copy Agent jobs?"
}

# ---------------------------
# 4) Availability Group (example flow)
# ---------------------------
function Playground-AvailabilityGroup {
    Ensure-Dbatools

    Write-Host "\nAvailability Group helper flow (example)." -ForegroundColor Green
    Write-Host "NOTE: Creating an AG requires that Windows Failover Cluster is configured and SQL Server AlwaysOn is enabled on instances." -ForegroundColor Yellow

    # 4a) Check prerequisites
    Write-Host "\nChecking AlwaysOn and cluster prerequisites" -ForegroundColor Green
    Test-DbaAvailabilityGroup -SqlInstance $Primary -ErrorAction SilentlyContinue

    # 4b) Optional: prepare DBs (they should be restored as NORECOVERY on secondary)
    Write-Host "\nMake sure DBs are full backed up and restored on secondary (NORECOVERY). Use Playground-BackupCopyRestore for help." -ForegroundColor Cyan

    # 4c) Attempt to create AG using dbatools if available
    if (Get-Command New-DbaAg -ErrorAction SilentlyContinue) {
        Write-Host "\nCreating Availability Group using New-DbaAg (dbatools)" -ForegroundColor Green
        $createAG = { New-DbaAg -SqlInstance $Primary -Name $AGName -Database $AGDatabases -Replica $Secondary -Force }
        Run-Safe $createAG "Create AG $AGName with replicas $Primary/$Secondary?"
    }
    else {
        Write-Warning "New-DbaAg command not found in this dbatools version on this machine. Install/update dbatools or create the AG via SSMS/T-SQL." 
        Write-Host "Sample T-SQL (simplified):" -ForegroundColor Cyan
        Write-Host "-- CREATE AVAILABILITY GROUP [$AGName] ...; -- JOIN on secondary with ALTER AVAILABILITY GROUP ... ADD DATABASE ..." -ForegroundColor DarkCyan
    }

    Write-Host "\nOptional: Create Listener (requires a cluster IP)." -ForegroundColor Green
    if (Get-Command New-DbaAgListener -ErrorAction SilentlyContinue) {
        Write-Host "New-DbaAgListener is available. You will need to supply a valid IP for your listener; replace the sample below." -ForegroundColor Cyan
        Write-Host "# Example (DO NOT RUN without valid IP): New-DbaAgListener -Name $ListenerName -StaticIp '10.0.0.100/24' -SqlInstance $Primary -AvailabilityGroup $AGName" -ForegroundColor DarkCyan
    }
}

# ---------------------------
# 5) Misc "cool stuff" (diagnostics, checks, maintenance)
# ---------------------------
function Playground-CoolStuff {
    Ensure-Dbatools

    Write-Host "\n-> Diagnostic queries" -ForegroundColor Green
    Invoke-DbaDiagnosticQuery -SqlInstance $Primary | Select Time, Database, Message -First 10

    Write-Host "\n-> Check last backup for all DBs" -ForegroundColor Green
    Test-DbaLastBackup -SqlInstance $Primary | Format-Table -AutoSize

    Write-Host "\n-> Quick perf counters" -ForegroundColor Green
    Get-DbaCpu -SqlInstance $Primary | Select AverageCpu

    Write-Host "\n-> Check AG replica state" -ForegroundColor Green
    Get-DbaAgReplica -SqlInstance $Primary -ErrorAction SilentlyContinue | Format-Table -AutoSize
}

# ---------------------------
# Export: convenience wrapper to run all discovery steps
# ---------------------------
function Playground-All {
    Playground-Discovery
    Playground-CoolStuff
}

# ---------------------------
# 6) Step-by-step Availability Group creator (interactive)
# ---------------------------
function Playground-CreateAvailabilityGroup {
    Ensure-Dbatools

    Write-Host "\nPlayground: Create Availability Group '$AGName' with replica $Secondary" -ForegroundColor Green

    # Step 1: prerequisites
    Write-Host "\n1) Checking AlwaysOn / cluster prerequisites" -ForegroundColor Green
    $prereq = Test-DbaAvailabilityGroup -SqlInstance $Primary -ErrorAction SilentlyContinue
    if (-not $prereq) {
        Write-Warning "Prerequisite checks returned no result or failed. Ensure that Windows Failover Clustering and AlwaysOn availability groups are configured and the SQL services are running on both instances."
        if (-not (Confirm-Action "Continue despite failed prereq checks?")) { Write-Host 'Aborting.'; return }
    }

    # Step 2: verify DBs exist and are in FULL recovery
    Write-Host "\n2) Verifying databases exist and use FULL recovery" -ForegroundColor Green
    foreach ($db in $AGDatabases) {
        Write-Host "Checking $db on $Primary" -ForegroundColor Cyan
        $dbInfo = Get-DbaDatabase -SqlInstance $Primary -Database $db -ErrorAction SilentlyContinue
        if (-not $dbInfo) { Write-Warning "Database $db not found on $Primary. Aborting."; return }
        if ($dbInfo.RecoveryModel -ne 'Full') {
            Write-Warning "$db is not in FULL recovery model (current: $($dbInfo.RecoveryModel))."
            if (Confirm-Action "Set $db to FULL recovery model on $Primary now?") {
                Set-DbaDbRecoveryModel -SqlInstance $Primary -Databases $db -RecoveryModel Full -Confirm:$false
            } else { Write-Warning "Database must be FULL for AG. Aborting."; return }
        }
    }

    # Step 3: Backup, copy and restore as NORECOVERY on secondary
    Write-Host "\n3) Backing up databases, copying, and restoring on $Secondary (NORECOVERY)" -ForegroundColor Green
    foreach ($db in $AGDatabases) {
        Write-Host "\nPreparing $db" -ForegroundColor Cyan
        $backupFull = { Backup-DbaDatabase -SqlInstance $Primary -Database $db -Type Full -Compress -Path $BackupPath -Force -Confirm:$false }
        Run-Safe $backupFull "Create full backup of $db on $Primary?"

        $backupLog = { Backup-DbaDatabase -SqlInstance $Primary -Database $db -Type Log -Compress -Path $BackupPath -Force -Confirm:$false }
        Run-Safe $backupLog "Create log backup of $db on $Primary?"

        if (Get-Command Copy-DbaDatabase -ErrorAction SilentlyContinue) {
            $copyRestore = { Copy-DbaDatabase -Source $Primary -Destination $Secondary -Database $db -BackupRestore -CompressBackup -NetworkSharePath $BackupPath -Force }
            Run-Safe $copyRestore "Copy and restore $db to $Secondary (NORECOVERY)?"
        } else {
            Write-Warning "Copy-DbaDatabase not available. You must copy the backups to $Secondary and run Restore-DbaDatabase with -NoRecovery manually."; return
        }

        # verify restore state
        $destDb = Get-DbaDatabase -SqlInstance $Secondary -Database $db -ErrorAction SilentlyContinue
        if ($destDb.Status -notin @('Restoring', 'Standby')) {
            Write-Warning "$db on $Secondary is not in Restoring/Standby state. Ensure it was restored with NORECOVERY." 
            if (-not (Confirm-Action "Proceed anyway?")) { Write-Host 'Aborting.'; return }
        }
    }

    # Step 4: Create the Availability Group
    Write-Host "\n4) Creating Availability Group on $Primary" -ForegroundColor Green
    if (Get-Command New-DbaAg -ErrorAction SilentlyContinue) {
        $createAG = { New-DbaAg -SqlInstance $Primary -Name $AGName -Database $AGDatabases -Replica $Secondary -Force }
        Run-Safe $createAG "Create Availability Group $AGName with replicas $Primary/$Secondary?"
    } else { Write-Warning "New-DbaAg not found in this dbatools version. Create the AG with SSMS or T-SQL and then use the helper functions here to validate."; return }

    # Step 5: Verify AG
    Start-Sleep -Seconds 5
    Write-Host "\n5) Verifying AG & replicas" -ForegroundColor Green
    Get-DbaAvailabilityGroup -SqlInstance $Primary -Name $AGName | Format-List *
    Get-DbaAgReplica -SqlInstance $Primary -AvailabilityGroup $AGName | Format-Table -AutoSize

    # Step 6: Listener (optional)
    Write-Host "\n6) Optional: Create AG Listener (requires cluster network config & IP)" -ForegroundColor Green
    if (Get-Command New-DbaAgListener -ErrorAction SilentlyContinue) {
        if (Confirm-Action "Create AG Listener $ListenerName now?") {
            $ip = Read-Host "Enter static IP (IP/SubnetMask or CIDR, e.g., 10.0.0.100/24). Press Enter to skip"
            if ($ip) {
                $listenerCmd = { New-DbaAgListener -Name $ListenerName -StaticIp $ip -SqlInstance $Primary -AvailabilityGroup $AGName }
                Run-Safe $listenerCmd "Create Listener $ListenerName with IP $ip?"
            } else { Write-Host "Skipping listener creation." }
        }
    } else { Write-Warning "New-DbaAgListener not available in this dbatools version." }

    Write-Host "\nAG creation flow complete. Use Get-DbaAvailabilityGroup/Get-DbaAgReplica to inspect state and Test-DbaAvailabilityGroup for checks." -ForegroundColor Magenta
}

Write-Host "dbatools playground loaded. Use functions: Playground-Discovery, Playground-BackupCopyRestore, Playground-SyncLoginsAndJobs, Playground-AvailabilityGroup, Playground-CreateAvailabilityGroup, Playground-CoolStuff, Playground-All" -ForegroundColor Magenta

# EOF
