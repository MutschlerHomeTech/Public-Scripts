##########################################
# AUTHOR   : Ryan Mutschler
# DATE     : 3-14-2025
# EDIT     : 3-14-2025
# PURPOSE  : Install the Remote Server Administration Tools (RSAT) on a Windows machine.
#
# VERSION  : 1    (Initial release)
##########################################

# Get RSAT items that are not currently installed:
$install = Get-WindowsCapability -Online |
  Where-Object {$_.Name -like "RSAT*" -AND $_.State -eq "NotPresent"}

# Install the RSAT items that meet the filter:
foreach ($item in $install) {
  try {
    Add-WindowsCapability -Online -Name $item.name
  }
  catch [System.Exception] {
    Write-Warning -Message $_.Exception.Message
  }
}