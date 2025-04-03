##########################################
# AUTHOR   : Ryan Mutschler
# DATE     : 3-14-2025
# EDIT     : 3-14-2025
# PURPOSE  : Compare two Azure AD groups and list the differences.
#
# VERSION  : 1    (Initial release)
##########################################

Connect-AzureAD

$GROUP1=Get-AzureADGroupMember -ObjectId "c203a90f-0ec1-4c75-85c9-8d6e97f78a60" -All $true | Select-Object DisplayName, UserPrincipalName
$GROUP2=Get-AzureADGroupMember -ObjectId "2177ea60-e8d6-4dc9-a044-4a1ccecbf743" -All $true | Select-Object DisplayName, UserPrincipalName

$Comparison=Compare-Object -ReferenceObject $GROUP1.UserPrincipalName -DifferenceObject $GROUP2.UserPrincipalName | Sort-Object UserPrincipalName

foreach ($i in $Comparison){
	if($i.SideIndicator -eq "=>"){
		#Listed in Group 2 but not in Group 1
		Write-output "$($i.InputObject) exists in Group 2 but not Group 1"
	}elseif($i.SideIndicator -eq "<="){
		#Listed in Group 1 but not in Group 2
		Write-output "$($i.InputObject) exists in Group 1 but not Group 2"
	}
}