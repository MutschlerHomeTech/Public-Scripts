Connect-msolService
Get-MsolUser -ReturnDeletedUsers | Select-Object UserPrincipalName, DisplayName | Sort-Object UserPrincipalName
# Get-MsolUser -ReturnDeletedUsers | Select-Object UserPrincipalName, DisplayName | Sort-Object UserPrincipalName | Export-Csv -Path C:\Temp\DeletedUsers.csv -NoTypeInformation