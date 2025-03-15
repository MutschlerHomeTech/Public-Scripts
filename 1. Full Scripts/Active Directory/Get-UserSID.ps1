##########################################
# AUTHOR   : Ryan Mutschler
# DATE     : 3-14-2025
# EDIT     : 3-14-2025
# PURPOSE  : Retrieve the SID of a user in Active Directory.
#
# VERSION  : 1    (Initial release)
##########################################

$objUser = New-Object System.Security.Principal.NTAccount("USERNAME")
$strSID = $objUser.Translate([System.Security.Principal.SecurityIdentifier])
$strSID.Value