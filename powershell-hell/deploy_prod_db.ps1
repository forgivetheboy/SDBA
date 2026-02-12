<#
=============================================================
   DEPLOY NEW SQL DATABASE (Full Production Script)
   Uses dbatools
=============================================================
#>

Import-Module dbatools

# ------------------------------
# CONFIGURATION (EDIT THESE)
# ------------------------------
$SqlInstance        = "SIMPODBDEVURSB"        # e.g. SIMPODBDEV
$DatabaseName       = "TestDB"
$DataPath           = "\\pdc1.ursb.local\Profiles\moses.chicco\Desktop\Senior DBA\instances\simpodbdevursb\ldf"
$LogPath            = "\\pdc1.ursb.local\Profiles\moses.chicco\Desktop\Senior DBA\instances\simpodbdevursb\mdf"
$Owner              = "saa"                     # or a domain login
$RecoveryModel      = "FULL"                   # FULL | SIMPLE | BULK_LOGGED
$PermissionLogin    = "$null"     # Set $null if not needed

# File settings
$DataFileSize       = 2048   # MB
$LogFileSize        = 1024   # MB
$DataGrowth         = 256    # MB
$LogGrowth          = 128    # MB


# ------------------------------
# 1. Ensure paths exist
# ------------------------------
foreach ($Path in @($DataPath, $LogPath)) {
    if (-not (Test-Path $Path)) {
        Write-Host "Creating folder: $Path" -ForegroundColor Yellow
        New-Item -ItemType Directory -Path $Path | Out-Null
    }
}

# ------------------------------
# 2. Check if DB already exists
# ------------------------------
$ExistingDb = Get-DbaDatabase -SqlInstance $SqlInstance -Database $DatabaseName -ErrorAction SilentlyContinue

if ($ExistingDb) {
    Write-Host "Database '$DatabaseName' already exists. Aborting." -ForegroundColor Red
    return
}

# ------------------------------
# 3. Create the new database
# ------------------------------
Write-Host "`nCreating database '$DatabaseName'..." -ForegroundColor Cyan

New-DbaDatabase -SqlInstance $SqlInstance -Name $DatabaseName `
    -DataFilePath $DataPath `
    -LogFilePath $LogPath `
    -PrimaryFileSize ($DataFileSize / 1MB) `      # size in MB
    -LogSize ($LogFileSize / 1MB) `               # size in MB
    -PrimaryFileGrowth ($DataGrowth * 1024) `     # growth in KB
    -LogGrowth ($LogGrowth * 1024) `              # growth in KB
    -Owner $Owner


Write-Host "Database created successfully ✔" -ForegroundColor Green

# ------------------------------
# 4. Set recovery model
# ------------------------------
Set-DbaDbRecoveryModel -SqlInstance $SqlInstance -Database $DatabaseName -RecoveryModel $RecoveryModel
Write-Host "Recovery model set to $RecoveryModel ✔" -ForegroundColor Green

# ------------------------------
# 5. Assign permissions (optional)
# ------------------------------
if ($PermissionLogin) {
    Write-Host "Applying READ/WRITE permissions for $PermissionLogin..." -ForegroundColor Yellow

    # Ensure login exists
    if (-not (Get-DbaLogin -SqlInstance $SqlInstance -Login $PermissionLogin -ErrorAction SilentlyContinue)) {
        Write-Host "Login $PermissionLogin does not exist on the instance. Creating it..." -ForegroundColor Yellow
        New-DbaLogin -SqlInstance $SqlInstance -Login $PermissionLogin -Password (Read-Host -AsSecureString "Enter Password")
    }

    # Grant database rights
    Invoke-DbaQuery -SqlInstance $SqlInstance -Database $DatabaseName -Query "
        CREATE USER [$PermissionLogin] FOR LOGIN [$PermissionLogin];
        ALTER ROLE db_datareader ADD MEMBER [$PermissionLogin];
        ALTER ROLE db_datawriter ADD MEMBER [$PermissionLogin];
    "

    Write-Host "Permissions applied ✔" -ForegroundColor Green
}

# ------------------------------
# 6. Verification output
# ------------------------------
Write-Host "`n=== DATABASE DETAILS ===" -ForegroundColor Cyan
Get-DbaDatabase -SqlInstance $SqlInstance -Database $DatabaseName | 
    Select Name, RecoveryModel, SizeMB, Status | Format-Table

Write-Host "`nDatabase deployment complete 🎉" -ForegroundColor Green
