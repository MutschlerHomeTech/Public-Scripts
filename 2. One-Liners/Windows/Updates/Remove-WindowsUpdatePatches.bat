#1. Find the list of packages installed on the machine that is having issues by performing this command.
dism /online /get-packages /format:table > C:\Packages.txt

#2. Run this command to uninstall the package silently using the package name gathered from the first step.
dism /online /remove-package /packagename:Package_for_KB2919355~31bf3856ad364e35~amd64~~ /quiet /norestart