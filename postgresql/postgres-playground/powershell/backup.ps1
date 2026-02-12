Param(
  [switch]$Logical,
  [switch]$Physical,
  [string]$BackupDir = "./backups",
  [string]$PGHost = "localhost",
  [int]$PGPort = 5432,
  [string]$PGUser = "postgres",
  [string]$PGPassword = ""
)

if (!(Test-Path $BackupDir)) { New-Item -ItemType Directory -Path $BackupDir | Out-Null }
$timestamp = Get-Date -Format "yyyyMMdd_HHmmss"

if ($Logical) {
  Write-Host "Running logical backup..."
  $env:PGPASSWORD = $PGPassword
  & pg_dumpall -h $PGHost -p $PGPort -U $PGUser > "$BackupDir\pg_dumpall_$timestamp.sql"
}

if ($Physical) {
  Write-Host "Physical backup with pg_basebackup..."
  $env:PGPASSWORD = $PGPassword
  & pg_basebackup -h $PGHost -p $PGPort -U $PGUser -D "$BackupDir\basebackup_$timestamp" -P
}

Write-Host "Backup complete."
