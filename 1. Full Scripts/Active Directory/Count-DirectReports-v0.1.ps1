# AD Direct Reports Counter
# This script counts the number of direct reports for a specified user in Active Directory

param(
    [Parameter(Mandatory=$true)]
    [string]$UserIdentity,
    
    [Parameter(Mandatory=$false)]
    [switch]$Detailed
)

function Get-DirectReportsCount {
    param (
        [Parameter(Mandatory=$true)]
        [string]$Identity,
        
        [Parameter(Mandatory=$false)]
        [switch]$ShowDetails
    )
    
    try {
        # Import the Active Directory module if not already loaded
        if (-not (Get-Module -Name ActiveDirectory)) {
            Import-Module ActiveDirectory -ErrorAction Stop
        }
        
        # Get the user object from Active Directory
        $user = Get-ADUser -Identity $Identity -Properties directReports -ErrorAction Stop
        
        # Get the count of direct reports
        $directReportsCount = ($user.directReports).Count
        
        # Display the results
        Write-Host "`nUser: $($user.Name) ($($user.SamAccountName))" -ForegroundColor Cyan
        Write-Host "Total Direct Reports: $directReportsCount" -ForegroundColor Green
        
        # If detailed information is requested, list all direct reports
        if ($ShowDetails -and $directReportsCount -gt 0) {
            Write-Host "`nList of Direct Reports:" -ForegroundColor Yellow
            
            foreach ($report in $user.directReports) {
                try {
                    $reportUser = Get-ADUser -Identity $report -Properties Title, Department
                    Write-Host "  - $($reportUser.Name)" -NoNewline
                    
                    if ($reportUser.Title -or $reportUser.Department) {
                        Write-Host " (" -NoNewline
                        if ($reportUser.Title) {
                            Write-Host "$($reportUser.Title)" -NoNewline
                        }
                        if ($reportUser.Title -and $reportUser.Department) {
                            Write-Host ", " -NoNewline
                        }
                        if ($reportUser.Department) {
                            Write-Host "$($reportUser.Department)" -NoNewline
                        }
                        Write-Host ")" -NoNewline
                    }
                    Write-Host ""
                }
                catch {
                    Write-Host "  - $report (Error retrieving user details)" -ForegroundColor Red
                }
            }
        }
        
        return $directReportsCount
    }
    catch {
        Write-Host "Error: $_" -ForegroundColor Red
        return -1
    }
}

# Call the function with the provided parameters
Get-DirectReportsCount -Identity $UserIdentity -ShowDetails:$Detailed

# Example usage:
# .\Get-ADDirectReportsCount.ps1 -UserIdentity "jsmith" -Detailed
