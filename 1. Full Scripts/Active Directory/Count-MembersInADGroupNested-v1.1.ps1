##########################################
# AUTHOR    : Ryan Mutschler
# DATE      : 4-2-2025
# EDIT      : 4-2-2025
# PURPOSE   : Count members of an Active Directory group, including nested groups.
# REPOSITORY: https://github.com/MutschlerHomeTech/Public-Scripts/blob/master/1.%20Full%20Scripts/Active%20Directory/Count-MembersInADGroupNested-v1.0.ps1
# WIKIPEDIA : https://wikipedia.mutschlerhome.com/books/active-directory-scripts/page/count-membersinadgroupnested
#
# VERSION   : 1.0     (Initial release)
##########################################

# Import the Active Directory module
Import-Module ActiveDirectory

function Get-ADNestedGroupMembers {
    param (
        [Parameter(Mandatory = $true)]
        [string]$GroupName,
        
        [Parameter(Mandatory = $false)]
        [switch]$CountOnly
    )
    
    Write-Host "Processing group: $GroupName..." -ForegroundColor Green
    
    # Use these variables to track progress
    $script:processedGroups = @{}
    $script:uniqueMembers = @{}
    $script:userCount = 0
    $script:groupCount = 0
    $script:computerCount = 0
    $script:otherCount = 0
    $script:memberCollection = New-Object System.Collections.ArrayList
    
    # Start the timer
    $stopwatch = [System.Diagnostics.Stopwatch]::StartNew()
    
    # Get the initial group
    try {
        # Get main group info
        $group = Get-ADGroup -Identity $GroupName -Properties Member -ErrorAction Stop
        $groupDN = $group.DistinguishedName
        
        # Start by getting the direct members of main group
        Write-Host "Getting direct members of $GroupName..." -ForegroundColor Cyan
        $directMembers = @()
        
        # Try to get all direct members at once, but be prepared for size limit errors
        try {
            $directMembers = Get-ADGroupMember -Identity $groupDN -ErrorAction Stop
            Write-Host "Retrieved $($directMembers.Count) direct members in one query" -ForegroundColor Cyan
        }
        catch [Microsoft.ActiveDirectory.Management.ADException] {
            if ($_.Exception.Message -like "*size limit*") {
                Write-Host "Size limit exceeded. Using paged approach to get direct members..." -ForegroundColor Yellow
                
                # Get members using a different approach - direct property access with chunking
                $allMembers = Get-ADGroup -Identity $groupDN -Properties member | Select-Object -ExpandProperty member
                
                if ($allMembers) {
                    Write-Host "Found $($allMembers.Count) members via direct property access" -ForegroundColor Green
                    
                    # Process in chunks of 100 to avoid overwhelming
                    $chunks = [Math]::Ceiling($allMembers.Count / 100)
                    for ($i = 0; $i -lt $chunks; $i++) {
                        $start = $i * 100
                        $end = [Math]::Min(($i + 1) * 100 - 1, $allMembers.Count - 1)
                        $chunk = $allMembers[$start..$end]
                        
                        Write-Host "Processing chunk $($i+1) of $chunks (members $start to $end)..." -ForegroundColor DarkCyan
                        
                        foreach ($memberDN in $chunk) {
                            try {
                                $member = Get-ADObject -Identity $memberDN -Properties objectClass, objectGUID, name, samAccountName
                                $directMembers += $member
                            }
                            catch {
                                Write-Warning "Error retrieving member $memberDN`: $_"
                            }
                        }
                    }
                }
            }
            else {
                throw $_ # Re-throw if it's not a size limit error
            }
        }
        
        # Process all direct members first
        $totalDirectMembers = $directMembers.Count
        Write-Host "Processing $totalDirectMembers direct members..." -ForegroundColor Cyan
        
        for ($i = 0; $i -lt $totalDirectMembers; $i++) {
            $member = $directMembers[$i]
            
            # Show progress every 100 members
            if ($i % 100 -eq 0 -and $i -gt 0) {
                Write-Host "  Processed $i of $totalDirectMembers direct members..." -ForegroundColor DarkGray
            }
            
            # Add member to our tracking
            $guidString = $member.objectGUID.ToString()
            
            if (-not $script:uniqueMembers.ContainsKey($guidString)) {
                $script:uniqueMembers[$guidString] = $member
                
                # Count by type
                switch ($member.objectClass) {
                    'user' { $script:userCount++ }
                    'group' { $script:groupCount++ }
                    'computer' { $script:computerCount++ }
                    default { $script:otherCount++ }
                }
                
                # Store the actual member object if not in count-only mode
                if (-not $CountOnly) {
                    [void]$script:memberCollection.Add($member)
                }
            }
            
            # Process nested groups
            if ($member.objectClass -eq 'group') {
                Initialize-NestedGroup -GroupDN $member.distinguishedName
            }
        }
        
        # Check for primary group membership
        Initialize-PrimaryGroupMembers -GroupDN $groupDN
        
        # Stop the timer
        $stopwatch.Stop()
        $elapsedTime = $stopwatch.Elapsed.TotalSeconds
        
        # Create result object
        $result = [PSCustomObject]@{
            TotalCount = $script:uniqueMembers.Count
            UserCount = $script:userCount
            GroupCount = $script:groupCount
            ComputerCount = $script:computerCount
            OtherCount = $script:otherCount
            ProcessingTimeSeconds = [math]::Round($elapsedTime, 2)
            ProcessedGroups = $script:processedGroups.Count
            Members = if (-not $CountOnly) { $script:memberCollection } else { $null }
        }
        
        return $result
    }
    catch {
        Write-Error "Error processing group $GroupName`: $_"
        return $null
    }
}

