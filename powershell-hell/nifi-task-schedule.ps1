$taskName = "NiFi-Startup"
$nifiPath = "C:\Tools\nifi-2.7.2\bin\nifi.bat"
$action = New-ScheduledTaskAction -Execute $nifiPath -Argument "start"
$trigger = New-ScheduledTaskTrigger -AtStartup
$principal = New-ScheduledTaskPrincipal -UserID "SYSTEM" -LogonType ServiceAccount -RunLevel Highest

Register-ScheduledTask -TaskName $taskName -Action $action -Trigger $trigger -Principal $principal -Description "Start NiFi at system startup"

# Verify it was created
Get-ScheduledTask -TaskName $taskName

#check 
Start-ScheduledTask -TaskName "NiFi-Startup"