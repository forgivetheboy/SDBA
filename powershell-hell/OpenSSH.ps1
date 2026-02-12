net start sshd
netsh advfirewall firewall add rule name="OpenSSH" dir=in action=allow protocol=TCP localport=22
netstat -an | find "22"
<#---------------------------------------------------------------------------------------------------#>
Add-WindowsCapability -Online -Name OpenSSH.Server~~~~0.0.1.0
Get-WindowsCapability -Online | Where-Object Name -like 'OpenSSH*'
<#---------------------------------------------------------------------------------------------------#>
Set-Service -Name sshd -StartupType 'Automatic'
Start-Service sshd
<#---------------------------------------------------------------------------------------------------#>
Get-Service -Name sshd