# Function to process a nested group
function Initialize-NestedGroup {
    param (
        [Parameter(Mandatory = $true)]
        [string]$GroupDN
    )
    
    # Skip if already processed to prevent loops
    if ($script:processedGroups.ContainsKey($GroupDN)) {
        return
    }
    
    # Mark as processed
    $script:processedGroups[$GroupDN] = $true
    $groupName = ($GroupDN -split ',')[0] -replace 'CN=',''
    Write-Host "Processing nested group: $groupName" -ForegroundColor Yellow
    
    try {
        # Get members of nested group
        $nestedMembers = Get-ADGroupMember -Identity $GroupDN -ErrorAction Stop
        Write-Host "  Found $($nestedMembers.Count) members in nested group $groupName" -ForegroundColor DarkYellow
        
        foreach ($member in $nestedMembers) {
            $guidString = $member.objectGUID.ToString()
            
            # Only process if new
            if (-not $script:uniqueMembers.ContainsKey($guidString)) {
                $script:uniqueMembers[$guidString] = $member
                
                # Count by type
                switch ($member.objectClass) {
                    'user' { $script:userCount++ }
                    'group' { $script:groupCount++ }
                    'computer' { $script:computerCount++ }
                    default { $script:otherCount++ }
                }
                
                # Store if not in count-only mode
                if (-not $CountOnly) {
                    [void]$script:memberCollection.Add($member)
                }
            }
            
            # Recurse if this is a group
            if ($member.objectClass -eq 'group') {
                Initialize-NestedGroup -GroupDN $member.distinguishedName
            }
        }
    }
    catch [Microsoft.ActiveDirectory.Management.ADException] {
        if ($_.Exception.Message -like "*size limit*") {
            Write-Host "  Size limit exceeded for nested group. Using paged approach..." -ForegroundColor Yellow
            
            try {
                # Try chunked approach for this nested group
                $allNestedMembers = Get-ADGroup -Identity $GroupDN -Properties member | Select-Object -ExpandProperty member
                
                if ($allNestedMembers) {
                    Write-Host "  Found $($allNestedMembers.Count) members via direct property access" -ForegroundColor DarkYellow
                    
                    foreach ($memberDN in $allNestedMembers) {
                        try {
                            $member = Get-ADObject -Identity $memberDN -Properties objectClass, objectGUID, name, samAccountName
                            $guidString = $member.objectGUID.ToString()
                            
                            if (-not $script:uniqueMembers.ContainsKey($guidString)) {
                                $script:uniqueMembers[$guidString] = $member
                                
                                # Count by type
                                switch ($member.objectClass) {
                                    'user' { $script:userCount++ }
                                    'group' { $script:groupCount++ }
                                    'computer' { $script:computerCount++ }
                                    default { $script:otherCount++ }
                                }
                                
                                # Store if not in count-only mode
                                if (-not $CountOnly) {
                                    [void]$script:memberCollection.Add($member)
                                }
                            }
                            
                            # If member is a group, process it recursively
                            if ($member.objectClass -eq 'group') {
                                Initialize-NestedGroup -GroupDN $member.distinguishedName
                            }
                        }
                        catch {
                            Write-Warning "  Error retrieving nested member $memberDN`: $_"
                        }
                    }
                }
            }
            catch {
                Write-Warning "  Failed to get members for nested group $groupName`: $_"
            }
        }
        else {
            Write-Warning "  Error retrieving members for nested group $groupName`: $_"
        }
    }
    catch {
        Write-Warning "  Error processing nested group $groupName`: $_"
    }
}

