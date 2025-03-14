$obj = Get-WmiObject -Namespace "Root/CIMV2/TerminalServices" -Class Win32_TerminalServiceSetting
$obj.ChangeMode(4)
$obj.SetSpecifiedLicenseServerList("RDS01")