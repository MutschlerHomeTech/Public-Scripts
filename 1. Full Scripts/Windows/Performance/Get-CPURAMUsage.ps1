##########################################
# AUTHOR   : Ryan Mutschler
# DATE     : 3-14-2025
# EDIT     : 3-14-2025
# PURPOSE  : Get the CPU and RAM usage of the top 15 processes on a list of servers.
#
# VERSION  : 1    (Initial release)
##########################################

$Output = 'C:\temp\Result.txt'
$ServerList = Get-Content 'C:\temp\Serverlist.txt'

$ScriptBLock = {

  $CPUPercent = @{
    Label = 'CPUUsed'
    Expression = {
      $SecsUsed = (New-Timespan -Start $_.StartTime).TotalSeconds
      [Math]::Round($_.CPU * 10 / $SecsUsed)
    }
  }

  $MemUsage = @{
    Label ='RAM(MB)'
    Expression = {
    [Math]::Round(($_.WS / 1MB),2)
    }
}
  Get-Process | Select-Object -Property Name, CPU, $CPUPercent, $MemUsage,
  Description |
  Sort-Object -Property CPUUsed -Descending |
  Select-Object -First 15  | Format-Table -AutoSize
}

foreach ($ServerNames in $ServerList) {

"CPU & Memory Usage in $serverNames" | Out-File $Output -Append

Invoke-Command -ScriptBlock $ScriptBLock -ComputerName $ServerNames |
Out-File $Output -Append
  }