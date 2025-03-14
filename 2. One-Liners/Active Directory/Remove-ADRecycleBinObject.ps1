#1. Check first to verify you only get the user you want from the following command.
Get-ADObject -Filter 'isDeleted -eq $true -and Name -like "*Username*"' -IncludeDeletedObjects -Properties * | Select-Object Name, ObjectClass, whenChanged, whenCreated, LastKnownParent, isDeleted | Sort-Object whenChanged -Descending

# Gets all deleted AD objects.
Get-ADObject -Filter 'isDeleted -eq $true' -IncludeDeletedObjects -Properties * | Select-Object Name, ObjectClass, whenChanged, whenCreated, LastKnownParent, isDeleted | Sort-Object whenChanged -Descending

#2. Once you verified the only result is the user you want to delete permanently, run the following command.
Get-ADObject -Filter 'isDeleted -eq $true -and Name -like "*Username*"' -IncludeDeletedObjects | Remove-ADObject -PermanentlyDelete -Confirm:$false