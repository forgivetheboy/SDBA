Stop-Service ClusSvc -Force


Clear-ClusterNode -Force


Uninstall-WindowsFeature Failover-Clustering -Restart


Install-WindowsFeature Failover-Clustering -IncludeManagementTools


Test-Cluster -Node DBMNG01


Add-ClusterNode -Name DBMNG01

