#1. Get list of applications installed on the computer
wmic product where "name like '%java%'" get name

#2. Uninstall the application
wmic product where "name like '%java%'" call uninstall