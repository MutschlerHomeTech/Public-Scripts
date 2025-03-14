Get-childitem \\network\share\ -recurse | where{$_.psiscontainer} |
Get-Acl | % {
    $path = $_.Path
    $_.Access | % {
        New-Object PSObject -Property @{
            Folder = $path.Replace("Microsoft.PowerShell.Core\FileSystem::","")
            Access = $_.FileSystemRights
            Control = $_.AccessControlType
            User = $_.IdentityReference
            Inheritance = $_.IsInherited
            }
        }
    } | select-object -Property User, Access, Folder | export-csv output.csv -force