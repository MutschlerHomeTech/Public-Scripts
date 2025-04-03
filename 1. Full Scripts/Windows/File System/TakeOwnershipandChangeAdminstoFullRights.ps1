##########################################
# AUTHOR   : Ryan Mutschler
# DATE     : 3-14-2025
# EDIT     : 3-14-2025
# PURPOSE  : Take ownership of a folder and change the permissions to full control for Administrators.
#
# VERSION  : 1    (Initial release)
##########################################

$folderMask = "C:\Program Files\WindowsApps\Microsoft.DesktopAppInstaller_*"
$folders = Get-ChildItem -Path $folderMask -Directory | Where-Object { $_.Name -like "*_x64_*" }
foreach ($folder in $folders) {
    $folderPath = $folder.FullName
    TAKEOWN /F $folderPath /R /A /D Y
    ICACLS $folderPath /grant Administrators:F /T
}