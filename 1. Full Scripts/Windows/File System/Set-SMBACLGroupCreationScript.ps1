##########################################
# AUTHOR   : Ryan Mutschler
# DATE     : 3-14-2025
# EDIT     : 3-14-2025
# PURPOSE  : Create SMB ACL groups in Active Directory.
#
# VERSION  : 1    (Initial release)
##########################################

param(
[Parameter(Mandatory=$True)][String[]]$FolderName,
[Parameter(Mandatory=$True)][String[]]$ServerName,
[Parameter(Mandatory=$False)][String[]]$SubFolderOf,
[Parameter(Mandatory=$False)][String]$OrganizationUnit="OU=SMB,OU=Security Groups,DC=corp,DC=mutschlerhome,DC=com"
)

$ServerNameUpper = $ServerName.ToUpper()
$ServerName = $ServerName.ToLower()

$Name = "SMB_$($ServerNameUpper)_$($FolderName)"
$Description = "\\$($ServerName)\$FolderName"
if($SubFolderOf) {

    if( ($SubFolderOf.EndsWith("\")) ) {
        $SubFolderOf = $SubFolderOf.substring(0,($($SubFolderOf).Length-1))
    }
    $Description = "\\$($ServerName)\$($SubFolderOf)\$($FolderName)"
}

New-ADGroup –Name "$($Name)_Read" -Description "$($Description) [Read Only]" –groupscope DomainLocal –path $OrganizationUnit
New-ADGroup –Name "$($Name)_Modify" -Description "$($Description) [Modify]" –groupscope DomainLocal –path $OrganizationUnit
New-ADGroup –Name "$($Name)_Full" -Description "$($Description) [FullControl]" –groupscope DomainLocal –path $OrganizationUnit
New-ADGroup –Name "$($Name)_List" -Description "$($Description) [List Only]" –groupscope DomainLocal –path $OrganizationUnit

Add-ADGroupMember -Identity "$($Name)_Full" -Members "Domain Admins"
Add-ADGroupMember -Identity "$($Name)_Full" -Members "Enterprise Admins"
Add-ADGroupMember -Identity "$($Name)_Full" -Members "Server Admins"
Add-ADGroupMember -Identity "$($Name)_Read" -Members "Domain Users"