#$credential = Get-Credential
#Connect-MsolService -Credential $credential
$ADUser = "user"
$365User = "user@mutschlerhome.com"
$guid =(Get-ADUser $ADUser).Objectguid
$immutableID=[system.convert]::ToBase64String($guid.tobytearray())
Set-MsolUser -UserPrincipalName "$365User" -ImmutableId $immutableID