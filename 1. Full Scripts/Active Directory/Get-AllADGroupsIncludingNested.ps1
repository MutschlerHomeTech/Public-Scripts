##########################################
# AUTHOR    : Ryan Mutschler
# DATE      : 4-29-2025
# EDIT      : 4-29-2025
# PURPOSE   : Lists all AD groups for a user, including nested groups
# REPOSITORY: 
# WIKIPEDIA : 
#
# VERSION   : 1.0     (Initial release)
##########################################
 

function Get-NestedGroups {
    param(
        [Parameter(Mandatory=$true)]
        [string]$GroupDN
    )
    
    # Get the group's memberOf property
    $group = Get-ADGroup -Identity $GroupDN -Properties MemberOf
    
    # Return the group's direct memberships
    return $group.MemberOf
}

function Get-AllUserGroups {
    param(
        [Parameter(Mandatory=$true)]
        [string]$Username
    )
    
    # Get user object
    try {
        $user = Get-ADUser -Identity $Username -Properties MemberOf -ErrorAction Stop
    }
    catch {
        Write-Error "User $Username not found in Active Directory"
        return
    }
    
    # Initialize collections
    $allGroups = New-Object System.Collections.ArrayList
    $processedGroups = New-Object System.Collections.ArrayList
    $groupsToProcess = New-Object System.Collections.ArrayList
    
    # Add direct groups to the list to process
    foreach ($group in $user.MemberOf) {
        [void]$groupsToProcess.Add($group)
    }
    
    # Process groups recursively
    while ($groupsToProcess.Count -gt 0) {
        $currentGroup = $groupsToProcess[0]
        $groupsToProcess.RemoveAt(0)
        
        if (-not $processedGroups.Contains($currentGroup)) {
            # Add to processed groups
            [void]$processedGroups.Add($currentGroup)
            
            # Add to all groups collection
            [void]$allGroups.Add($currentGroup)
            
            # Get parent groups
            $parentGroups = Get-NestedGroups -GroupDN $currentGroup
            
            # Add parent groups to process
            foreach ($parentGroup in $parentGroups) {
                if (-not $processedGroups.Contains($parentGroup)) {
                    [void]$groupsToProcess.Add($parentGroup)
                }
            }
        }
    }
    
    return $allGroups
}

function Format-GroupOutput {
    param(
        [Parameter(Mandatory=$true)]
        [System.Collections.ArrayList]$Groups
    )
    
    $formattedGroups = @()
    
    foreach ($groupDN in $Groups) {
        try {
            $group = Get-ADGroup -Identity $groupDN -Properties Description
            $formattedGroups += [PSCustomObject]@{
                Name = $group.Name
                Description = $group.Description
                DistinguishedName = $group.DistinguishedName
            }
        }
        catch {
            Write-Warning "Could not retrieve details for group: $groupDN"
        }
    }
    
    return $formattedGroups
}

# Main execution
Clear-Host
Write-Host "AD Group Membership Report Tool" -ForegroundColor Cyan
Write-Host "----------------------------" -ForegroundColor Cyan

# Prompt for username
$Username = Read-Host -Prompt "Enter the username to check group memberships"

Write-Host "Finding all groups for user: $Username" -ForegroundColor Cyan

# Get all groups
$allUserGroups = Get-AllUserGroups -Username $Username

if ($allUserGroups) {
    Write-Host "Found $($allUserGroups.Count) groups" -ForegroundColor Green
    
    # Format and display results
    $formattedGroups = Format-GroupOutput -Groups $allUserGroups
    $formattedGroups | Format-Table -Property Name, Description -AutoSize
    
    # Ask if user wants to export results
    $exportChoice = Read-Host -Prompt "Do you want to export results to CSV? (Y/N)"
    if ($exportChoice -eq "Y" -or $exportChoice -eq "y") {
        $formattedGroups | Export-Csv -Path ".\$Username-Groups.csv" -NoTypeInformation
        Write-Host "Results exported to .\$Username-Groups.csv" -ForegroundColor Green
    }
}
else {
    Write-Host "No groups found for user $Username" -ForegroundColor Yellow
}

# Use a more compatible method to pause at the end
Write-Host "Press Enter to exit..."
Read-Host