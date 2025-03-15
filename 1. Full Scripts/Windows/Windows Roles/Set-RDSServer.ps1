##########################################
# AUTHOR   : Ryan Mutschler
# DATE     : 3-14-2025
# EDIT     : 3-14-2025
# PURPOSE  : Set the RDS server to use a specified license server.
#
# VERSION  : 1    (Initial release)
##########################################

$obj = Get-WmiObject -Namespace "Root/CIMV2/TerminalServices" -Class Win32_TerminalServiceSetting
$obj.ChangeMode(4)
$obj.SetSpecifiedLicenseServerList("RDS01")