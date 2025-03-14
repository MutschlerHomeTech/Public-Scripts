#1. Connect to MSOnline in Powershell
Import-Module ExchangeOnlineManagement
Connect-IPPSSession -UserPrincipalName "UPN"

#2. Create a New Compliance Search in Powershell, preferably Powershell ISE
New-ComplianceSearch `
-Name Phish1 `
-ExchangeLocation All `
-ContentMatchQuery 'subject:"You must change your bank password now" AND sent:05/12/2020'

#3. Start the Compliance Search
Start-ComplianceSearch -Identity Phish1

#4. Check the Status of/Verify the Search Completes
Get-ComplianceSearch -Identity Phish1

#5. Verify Items Found Match the Number of Emails Expected
Get-ComplianceSearch -Identity Phish1 | Format-List *

#6. Create Preview of the Search Results
New-ComplianceSearchAction -SearchName Phish1 -Preview

#7. Preview the Search Results
(Get-ComplianceSearchAction Phish1_Preview | Select-Object -ExpandProperty Results) -split ","

#8. Delete Email From All Mailboxes In Office 365 With Soft Delete
New-ComplianceSearchAction -SearchName Phish1 -Purge -PurgeType SoftDelete

#9. View Result of Purge
Get-ComplianceSearchAction -Identity Phish1_Purge | Format-List