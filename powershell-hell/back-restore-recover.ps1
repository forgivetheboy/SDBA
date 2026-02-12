#--------------------------------------------------------------------------------------------
Set-DbatoolsInsecureConnection -SessionOnly
#bypass exec policy
Set-ExecutionPolicy -Scope Process Bypass
#--------------------------------------------------------------------------------------------

<#  
   To change dir for ldf and mdf of secondary instance or db    
(hahaha! this is T-SQL so dont run it in Powershell, unless with invoke-query)       
 #>
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
#--------------------------------------------------------------------------------------------
#backup db
Backup-DbaDatabase -SqlInstance SIMPODBDEV -Database SIMPODB -Path \\192.168.180.161\db_backups$\SIMPODEVDB\SIMPODBDEV\SIMPODB\FULL -Type Full -ReplaceInName

#test backups by restoring on other instance , doing checkdb dbcc and dropping the db ; pipe object to write data to a table in dev db of my choice lol!!
Test-DbaLastBackup `
-SqlInstance SIMPODB `
-Destination SIMPODBDEVURSB `
-Prefix "TestRestore_" `
-ExcludeDatabase model, master, msdb `
       | `
            Write-DbaDbTableData `
                 -SqlInstance "SIMPODBDEVURSB" `
                     -Database "Tests" `
                        -Schema "dbo" `
                             -Table "TestRestores" `
                                 -AutoCreateTable

#restore from path 
Restore-DbaDatabase -SqlInstance CHICCO-PC -Path \\chicco-pc\y

#test path access of sqlserver account
Test-DbaPath -SqlInstance CHICCO-PC -Path 'C:\Program Files\Microsoft SQL Server\MSSQL15.MSSQLSERVER\MSSQL\Backup'

#restore db through ola hallengren
Restore-DbaDatabase -SqlInstance SIMPODBDEVURSB -Path \\192.168.180.161\db_backups$ -DestinationDataDirectory c:\restores -MaintenanceSolutionBackup

Restore-DbaDatabase -SqlInstance SIMPODB2 `
-DatabaseName SIMPRSDB `
-Path "\\192.168.180.161\db_backups$\SIMPRSDB_202601271835.bak" `
-NoRecovery `
-WithReplace `
-DestinationDataDirectory "D:\DBData" `
-DestinationLogDirectory "E:\DBLogs"

#restore db through ola hallengren to a point in time
$RestoreTime = Get-Date '2026-01-27T19:45:00'
Restore-DbaDatabase `
    -SqlInstance SIMPODB2 `
    -Path '\\192.168.180.161\DB_BACKUPS$\SIMPODB\simpo-test-cluster$simpo-ag' `
    -MaintenanceSolutionBackup `
   # -DestinationDataDirectory 'C:\Restores' `
    -RestoreTime $RestoreTime

#--------------------------------------------------------------------------------------------

#Skips the DBCC CHECKDB check. This can help speed up the tests but makes it less tested. The test restores will remain on the server.
Test-DbaLastBackup `
-SqlInstance sql2016 `
-Destination SIMPODBDEVURSB `
-ExcludeDatabase model, master, msdb `
-NoCheck -NoDrop
    
