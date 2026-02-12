#clone db
Copy-DbaDatabase `
    -SourceSqlInstance "SIMPODBDEVURSB" `
    -SourceDatabase "TestLogsDB" `
    -DestinationSqlInstance "SIMPODBDEVURSB" `
    -DestinationDatabase "SeniorDBA" `
    -DataFilePath "F:\Data" `
    -LogFilePath  "F:\Logs"
    #-CompressBackup


#clone server but exclusive of sys dbs and SSL certs etc!!!!!!! run on destination server to avoid conflict of file system access, with force
Start-DbaMigration `
    -Source "SIMPODEVURSB" `
    -Destination "SeniorDBA" `
#   -Exclude "DatabaseMailAccounts", "DataCollector" `
    -IncludeLogins `
    -IncludeSqlAgentJobs `
    -IncludeLinkedServers `
    -IncludeCredentials `
    -IncludeDatabaseMail `
    -IncludePolicyManagement `
    -IncludeSqlServerAgent `
    -IncludeEndpoints `
    -IncludeBackupDevices `
    -ReuseSourceFolderStructure `
    -Force


