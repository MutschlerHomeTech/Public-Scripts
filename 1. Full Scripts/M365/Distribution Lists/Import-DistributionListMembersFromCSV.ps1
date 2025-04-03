##########################################
# AUTHOR   : Ryan Mutschler
# DATE     : 3-14-2025
# EDIT     : 3-14-2025
# PURPOSE  : Import members to a distribution list from a CSV file.
#
# VERSION  : 1    (Initial release)
##########################################

$GroupEmailID = "Sales@Crescent.com"
$CSVFile = "C:\Temp\DL-Members.txt"

#Connect to Exchange Online
Connect-ExchangeOnline -ShowBanner:$False

#Get Existing Members of the Distribution List
$DLMembers =  Get-DistributionGroupMember -Identity $GroupEmailID -ResultSize Unlimited | Select-Object -Expand PrimarySmtpAddress

#Import Distribution List Members from CSV
Import-CSV $CSVFile -Header "UPN" | ForEach-Object {
    #Check if the Distribution List contains the particular user
    If ($DLMembers -contains $_.UPN)
    {
        Write-host -f Yellow "User is already member of the Distribution List:"$_.UPN
    }
    Else
    {
        Add-DistributionGroupMember –Identity $GroupEmailID -Member $_.UPN
        Write-host -f Green "Added User to Distribution List:"$_.UPN
    }
}