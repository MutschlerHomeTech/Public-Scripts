# Define the list of distribution lists
$distributionLists = @("Managers", "Senior Managers")

# Function to get members of a distribution list
function Get-DistributionListMembers {
    param (
        [string]$distributionListName
    )

    $members = Get-DistributionGroupMember -Identity $distributionListName | Select-Object -ExpandProperty PrimarySmtpAddress
    return $members
}

# Function to get all users
function Get-AllUsers {
    $users = Get-ADUser -Properties * -Filter *
    return $users
}

# Create an array to store all users
$allUsers = Get-AllUsers

# Create an array to store members of all distribution lists
$allListMembers = @()

# Populate $allListMembers with members of each distribution list
foreach ($list in $distributionLists) {
    $listMembers = Get-DistributionListMembers -distributionListName $list
    $allListMembers += $listMembers
}

# Find users not in any distribution list
$missingUsers = $allUsers | Where-Object { $_.UserPrincipalName -notin $allListMembers }

# Export results to CSV
$missingUsers | Select-Object UserPrincipalName, Name, Enabled, Title, Department, DistinguishedName, LastLogonDate | Export-Csv -Path "C:\temp\Distlist.csv" -NoTypeInformation