# The script below pings the target 10 times.

Start-Transcript -Force -Path "C:\temp\ping.log"
Test-Connection -Count 10 -ComputerName COMPUTERNAME | Format-Table @{Name='TimeStamp';Expression={Get-Date}},Address,ProtocolAddress,ResponseTime

# The script below pings the target the maximum number of times for Powershell Versions below 7.2.

Start-Transcript -Force -Path "C:\temp\ping.log"
Test-Connection -Count 2147483647 -ComputerName COMPUTERNAME | Format-Table @{Name='TimeStamp';Expression={Get-Date}},Address,ProtocolAddress,ResponseTime

# The script below pings the target indefinitely. Requires Powershell Version 7.2 at minimum.

Start-Transcript -Force -Path "C:\temp\ping.log"
Test-Connection -Repeat -ComputerName COMPUTERNAME | Format-Table @{Name='TimeStamp';Expression={Get-Date}},Address,ProtocolAddress,ResponseTime