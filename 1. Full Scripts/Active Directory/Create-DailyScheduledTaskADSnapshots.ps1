##########################################
# AUTHOR   : Ryan Mutschler
# DATE     : 3-14-2025
# EDIT     : 3-14-2025
# PURPOSE  : This script creates a daily scheduled task to take AD snapshots on a domain controller
#
# VERSION  : 1    (Initial release)
##########################################

#region Check if System is DC and logged-on user is admin

$DomainRole = Get-WmiObject -Class Win32_ComputerSystem | Select-Object -ExpandProperty DomainRole

if( $DomainRole -match '4|5' )
#0=StandaloneWorkstation, 1=MemberWorkstation, 2=StandaloneServer, 3=MemberServer, 4=BackupDC, 5=PrimaryDC

{Write-Host 'Check: Machine is DC' -ForegroundColor Green}

else
{Write-Host 'Oops: This Script must be run on a DC' -ForegroundColor Red -InformationAction Stop}

if (([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator))
 
{Write-Host 'Check: You are Admin and good to go...' -ForegroundColor Green
} 
else
{Write-Host 'Oops: Please run Powershell as Administrator to complete this task!' -ForegroundColor Red
}
#endregion


#region Create Scheduled Task
#&: call operator; tells PowerShell to interpret the string that follows as an executable command
$action = New-ScheduledTaskAction -Execute 'powershell.exe' -Argument {-noexit -command (&"ntdsutil.exe 'activate instance ntds' snapshot create quit quit")}
$trigger = New-ScheduledTaskTrigger -Daily -At 03:00
$principal = New-ScheduledTaskPrincipal -UserId 'NT Authority\System' -LogonType Password

Register-ScheduledTask -TaskName ADSnapshot -Action $action -Trigger $trigger -Principal $principal
#endregion