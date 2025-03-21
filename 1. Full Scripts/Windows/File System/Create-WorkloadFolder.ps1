##########################################
# AUTHOR    : Ryan Mutschler
# DATE      : 3-19-2025
# EDIT      : 3-21-2025
# PURPOSE   : This script creates folders for Changes, Incidents, or Projects following the specified naming convention
# REPOSITORY: https://github.com/MutschlerHomeTech/Public-Scripts/blob/master/1.%20Full%20Scripts/Windows/File%20System/Create-WorkloadFolder.ps1
# WIKIPEDIA : https://wikipedia.mutschlerhome.com/books/windows-scripts/page/create-workloadfolder-v12
#
# VERSION   : 1.0     (Initial release)
# VERSION   : 1.1     (URL subfolder creation)
# VERSION   : 1.2     (Communications subfolder creation)
# VERSION   : 1.3     (Added illegal character handling)
##########################################

# Function to check for illegal Windows folder name characters
function Test-IllegalCharacters {
    param (
        [string]$FolderName
    )
    
    return $FolderName -match '[\\\/\:\*\?\"\<\>\|]'
}

# Function to remove illegal Windows folder name characters
function Remove-IllegalCharacters {
    param (
        [string]$FolderName
    )
    
    # Replace illegal characters with underscores or appropriate alternatives
    $cleanName = $FolderName -replace '[\\\/\:\*\?\"\<\>\|]', '_'
    return $cleanName
}

# Get the base workload folder path by reading from the Windows Registry
try {
    # Get the Documents folder path from Registry
    $documentsPath = (Get-ItemProperty -Path "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\User Shell Folders" -Name "Personal").Personal
    
    # Expand environment variables if they exist in the path
    $documentsPath = [System.Environment]::ExpandEnvironmentVariables($documentsPath)
    
    # Build the workload path
    $workloadBasePath = Join-Path -Path $documentsPath -ChildPath "Workload"
}
catch {
    Write-Host "Error accessing Registry. Falling back to default Documents location." -ForegroundColor Yellow
    $workloadBasePath = Join-Path -Path $env:USERPROFILE -ChildPath "Documents\Workload"
}

# Check if the workload folder exists, create it if not
if (-not (Test-Path -Path $workloadBasePath)) {
    Write-Host "Creating base Workload folder structure..."
    New-Item -Path $workloadBasePath -ItemType Directory | Out-Null
    
    # Create main category folders
    $categories = @("Changes", "Incidents", "Projects")
    foreach ($category in $categories) {
        $categoryPath = Join-Path -Path $workloadBasePath -ChildPath $category
        New-Item -Path $categoryPath -ItemType Directory | Out-Null
        
        # Create subcategories based on the parent folder
        $subcategories = @()
        switch ($category) {
            "Changes" {
                $subcategories = @(
                    "1. Discovery", 
                    "2. Testing", 
                    "3. Implementation", 
                    "4. Completed", 
                    "99. Uncategorized"
                )
            }
            "Incidents" {
                $subcategories = @(
                    "1. Investigation", 
                    "2. On Hold", 
                    "3. Resolved", 
                    "99. Uncategorized"
                )
            }
            "Projects" {
                $subcategories = @(
                    "1. Discovery", 
                    "2. Implementation", 
                    "3. Maintenance", 
                    "4. Decommissioned", 
                    "99. Uncategorized"
                )
            }
        }
        
        # Create each subcategory folder
        foreach ($subcategory in $subcategories) {
            $subcategoryPath = Join-Path -Path $categoryPath -ChildPath $subcategory
            New-Item -Path $subcategoryPath -ItemType Directory | Out-Null
        }
    }
    Write-Host "Base folder structure created successfully."
}

# Main script execution starts here
Write-Host "=== Workload Folder Creation Tool ===" -ForegroundColor Cyan
Write-Host "This script will create a new folder for your workload item."

# Prompt for workload type
$validSelection = $false
$workloadType = ""
$prefix = ""

