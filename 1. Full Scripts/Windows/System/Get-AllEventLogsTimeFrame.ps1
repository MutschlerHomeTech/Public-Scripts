##########################################
# AUTHOR   : Ryan Mutschler
# DATE     : 3-14-2025
# EDIT     : 3-14-2025
# PURPOSE  : Get all event logs from a specified time frame.
#
# VERSION  : 1    (Initial release)
##########################################

#example: get all logs in the last minute
if($computerName -eq "" -OR $null -eq $computerName)
{
  $computerName = $env:COMPUTERNAME
}
#gather the log names
$logNames = @()
$allLogNames = get-winevent -computerName $computerName -ListLog *
foreach($logName in $allLogNames)
{
  if($logName.recordcount -gt 0) #filter empty logs
  {
    $logNames += $logName
  }
}
#get the time range
$startTime = '3/3/2025 05:17:15'#(Get-date).AddMinutes(-1)
$endTime = '3/3/2025 05:18:00'#Get-date
#get the actual logs
$logs = Get-WinEvent -computerName $computerName -FilterHashtable @{ LogName=$logNames.logName; StartTime=$startTime; EndTime=$endTime}
#this makes Out-GridView show the full log properties
($logs | ConvertTo-Json | ConvertFrom-Json).syncroot | Export-Csv -Path .\events.csv -NoTypeInformation