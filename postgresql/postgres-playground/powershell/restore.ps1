Param(
  [switch]$Logical,
  [switch]$PgRestore,
  [string]$File,
  [string]$PGHost = "localhost",
  [int]$PGPort = 5432,
  [string]$PGUser = "postgres",
  [string]$PGPassword = ""
)

if ($Logical -and $File) {
  $env:PGPASSWORD = $PGPassword
  Write-Host "Restoring SQL file $File"
  & psql -h $PGHost -p $PGPort -U $PGUser -f $File
}
elseif ($PgRestore -and $File) {
  $env:PGPASSWORD = $PGPassword
  Write-Host "Restoring custom dump $File"
  & pg_restore -h $PGHost -p $PGPort -U $PGUser -d postgres -c $File
}
else {
  Write-Host "Use -Logical -File <sql> or -PgRestore -File <dump>"
}
