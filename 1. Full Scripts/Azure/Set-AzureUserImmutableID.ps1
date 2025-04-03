##########################################
# AUTHOR   : Ryan Mutschler
# DATE     : 3-14-2025
# EDIT     : 3-14-2025
# PURPOSE  : Set the ImmutableID for an Azure AD user.
#
# VERSION  : 1    (Initial release)
##########################################

#$credential = Get-Credential
#Connect-MsolService -Credential $credential
$ADUser = "user"
$365User = "user@mutschlerhome.com"
$guid =(Get-ADUser $ADUser).Objectguid
$immutableID=[system.convert]::ToBase64String($guid.tobytearray())
Set-MsolUser -UserPrincipalName "$365User" -ImmutableId $immutableID