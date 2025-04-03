##########################################
# AUTHOR   : Ryan Mutschler
# DATE     : 3-14-2025
# EDIT     : 3-14-2025
# PURPOSE  : Set the owner of an Azure AD device.
#
# VERSION  : 1    (Initial release)
##########################################

#1. First, you must ensure the AzureAD module is installed on your computer and then imported into your PowerShell session. To do that, you should use the following commands.
Install-Module AzureAD
Import-module AzureAD

#2. Connect to Azure Active Directory
Connect-AzureAD

#3. To get the device object in your tenant, you must use the Get-AzureADDevice cmdlet and pass the device name in the -SearchString parameter.
$device=Get-AzureADDevice `
    -searchString "SAD001"

#4. To get the current registered owner for the device, you should use the Get-AzureADDeviceRegisteredOwner cmdlet with the following syntax.
(Get-AzureADDeviceRegisteredOwner -ObjectId $device.ObjectId).DisplayName

#5. To add a user as an owner to a device, the user must be registered in your tenant and know the value of the user’s “ObjectId” property. I will store the user object in the $user variable to improve code readability.
$owner=Get-AzureADUser `
    -searchString "Jorge Bernhardt"

#6. Once the user object is stored in the $owner variable, you should use the Add-AzureADDeviceRegisteredOwner cmdlet with the following syntax to add the user as the device’s new owner.
Add-AzureADDeviceRegisteredOwner `
    -ObjectId $device.ObjectId `
    -RefObjectId $owner.ObjectId

#7. Using the following syntax, you can always remove a device owner using the Remove-AzureADDeviceRegisteredOwner cmdlet.
$user=Get-AzureADUser `
    -searchString "some user"
Remove-AzureADDeviceRegisteredOwner `
    -ObjectId $device.ObjectId `
    -OwnerId $user.ObjectId

#8. Once the previous step is done, to verify that the change was successful, use the Get-AzureADDeviceRegisteredOwner cmdlet with the following syntax.
Get-AzureADDeviceRegisteredOwner `
    -ObjectId $device.ObjectId