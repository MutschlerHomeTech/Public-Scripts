##########################################
# AUTHOR   : Ryan Mutschler
# DATE     : 3-14-2025
# EDIT     : 3-14-2025
# PURPOSE  : Retrieve the user ID from a given SID in Active Directory.
#
# VERSION  : 1    (Initial release)
##########################################

$objSID = New-Object System.Security.Principal.SecurityIdentifier ("S-1-5-21-2484819571-2125529598-2454565363-2184915")
$objUser = $objSID.Translate( [System.Security.Principal.NTAccount])
$objUser.Value