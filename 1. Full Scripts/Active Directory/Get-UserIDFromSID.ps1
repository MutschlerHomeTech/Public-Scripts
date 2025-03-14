$objSID = New-Object System.Security.Principal.SecurityIdentifier ("S-1-5-21-2484819571-2125529598-2454565363-2184915")
$objUser = $objSID.Translate( [System.Security.Principal.NTAccount])
$objUser.Value