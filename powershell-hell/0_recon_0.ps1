<#
DONT EXECUTE ALL THESE COMMANDS AT ONCE. DONT EXECUTE A COMMAND YOURE NOT FAMILIAR WITH  DBATOOLS POWERSHELL
#>

Uninstall-Module dbatools -AllVersions -Force
#----------------------------------------------------------------------------------
#install and import sqlserver module for all users 
Install-Module dbatools -Scope AllUsers 
Install-Module SqlServer -Scope CurrentUser
Import-Module SqlServer

#bypass exec policy
Set-ExecutionPolicy -Scope Process Bypass
Set-DbatoolsConfig -FullName sql.connection.trustcert -Value $true

#import module and test commands
ipmo dbatools
Get-Command -Module dbatools | Measure-Object
Get-Command -Module dbatools | Select-Object -First 10
Get-Module -ListAvailable dbatools | Select-Object Name, Version, Path

#info about a command
Get-Command -module dbatools -name *logshipping*
help  Invoke-DbaDbLogShipping -showwindow

#Check Module
Get-Module  dbatools
(get-module dbatools).Version
#--------------------------------------------------------------------------------------------

#outline credentials 
$cred = Get-Credential
$instance = Connect-DbaInstance -SqlInstance SIMPODB -SqlCredential $cred -TrustServerCertificate
  Get-DbaLastBackup -SqlInstance $instance | Format-Table
Get-DbaDatabase -SqlInstance $instance | Format-Table

#--------------------------------------------------------------------------------------------
#INSTALL WHOISACTUVE ON INSTANCE
Install-DbaWhoIsActive -SqlInstance "SIMPODB"

#CHECK ACTIVE LOGINS ON INSTANCE
Get-DbaLogin -SqlInstance "SIMPODB"
Get-DbaProcess -SqlInstance "SIMPODBDEV"
#--------------------------------------------------------------------------------------------
#-------------------------------------------------------------------------------------------
#--------------------------------------------------------------------------------------------
#--------------------------------------------------------------------------------------------
#--------------------------------------------------------------------------------------------

Set-DbatoolsInsecureConnection -SessionOnly

#--------------------------------------------------------------------------------------------
Set-DbatoolsConfig -FullName sql.connection.trustcert -Value $true -Register
Set-DbatoolsConfig -FullName sql.connection.encrypt -Value $false -Register 
#--------------------------------------------------------------------------------------------

#check databases on instance
Get-DbaDatabase -SqlInstance SIMPODB       | Format-Table                

#check last backups 
Get-DbaLastBackup -SqlInstance SIMPODBDEV | Format-Table

#Run T-SQL query
Invoke-DbaQuery -SqlInstance SIMPODB -Query "SELECT @@VERSION" 

Invoke-DbaQuery `
-SqlInstance SIMPODBDEVURSB `
-Query  `
"SELECT COUNT(CollateralId) AS NumberOfCaveats FROM [SIMPODB].[dbo].[Caveats] WHERE CollateralId NOT BETWEEN 4000 AND 6000" 
          

# Export query results to CSV
Invoke-DbaQuery `
-SqlInstance SIMPODBDEVURSB `
-Database SIMPODB `
-Query "SELECT * FROM [SIMPODB].[dbo].[People]" `
            |  `
    Export-Csv -Path \\192.168.180.161\db_backups$\InstitutionParticipants.csv -NoTypeInformation

# Run a script file against all your servers (dont do it lol!)
#Get-Content C:\Scripts\CheckStatus.sql | Invoke-DbaQuery -SqlInstance (Get-Content C:\servers.txt)



#alter recovery model of a db or multiple dbs
Set-DbaDbRecoveryModel -SqlInstance SIMPODBDEVURSB -Database DWDiagnosticse -RecoveryModel Full

Set-DbaDbRecoveryModel -SqlInstance SIMPODBDEVURSB -Database "DWDiagnostics","DWQueue" -RecoveryModel Full <#full or simple or bulk logged#>

<#-----------------------------------------------------------------------------------------------#>
#get jobs on an instance and disable it 
Get-DbaAgentJob -SqlInstance chicco-pc |format-table

<#*_*#>  Disable-DbaAgentJob -SqlInstance "chicco-pc" -Job "SYSTEM_DATABASES - FULL"
<#-----------------------------------------------------------------------------------------------#>
#error log to table 
Get-DbaErrorLog -SqlInstance SIMPODB |
    Write-DbaDbTableData -SqlInstance "SIMPODBDEVURSB" -Database "TestLogsDB" -Schema "dbo" -Table "eRRORS" -AutoCreateTable



