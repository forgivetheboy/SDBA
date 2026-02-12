#test backups by restoring on other instance , doing checkdb dbcc and dropping the db ; pipe object to write data to a table in dev db of my choice lol!! db has to be existing befroehand 

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
