# Import the Active Directory module
Import-Module ActiveDirectory

# Define the thresholds for inactive computers (e.g., 90 days)
$inactiveThreshold = (Get-Date).AddDays(-90)

# Fetch all computer objects from Active Directory
$computers = Get-ADComputer -Filter * -Property Name, DistinguishedName, Enabled, LastLogonDate

# Initialize arrays to hold categorized computer objects
$normalComputers = @()
$inactiveComputers = @()
$disabledComputers = @()

# Categorize the computer objects
foreach ($computer in $computers) {
if (-not $computer.Enabled) {
$disabledComputers += $computer
} elseif ($computer.LastLogonDate -lt $inactiveThreshold) {
$inactiveComputers += $computer
} else {
$normalComputers += $computer
}
}

# Function to create a custom object for export
function Set-CustomObject {
param (
[array]$Computers,
[string]$Category
)
$result = @()
foreach ($computer in $Computers) {
$obj = [PSCustomObject]@{
Name = $computer.Name
DistinguishedName = $computer.DistinguishedName
Category = $Category
}
$result += $obj
}
return $result
}

# Combine all results
$allResults = @()
$allResults += Set-CustomObject -Computers $normalComputers -Category "Normal"
$allResults += Set-CustomObject -Computers $inactiveComputers -Category "Inactive"
$allResults += Set-CustomObject -Computers $disabledComputers -Category "Disabled"

# Export to CSV
$csvPath = "C:\Temp\ADComputerCategories.csv"
$allResults | Export-Csv -Path $csvPath -NoTypeInformation

# Function to display the results in a colored table
function Show-Results {
param (
[array]$Computers,
[string]$Category,
[string]$Color
)

Write-Host "$Category Computers:" -ForegroundColor $Color
$Computers | Format-Table Name, DistinguishedName, @{Name="Category"; Expression = {$Category}} -AutoSize
Write-Host ""
}

# Display the results
Show-Results -Computers $normalComputers -Category "Normal" -Color "Green"
Show-Results -Computers $inactiveComputers -Category "Inactive" -Color "Yellow"
Show-Results -Computers $disabledComputers -Category "Disabled" -Color "Red"

Write-Host "Results exported to $csvPath"