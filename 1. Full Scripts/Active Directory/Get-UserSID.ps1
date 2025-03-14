$objUser = New-Object System.Security.Principal.NTAccount("USERNAME")
$strSID = $objUser.Translate([System.Security.Principal.SecurityIdentifier])
$strSID.Value