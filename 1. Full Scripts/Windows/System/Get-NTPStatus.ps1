##########################################
# AUTHOR    : Ryan Mutschler
# DATE      : 4-21-2025
# EDIT      : 4-21-2025
# PURPOSE   : PowerShell script to query w32tm configuration, local time, and timezone on multiple servers and export to CSV
# REPOSITORY: 
# WIKIPEDIA : 
#
# VERSION   : 1.0     (Initial release)
##########################################

# Define the path for the output CSV file
$outputFile = "C:\Temp\W32TimeConfig_Results.csv"

# Define list of servers to query
# Replace these with your actual server names
$servers = @(
    "Server1",
    "Server2",
    "Server3"
    # Add more servers as needed
)

# Create an array to store results
$results = @()

# Loop through each server
foreach ($server in $servers) {
    Write-Host "Querying time configuration on $server..." -ForegroundColor Cyan
    
    try {
        # Get the local time and timezone info from the server
        $timeInfo = Invoke-Command -ComputerName $server -ScriptBlock {
            $timeZone = Get-TimeZone
            [PSCustomObject]@{
                CurrentTime = Get-Date
                TimeZoneId = $timeZone.Id
                TimeZoneName = $timeZone.DisplayName
                StandardName = $timeZone.StandardName
                DaylightName = $timeZone.DaylightName
                BaseUtcOffset = $timeZone.BaseUtcOffset.ToString()
            }
        } -ErrorAction Stop
        
        # Execute the w32tm command remotely
        $output = Invoke-Command -ComputerName $server -ScriptBlock {
            & w32tm /query /configuration
        } -ErrorAction Stop
        
        # Initialize variables to store configuration values
        $timeConfig = [PSCustomObject]@{
            ServerName = $server
            LocalTime = $timeInfo.CurrentTime
            TimeZoneId = $timeInfo.TimeZoneId
            TimeZoneName = $timeInfo.TimeZoneName
            StandardName = $timeInfo.StandardName
            DaylightName = $timeInfo.DaylightName
            BaseUtcOffset = $timeInfo.BaseUtcOffset
            EventLogFlags = ""
            AnnounceFlags = ""
            TimeJumpAuditOffset = ""
            MinPollInterval = ""
            MaxPollInterval = ""
            MaxNegPhaseCorrection = ""
            MaxPosPhaseCorrection = ""
            MaxAllowedPhaseOffset = ""
            FrequencyCorrectRate = ""
            PollAdjustFactor = ""
            LargePhaseOffset = ""
            SpikeWatchPeriod = ""
            LocalClockDispersion = ""
            HoldPeriod = ""
            PhaseCorrectRate = ""
            UpdateInterval = ""
            NtpServer = ""
            Type = ""
            Enabled = ""
        }
        
        # Parse the output and extract the configuration values
        foreach ($line in $output) {
            if ($line -match "EventLogFlags:\s+(\d+)") {
                $timeConfig.EventLogFlags = $matches[1]
            }
            elseif ($line -match "AnnounceFlags:\s+(\d+)") {
                $timeConfig.AnnounceFlags = $matches[1]
            }
            elseif ($line -match "TimeJumpAuditOffset:\s+(\d+)") {
                $timeConfig.TimeJumpAuditOffset = $matches[1]
            }
            elseif ($line -match "MinPollInterval:\s+(\d+)") {
                $timeConfig.MinPollInterval = $matches[1]
            }
            elseif ($line -match "MaxPollInterval:\s+(\d+)") {
                $timeConfig.MaxPollInterval = $matches[1]
            }
            elseif ($line -match "MaxNegPhaseCorrection:\s+(\d+)") {
                $timeConfig.MaxNegPhaseCorrection = $matches[1]
            }
            elseif ($line -match "MaxPosPhaseCorrection:\s+(\d+)") {
                $timeConfig.MaxPosPhaseCorrection = $matches[1]
            }
            elseif ($line -match "MaxAllowedPhaseOffset:\s+(\d+)") {
                $timeConfig.MaxAllowedPhaseOffset = $matches[1]
            }
            elseif ($line -match "FrequencyCorrectRate:\s+(\d+)") {
                $timeConfig.FrequencyCorrectRate = $matches[1]
            }
            elseif ($line -match "PollAdjustFactor:\s+(\d+)") {
                $timeConfig.PollAdjustFactor = $matches[1]
            }
            elseif ($line -match "LargePhaseOffset:\s+(\d+)") {
                $timeConfig.LargePhaseOffset = $matches[1]
            }
            elseif ($line -match "SpikeWatchPeriod:\s+(\d+)") {
                $timeConfig.SpikeWatchPeriod = $matches[1]
            }
            elseif ($line -match "LocalClockDispersion:\s+(\d+)") {
                $timeConfig.LocalClockDispersion = $matches[1]
            }
            elseif ($line -match "HoldPeriod:\s+(\d+)") {
                $timeConfig.HoldPeriod = $matches[1]
            }
            elseif ($line -match "PhaseCorrectRate:\s+(\d+)") {
                $timeConfig.PhaseCorrectRate = $matches[1]
            }
            elseif ($line -match "UpdateInterval:\s+(\d+)") {
                $timeConfig.UpdateInterval = $matches[1]
            }
            elseif ($line -match "NtpServer:\s+(.+?)\s+\(") {
                $timeConfig.NtpServer = $matches[1]
            }
            elseif ($line -match "Type:\s+(.+?)\s+\(") {
                $timeConfig.Type = $matches[1]
            }
            elseif ($line -match "Enabled:\s+(\d+)") {
                $timeConfig.Enabled = $matches[1]
            }
        }
        
        # Add the server's config to the results array
        $results += $timeConfig
        
        Write-Host "Successfully queried $server" -ForegroundColor Green
    }
    catch {
        Write-Host "Failed to query $server. Error: $_" -ForegroundColor Red
        
        # Add a record with the server name and error
        $results += [PSCustomObject]@{
            ServerName = $server
            LocalTime = "ERROR"
            TimeZoneId = "ERROR"
            TimeZoneName = "ERROR"
            StandardName = "ERROR"
            DaylightName = "ERROR"
            BaseUtcOffset = "ERROR"
            EventLogFlags = "ERROR"
            AnnounceFlags = "ERROR"
            TimeJumpAuditOffset = "ERROR"
            MinPollInterval = "ERROR"
            MaxPollInterval = "ERROR"
            MaxNegPhaseCorrection = "ERROR"
            MaxPosPhaseCorrection = "ERROR"
            MaxAllowedPhaseOffset = "ERROR"
            FrequencyCorrectRate = "ERROR"
            PollAdjustFactor = "ERROR"
            LargePhaseOffset = "ERROR"
            SpikeWatchPeriod = "ERROR"
            LocalClockDispersion = "ERROR"
            HoldPeriod = "ERROR"
            PhaseCorrectRate = "ERROR"
            UpdateInterval = "ERROR"
            NtpServer = "ERROR"
            Type = "ERROR"
            Enabled = "ERROR"
        }
    }
}

# Export the results to CSV
$results | Export-Csv -Path $outputFile -NoTypeInformation

Write-Host "`nProcess completed. Results exported to $outputFile" -ForegroundColor Yellow