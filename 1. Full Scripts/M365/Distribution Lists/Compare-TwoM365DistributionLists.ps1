##########################################
# AUTHOR   : Ryan Mutschler
# DATE     : 3-14-2025
# EDIT     : 3-14-2025
# PURPOSE  : Compare two Microsoft 365 distribution lists and identify differences.
#
# VERSION  : 1    (Initial release)
##########################################

Connect-AzureAD

$AW=Get-DistributionGroupMember -Identity "iPhone Notifications" | Select-Object Identity, PrimarySMTPAddress
$Mango=Get-DistributionGroupMember -Identity "iPhone Notifications" | Select-Object Identity, PrimarySMTPAddress

$Comparison=Compare-Object -ReferenceObject $AW.PrimarySMTPAddress -DifferenceObject $Mango.PrimarySMTPAddress | Sort-Object PrimarySMTPAddress

foreach ($i in $Comparison){
	if($i.SideIndicator -eq "=>"){
		#Listed in Mango but not in AW
		Write-output "$($i.InputObject) exists in Mango Apps but not Arctic Wolf"
	}elseif($i.SideIndicator -eq "<="){
		#Listed in AW but not in Mango
		Write-output "$($i.InputObject) exists in Arctic Wolf but not Mango Apps"
	}
}