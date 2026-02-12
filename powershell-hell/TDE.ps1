

$masterkeypass = (Get-Credential 3212@sdba).Password 
$certbackuppass = (Get-Credential 3212@sdba).Password
$TDE = @{
SqlInstance                   = "DESKTOP-BTV6FJV" 
Database                      = "Random300MB"
#AllUserDatabases             = $true
MasterKeySecurePassword      = $masterkeypass
BackupSecurePassword         = $certbackuppass
BackupPath                   = "C:\keys"
#Parallel                     = $true , ---use if enabling on multiple databases to improve performance
}
Get-DbaDatabase -SqlInstance DESKTOP-BTV6FJV -Database Random300MB| Start-DbaDbEncryption @TDE


Get-DbaDbEncryptionKey -SqlInstance DESKTOP-BTV6FJV -Database Random300MB | out-gridview
#or check sys.certificates at master db
Get-DbaDbCertificate -sqlinstance desktop-btv6f | out-gridview

Enable-DbaDbEncryption -SqlInstance chicco-pc -Database Random500MB -Confirm:$True
Disable-DbaDbEncryption -SqlInstance DESKTOP-BTV6FJV -Database Random500MB -Confirm:$True

#--------------------------------------------------------------------
#TDE based cross server restore 
#--------------------------------------------------------------------

# SQL & Database
$SqlInstance = "NEWSQLSERVER"
$Database    = "MyTdeDb"

# Backup locations
$BackupRoot  = "\\192.168.180.161\db_backups$\MyTdeDb"
$CertPath    = "\\192.168.180.161\db_backups$\Certs"

# Data locations
$DataDir = "D:\SQLData"
$LogDir  = "E:\SQLLogs"


$CertPassword = Read-Host "Enter TDE certificate private key password" -AsSecureString
$DmkPassword  = Read-Host "Enter MASTER KEY password for NEW server" -AsSecureString


Write-Host "=== TDE Cross-Server Restore Started ===" -ForegroundColor Cyan

# 1️⃣ Ensure MASTER KEY exists in master DB
if (-not (Get-DbaDbMasterKey -SqlInstance $SqlInstance -Database master -ErrorAction SilentlyContinue)) {

    Write-Host "Creating MASTER KEY in master database..." -ForegroundColor Yellow

    $PlainDmk = ConvertFrom-SecureString $DmkPassword -AsPlainText

    Invoke-DbaQuery -SqlInstance $SqlInstance -Query "
        USE master;
        CREATE MASTER KEY
        ENCRYPTION BY PASSWORD = '$PlainDmk';
        ALTER MASTER KEY
        ADD ENCRYPTION BY SERVICE MASTER KEY;
    "
}
else {
    Write-Host "MASTER KEY already exists." -ForegroundColor Green
}

# 2️⃣ Restore TDE Certificate
Write-Host "Restoring TDE certificate..." -ForegroundColor Yellow

Restore-DbaDbCertificate `
  -SqlInstance $SqlInstance `
  -Path $CertPath `
  -DecryptionPassword $CertPassword `
  -EnableException

# 3️⃣ Restore FULL backup (NORECOVERY)
Write-Host "Restoring FULL backup..." -ForegroundColor Yellow

Restore-DbaDatabase `
  -SqlInstance $SqlInstance `
  -DatabaseName $Database `
  -Path "$BackupRoot\FULL" `
  -DestinationDataDirectory $DataDir `
  -DestinationLogDirectory  $LogDir `
  -NoRecovery `
  -ReplaceDb `
  -EnableException

# 4️⃣ Restore DIFF (if exists)
if (Test-Path "$BackupRoot\DIFF") {

    Write-Host "Restoring DIFF backup..." -ForegroundColor Yellow

    Restore-DbaDatabase `
      -SqlInstance $SqlInstance `
      -DatabaseName $Database `
      -Path "$BackupRoot\DIFF" `
      -NoRecovery `
      -EnableException
}

# 5️⃣ Restore LOG backups (if exist)
if (Test-Path "$BackupRoot\LOG") {

    Write-Host "Restoring LOG backups..." -ForegroundColor Yellow

    Restore-DbaDatabase `
      -SqlInstance $SqlInstance `
      -DatabaseName $Database `
      -Path "$BackupRoot\LOG" `
      -NoRecovery `
      -EnableException
}

# 6️⃣ Recover database
Write-Host "Recovering database..." -ForegroundColor Yellow

Restore-DbaDatabase `
  -SqlInstance $SqlInstance `
  -DatabaseName $Database `
  -Recover `
  -EnableException

# 7️⃣ Validation
Write-Host "Validating restore..." -ForegroundColor Cyan

Get-DbaDbState -SqlInstance $SqlInstance -Database $Database
Test-DbaDbCertificate -SqlInstance $SqlInstance

Write-Host "=== TDE Cross-Server Restore Completed Successfully ===" -ForegroundColor Green

