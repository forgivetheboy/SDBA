<#-------------------------------------------------------------------------------------------------------------
-all this wont come to fruition if wsfc and wintess isn't configured well, permissions in AD, DNS granted well.
-if seeding is to be manual, hahahahaha! make sure to provide sharedpath
-in SSMS , after setting the AG and listener, alter Readable Secondary from "No" , to enable readability
-always check web.config;
#-------------------------------------------------------------------------------------------------------------#>


Set-DbatoolsInsecureConnection -SessionOnly

# Create Availability Group
New-DbaAvailabilityGroup `
    -Primary            SIMPODB `
    -Secondary          SIMPODB2 `
    -Name               simpo-ag-prod `
    -Database           SIMPRSDB `
    -ClusterType        WSFC `
    -AvailabilityMode   SynchronousCommit `
    -SeedingMode        Automatic `
    -FailoverMode       Automatic `
    #-SharedPath         '\\192.168.180.161\db_backups$\HA-DR\Always On Availability Groups' `
    -EndpointUrl        'TCP://SIMPODB.URSB.LOCAL:5022',
                        'TCP://SIMPODB2.URSB.LOCAL:5022'
#-----------------------------------------------------------------------------------

#create listener, here the subnet mask will be configured automatically 
Add-DbaAgListener `
-Name                   simpo-lis `
-SqlInstance            SIMPODBDEV `
-AvailabilityGroup      ag-simpo  `
-IPAddress              '192.168.3.108','192.168.180.157'
#-----------------------------------------------------------------------------------


#-----------------------------------------------------------------------------------
#to tweak the listener endpoint port from the default
#Set-DbaAgListener -SqlInstance XXXXX -AvailabilityGroup XXX-AG -Port 14333
#-----------------------------------------------------------------------------------
#simple AG checks
Get-Cluster
Get-ClusterNode
#-----------------------------------------------------------------------------------

Sync-DbaAvailabilityGroup -Primary xxxxx -AvailabilityGroup ag-name
<#
Syncs the following on all replicas found in the db3 AG:
SpConfigure, CustomErrors, Credentials, DatabaseMail, LinkedServers
Logins, LoginPermissions, SystemTriggers, DatabaseOwner, AgentCategory,
AgentOperator, AgentAlert, AgentProxy, AgentSchedule, AgentJob
#>

#-----------------------------------------------------------------------------------