while (-not $validSelection) {
    Write-Host "`nSelect the type of workload:" -ForegroundColor Yellow
    Write-Host "1. Change"
    Write-Host "2. Incident"
    Write-Host "3. Project"
    $selection = Read-Host "Enter your selection (1-3)"
    
    switch ($selection) {
        "1" {
            $workloadType = "Changes"
            $prefix = "RMCHG"
            $validSelection = $true
        }
        "2" {
            $workloadType = "Incidents"
            $prefix = "RMINC"
            $validSelection = $true
        }
        "3" {
            $workloadType = "Projects"
            $prefix = "RMPRJ"
            $validSelection = $true
        }
        default {
            Write-Host "Invalid selection. Please enter a number between 1 and 3." -ForegroundColor Red
        }
    }
}

# Get the workload name
$workloadName = ""
$validName = $false
while (-not $validName) {
    $workloadName = Read-Host "Enter the name of the $($workloadType.TrimEnd('s'))"
    
    if ([string]::IsNullOrWhiteSpace($workloadName)) {
        Write-Host "Name cannot be empty. Please enter a valid name." -ForegroundColor Red
    } 
    elseif ($workloadName -match "\/") {
        # Found forward slash, ask user what to do
        Write-Host "`nThe name contains a forward slash (/), which can create subfolders." -ForegroundColor Yellow
        Write-Host "1. Create subfolders (e.g., 'folder/subfolder' creates 'folder' with 'subfolder' inside)"
        Write-Host "2. Remove illegal characters and use a single folder"
        $slashChoice = Read-Host "Enter your choice (1-2)"
        
        if ($slashChoice -eq "1") {
            # User wants subfolders, proceed with the name as is
            $validName = $true
        }
        else {
            # User wants to remove illegal characters
            #$originalName = $workloadName
            $workloadName = Remove-IllegalCharacters -FolderName $workloadName
            Write-Host "Cleaned name: '$workloadName'" -ForegroundColor Cyan
            $confirmName = Read-Host "Is this acceptable? (Y/N)"
            if ($confirmName.ToUpper() -eq "Y") {
                $validName = $true
            }
        }
    }
    elseif (Test-IllegalCharacters -FolderName $workloadName) {
        # Other illegal characters found
        Write-Host "The name contains illegal Windows folder characters." -ForegroundColor Yellow
        #$originalName = $workloadName
        $workloadName = Remove-IllegalCharacters -FolderName $workloadName
        Write-Host "Cleaned name: '$workloadName'" -ForegroundColor Cyan
        $confirmName = Read-Host "Is this acceptable? (Y/N)"
        if ($confirmName.ToUpper() -eq "Y") {
            $validName = $true
        }
    }
    else {
        $validName = $true
    }
}

# Get current date in the required format (YYMMdd)
$currentDate = Get-Date -Format "yyMMdd"

# Determine the next available sequence number
function Get-NextSequenceNumber {
    param (
        [string]$TargetPath,
        [string]$Prefix,
        [string]$Date
    )
    
    # Get all folders that match the pattern for today in the target path only
    $pattern = "$Prefix$Date*"
    $existingFolders = Get-ChildItem -Path $TargetPath -Directory | 
                      Where-Object { $_.Name -like $pattern }
    
    if ($existingFolders.Count -eq 0) {
        # No folders exist for today, start with 001
        return "001"
    }
    
    # Extract sequence numbers from existing folders
    $sequenceNumbers = @()
    foreach ($folder in $existingFolders) {
        if ($folder.Name -match "$Prefix$Date(\d{3})") {
            $sequenceNumbers += [int]$matches[1]
        }
    }
    
    if ($sequenceNumbers.Count -eq 0) {
        # No sequence numbers found, start with 001
        return "001"
    }
    
    # Find the highest sequence number and increment by 1
    $nextNumber = ($sequenceNumbers | Measure-Object -Maximum).Maximum + 1
    return $nextNumber.ToString("000")
}

# Get the next sequence number for the specific subcategory folder
$sequenceNumber = Get-NextSequenceNumber -TargetPath $subcategoryPath -Prefix $prefix -Date $currentDate

