#LOG SHIPPING BUT DONT EXECUTE ANY PART OF THIS SCRIPT IF YOU DONT KNOW WHAT YOURE DOING ???
#-------------------------------------------------------------------------------------------------------------------------------------------------------

#lets first change dir for ldf and mdf of secondary instance or db 
<#        (hahaha! this is T-SQL so dont run it in Powershell)        #>
EXEC xp_instance_regwrite
    N'HKEY_LOCAL_MACHINE',
    N'SOFTWARE\Microsoft\MSSQLServer\MSSQLServer',
    N'DefaultData',
    REG_SZ,
    'F:\LS\Restore';

EXEC xp_instance_regwrite
    N'HKEY_LOCAL_MACHINE',
    N'SOFTWARE\Microsoft\MSSQLServer\MSSQLServer',
    N'DefaultLog',
    REG_SZ,
    'F:\LS\Restore';


#-------------------------------------------------------------------------------------------------------------------------------------------
#FIRST TEST LOGSHIP STATUS (HAHAHAHAHA)
Test-DbaDbLogShipStatus -SqlInstance SIMPODBDEV | Format-Table

Get-DbaDbLogShipError -SqlInstance SIMPODB

Remove-DbaDbLogShipping -PrimarySqlInstance SIMPODBDEV -Database zzz #remove all remnants if any

#this is a more lengthy LS but efficient. IF IT FAILES FIRST TIME, REVIEW AND EXECUTE AGAIN 
#------------------------------------------------------------------------------------------------------------------
$params = @{
    SourceSqlInstance                      = 'SIMPODBDEV'
    DestinationSqlInstance                 = 'SIMPODB'
    Database                               = 'zzz'
    SharedPath                             = '\\192.168.180.161\db_backups$\HA-DR\Logshipping'

    BackupScheduleFrequencyType            = 'daily'
    BackupScheduleFrequencyInterval        = 1
    BackupScheduleFrequencySubDayType      = 'minutes'
    BackupScheduleFrequencySubDayInterval  = 10
    CompressBackup                         = $true

    CopyScheduleFrequencyType              = 'daily'
    CopyScheduleFrequencyInterval          = 1
    CopyScheduleFrequencySubDayType        = 'minutes'
    CopyScheduleFrequencySubDayInterval    = 10


    RestoreScheduleFrequencyType           = 'daily'
    RestoreScheduleFrequencyInterval       = 1
    RestoreScheduleFrequencySubDayType     = 'minutes'
    RestoreScheduleFrequencySubDayInterval = 10

    CopyDestinationFolder                  = 'F:\LS' #create dir on secondary prior
    GenerateFullBackup                     = $true
    Force                                  = $true
}

Invoke-DbaDbLogShipping @params

#------------------------------------------------------------------------------------------------------------------
#------------------------------------------------------------------------------------------------------------------
#------------------------------------------------------------------------------------------------------------------
#------------------------------------------------------------------------------------------------------------------

# --- Email list for alerts ---
# $alertEmails = 'alerts@yourdomain.com; dba_team@yourdomain.com; moses.chicco@ursb.go.ug'   >>> multiple mails
  $alertEmails = 'moses.chicco@ursb.go.ug'
# --- CREATE OPERATOR ON PRIMARY ---
New-DbaAgentOperator -SqlInstance 'SIMPODBDEVURSB' `
    -Name 'LS_Alerts_Operator' `
    -EmailAddress $alertEmails `
    -ErrorAction SilentlyContinue

# --- CREATE ALERT ON PRIMARY (BACKUP FAILURE) ---
New-DbaAgentAlert -SqlInstance 'SIMPODBDEVURSB' `
    -Name 'LS Backup Not happening within threshold' `
    -MessageId 14420 `
    -Severity 0 `
    -Operator 'LS_Alerts_Operator' `
    -NotificationMethod Email `
    -ErrorAction SilentlyContinue


# --- CREATE OPERATOR ON SECONDARY ---
New-DbaAgentOperator -SqlInstance 'SIMPODBDEV' `
    -Name 'LS_Alerts_Operator' `
    -EmailAddress $alertEmails `
    -ErrorAction SilentlyContinue

# --- CREATE ALERT ON SECONDARY (RESTORE FAILURE) ---
New-DbaAgentAlert -SqlInstance 'SIMPODBDEVSIMPODBDEVURSB' `
    -Name 'LS Restore Not happening within threshold' `
    -MessageId 14421 `
    -Severity 0 `
    -Operator 'LS_Alerts_Operator' `
    -NotificationMethod Email `
    -ErrorAction SilentlyContinue


#------------------------------------------------------------------------------------------

#LS Failoverrrrrrrrrr

#------------------------------------------------------------------------------------------

# --- VARIABLES ---
$primary = 'SIMPODBDEVURSB'
$secondary = 'SIMPODBDEV'
$db = 'TestLogsDB'

# --- CHECK LS STATUS FIRST (optional but wise) ---
Get-DbaDbLogShippingMonitor -SqlInstance $primary -Database $db | Format-Table

# --- PERFORM MANUAL FAILOVER ---
Invoke-DbaDbLogShippingFailover `
    -PrimarySqlInstance $primary `
    -SecondarySqlInstance $secondary `
    -Database $db `
    -Force `
    -Verbose

# --- CONFIRM THE SECONDARY IS NOW ONLINE ---
Get-DbaDatabase -SqlInstance $secondary -Database $db | Select Name, Status



#------------------------------------------------------------------------------------------

#After LS failover, restore model and msdb, first put the SQL Server into SINGLE_USER mode either through GUI or 
#------------------------------------------------------------------------------------------
# --- VARIABLES ---
$secondaryInstance = 'SIMPODBDEVURSB'   # the new primary after LS failover
$backupPath        = '\\192.168.180.161\db_backups$'  # path where system DB backups exist

# --- Step 1: Put SQL Server into SINGLE_USER mode ---
Write-Host "Restarting SQL Server in SINGLE_USER mode..."
Stop-Service -Name "MSSQLSERVER" -Force
Start-Process -FilePath "sqlservr.exe" -ArgumentList "-m" -NoNewWindow -Wait

# --- Step 2: Restore msdb ---
Write-Host "Restoring msdb..."
Restore-DbaDatabase -SqlInstance $secondaryInstance `
    -Database 'msdb' `
    -Path "\\192.168.180.161\db_backups$\xxxxxxx\msdb.bak" `  #point to dir
    -ReplaceDatabase `
    -Verbose

# --- Step 3: Restore model ---
Write-Host "Restoring model..."
Restore-DbaDatabase -SqlInstance $secondaryInstance `
    -Database 'model' `
    -Path "\\192.168.180.161\db_backups$\xxxxxxx\model.bak" `     #point to dir
    -ReplaceDatabase `
    -Verbose

# --- Step 4: Restart SQL Server normally ---
Write-Host "Restarting SQL Server normally..."
Stop-Process -Name sqlservr -Force  # stops the single-user instance
Start-Service -Name "MSSQLSERVER"


# --- Step 5: Verify ---
#$secondaryInstance = 'SIMPODBDEVURSB'
Get-DbaDatabase -SqlInstance $secondaryInstance -Database 'msdb','model' | Select Name, Status

