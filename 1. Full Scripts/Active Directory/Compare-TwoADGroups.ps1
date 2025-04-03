##########################################
# AUTHOR   : Ryan Mutschler
# DATE     : 3-14-2025
# EDIT     : 3-14-2025
# PURPOSE  : Compare two AD groups and list the differences between the two groups.
# COMMENT  : AD Group Comparison
#
# VERSION  : 1    (Initial release)
##########################################

$GROUP1=Get-ADGroupMember -Identity "Domain Admins" | select-Object Name
$GROUP2=Get-ADGroupMember -Identity "Enterprise Admins" | select-Object Name

$Comparison=Compare-Object -ReferenceObject $GROUP1.Name -DifferenceObject $GROUP2.Name | Sort-Object Name

foreach ($i in $Comparison){
	if($i.SideIndicator -eq "=>"){
		#Listed in GROUP2 but not in GROUP1
		Write-output "$($i.InputObject) exists in Group 2 but not Group 1"
	}elseif($i.SideIndicator -eq "<="){
		#Listed in GROUP1 but not in GROUP2
		Write-output "$($i.InputObject) exists in Group 1 but not Group 2"
	}
}