# Build the folder name with sequence number
$folderName = "$prefix$currentDate$sequenceNumber - $workloadName"

# Prompt for subcategory
Write-Host "`nSelect the subcategory:" -ForegroundColor Yellow
$subcategories = @()
switch ($workloadType) {
    "Changes" {
        Write-Host "1. Discovery"
        Write-Host "2. Testing"
        Write-Host "3. Implementation"
        Write-Host "4. Completed"
        Write-Host "5. Uncategorized"
        $subcategories = @(
            "1. Discovery", 
            "2. Testing", 
            "3. Implementation", 
            "4. Completed", 
            "99. Uncategorized"
        )
    }
    "Incidents" {
        Write-Host "1. Investigation"
        Write-Host "2. On Hold"
        Write-Host "3. Resolved"
        Write-Host "4. Uncategorized"
        $subcategories = @(
            "1. Investigation", 
            "2. On Hold", 
            "3. Resolved", 
            "99. Uncategorized"
        )
    }
    "Projects" {
        Write-Host "1. Discovery"
        Write-Host "2. Implementation"
        Write-Host "3. Maintenance"
        Write-Host "4. Decommissioned"
        Write-Host "5. Uncategorized"
        $subcategories = @(
            "1. Discovery", 
            "2. Implementation", 
            "3. Maintenance", 
            "4. Decommissioned", 
            "99. Uncategorized"
        )
    }
}

$validSubcategory = $false
$subcategoryPath = ""

while (-not $validSubcategory) {
    $maxOption = if ($workloadType -eq "Incidents") { 4 } else { 5 }
    $subcategorySelection = Read-Host "Enter your selection (1-$maxOption)"
    
    $subcategoryIndex = [int]$subcategorySelection - 1
    
    # Handle "Uncategorized" as special case
    if ($subcategorySelection -eq $maxOption.ToString()) {
        $subcategoryIndex = $subcategories.Count - 1
    }
    
    if ($subcategoryIndex -ge 0 -and $subcategoryIndex -lt $subcategories.Count) {
        $subcategoryPath = Join-Path -Path $workloadBasePath -ChildPath "$workloadType\$($subcategories[$subcategoryIndex])"
        $validSubcategory = $true
    }
    else {
        Write-Host "Invalid selection. Please enter a number between 1 and $maxOption." -ForegroundColor Red
    }
}

# Create the full path for the new folder
$newFolderPath = Join-Path -Path $subcategoryPath -ChildPath $folderName

# Check if the folder already exists
if (Test-Path -Path $newFolderPath) {
    Write-Host "`nWarning: A folder with this name already exists at this location." -ForegroundColor Yellow
    $confirmation = Read-Host "Would you like to create it anyway? (Y/N)"
    
    if ($confirmation.ToUpper() -ne "Y") {
        Write-Host "Operation cancelled by user." -ForegroundColor Red
        exit
    }
}

# Create the folder
try {
    # Create the main workload folder
    New-Item -Path $newFolderPath -ItemType Directory | Out-Null
    
    # Create subfolders within the new workload folder
    $urlFolderPath = Join-Path -Path $newFolderPath -ChildPath "URL"
    $commsFolderPath = Join-Path -Path $newFolderPath -ChildPath "Communications"
    
    New-Item -Path $urlFolderPath -ItemType Directory | Out-Null
    New-Item -Path $commsFolderPath -ItemType Directory | Out-Null
    
    Write-Host "`nSuccess! Created folder:" -ForegroundColor Green
    Write-Host $newFolderPath
    Write-Host "Subfolders created:"
    Write-Host "- URL: $urlFolderPath"
    Write-Host "- Communications: $commsFolderPath"
    
    # Open the folder in Explorer
    $openFolder = Read-Host "Would you like to open the folder now? (Y/N)"
    if ($openFolder.ToUpper() -eq "Y") {
        Invoke-Item -Path $newFolderPath
    }
}
catch {
    Write-Host "`nError creating folder: $_" -ForegroundColor Red
}
