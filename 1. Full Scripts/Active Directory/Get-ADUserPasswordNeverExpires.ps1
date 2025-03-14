##########################################
# AUTHOR   : Ryan Mutschler
# DATE     : 3-14-2025
# EDIT     : 3-14-2025
# PURPOSE  : This script queries AD for users with PasswordNeverExpires enabled and exports to a text file
# Created with assistance from claude.ai
#
# VERSION  : 1    (Initial release)
##########################################

get-aduser -filter * -properties Name, PasswordNeverExpires |
Where-Object { $_.passwordNeverExpires -eq "true" } |
Where-Object {$_.enabled -eq "true"} |
Format-Table -Property Name, PasswordNeverExpires -AutoSize |
Out-File -FilePath .\Get-ADUser-PasswordNeverExpires.txt