# Function to handle primary group membership
function Initialize-PrimaryGroupMembers {
    param (
        [Parameter(Mandatory = $true)]
        [string]$GroupDN
    )
    
    try {
        Write-Host "Checking for primary group members..." -ForegroundColor Magenta
        
        # Get the RID of the group
        $groupSID = (Get-ADGroup $GroupDN -Properties objectSID).objectSID
        $groupRID = $groupSID.Value.Split("-")[-1]
        
        # Find users who have this as their primary group
        $primaryGroupUsers = Get-ADUser -LDAPFilter "(primaryGroupID=$groupRID)" -Properties objectGUID
        $primaryCount = ($primaryGroupUsers | Measure-Object).Count
        
        Write-Host "  Found $primaryCount users with this group as their primary group" -ForegroundColor Magenta
        
        # Process each primary group user
        foreach ($user in $primaryGroupUsers) {
            $guidString = $user.objectGUID.ToString()
            
            if (-not $script:uniqueMembers.ContainsKey($guidString)) {
                $script:uniqueMembers[$guidString] = $user
                $script:userCount++
                
                if (-not $CountOnly) {
                    [void]$script:memberCollection.Add($user)
                }
            }
        }
    }
    catch {
        Write-Warning "Error checking for primary group members: $_"
    }
}

# Main script execution
$groupName = Read-Host "Enter the name of the Active Directory group"

Write-Host "`nRetrieving members of group '$groupName' (including nested groups)..."

# Ask if user wants just the count (faster) or full member details
$countOnly = Read-Host "Do you want just the count (faster) or full member details? (C for count only, F for full details)"
$countOnlySwitch = ($countOnly -eq "C" -or $countOnly -eq "c")

Write-Host "`nStarting group membership analysis... This may take some time for large groups."
Write-Host "You selected: $(if ($countOnlySwitch) { 'Count only (faster)' } else { 'Full member details' })"

$result = Get-ADNestedGroupMembers -GroupName $groupName -CountOnly:$countOnlySwitch

if ($null -ne $result) {
    # Report results
    Write-Host "`n=============== RESULTS ==============="
    Write-Host "Total unique members: $($result.TotalCount)"
    
    Write-Host "`nMembers by type:"
    Write-Host "  Users: $($result.UserCount)"
    Write-Host "  Groups: $($result.GroupCount)"
    Write-Host "  Computers: $($result.ComputerCount)"
    Write-Host "  Other objects: $($result.OtherCount)"
    
    Write-Host "`nProcessed $($result.ProcessedGroups) groups in $($result.ProcessingTimeSeconds) seconds"
    
    # Optionally export to CSV if we have full member details
    if (-not $countOnlySwitch -and $null -ne $result.Members) {
        $exportCsv = Read-Host "`nExport members to CSV? (Y/N)"
        if ($exportCsv -eq 'Y' -or $exportCsv -eq 'y') {
            # Ensure C:\Temp directory exists
            if (-not (Test-Path -Path "C:\Temp" -PathType Container)) {
                try {
                    New-Item -Path "C:\Temp" -ItemType Directory -Force | Out-Null
                    Write-Host "Created directory: C:\Temp"
                } catch {
                    Write-Error "Failed to create C:\Temp directory: $_"
                    return
                }
            }
            
            $csvPath = "C:\Temp\$groupName-members.csv"
            $result.Members | Select-Object Name, SamAccountName, objectClass, distinguishedName |
                Export-Csv -Path $csvPath -NoTypeInformation
            Write-Host "Members exported to: $csvPath"
        }
    }
}
