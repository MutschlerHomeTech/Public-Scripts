##########################################
# AUTHOR   : Ryan Mutschler
# DATE     : 3-14-2025
# EDIT     : 3-14-2025
# PURPOSE  : This script presents a dialog box to enter computer names, queries their AD properties, and exports to CSV
# Compatible with all PowerShell versions
# Created with assistance from claude.ai
#
# VERSION  : 1    (Initial release)
##########################################


# Load required assemblies for the GUI
Add-Type -AssemblyName System.Windows.Forms
Add-Type -AssemblyName System.Drawing

# Create the form
$form = New-Object System.Windows.Forms.Form
$form.Text = "AD Computer Properties Export"
$form.Size = New-Object System.Drawing.Size(500, 400)
$form.StartPosition = "CenterScreen"
$form.FormBorderStyle = "FixedDialog"
$form.MaximizeBox = $false

# Create label
$label = New-Object System.Windows.Forms.Label
$label.Location = New-Object System.Drawing.Point(10, 10)
$label.Size = New-Object System.Drawing.Size(480, 40)
$label.Text = "Enter computer names (one per line):"
$form.Controls.Add($label)

# Create text box for server list
$textBox = New-Object System.Windows.Forms.TextBox
$textBox.Location = New-Object System.Drawing.Point(10, 50)
$textBox.Size = New-Object System.Drawing.Size(460, 250)
$textBox.Multiline = $true
$textBox.ScrollBars = "Vertical"
$form.Controls.Add($textBox)

# Create OK button
$okButton = New-Object System.Windows.Forms.Button
$okButton.Location = New-Object System.Drawing.Point(295, 320)
$okButton.Size = New-Object System.Drawing.Size(75, 23)
$okButton.Text = "OK"
$okButton.DialogResult = [System.Windows.Forms.DialogResult]::OK
$form.AcceptButton = $okButton
$form.Controls.Add($okButton)

# Create Cancel button
$cancelButton = New-Object System.Windows.Forms.Button
$cancelButton.Location = New-Object System.Drawing.Point(380, 320)
$cancelButton.Size = New-Object System.Drawing.Size(75, 23)
$cancelButton.Text = "Cancel"
$cancelButton.DialogResult = [System.Windows.Forms.DialogResult]::Cancel
$form.CancelButton = $cancelButton
$form.Controls.Add($cancelButton)

# Show the form
$result = $form.ShowDialog()

# Process the input if OK was clicked
if ($result -eq [System.Windows.Forms.DialogResult]::OK) {
    # Get the list of computers
    $computerList = $textBox.Text -split "`r`n" | Where-Object { $_ -ne "" }
    
    # Ask for CSV output file location
    $saveFileDialog = New-Object System.Windows.Forms.SaveFileDialog
    $saveFileDialog.Filter = "CSV Files (*.csv)|*.csv|All Files (*.*)|*.*"
    $saveFileDialog.Title = "Save AD Computer Properties"
    $saveFileDialog.DefaultExt = "csv"
    $saveFileDialog.FileName = "ADComputerProperties_$(Get-Date -Format 'yyyyMMdd').csv"
    
    if ($saveFileDialog.ShowDialog() -eq [System.Windows.Forms.DialogResult]::OK) {
        $outputPath = $saveFileDialog.FileName
        
        # Create progress form
        $progressForm = New-Object System.Windows.Forms.Form
        $progressForm.Text = "Retrieving Computer Information"
        $progressForm.Size = New-Object System.Drawing.Size(400, 150)
        $progressForm.StartPosition = "CenterScreen"
        $progressForm.FormBorderStyle = "FixedDialog"
        $progressForm.ControlBox = $false
        
        $progressLabel = New-Object System.Windows.Forms.Label
        $progressLabel.Location = New-Object System.Drawing.Point(10, 20)
        $progressLabel.Size = New-Object System.Drawing.Size(380, 20)
        $progressLabel.Text = "Retrieving computer information..."
        $progressForm.Controls.Add($progressLabel)
        
        $progressBar = New-Object System.Windows.Forms.ProgressBar
        $progressBar.Location = New-Object System.Drawing.Point(10, 50)
        $progressBar.Size = New-Object System.Drawing.Size(360, 20)
        $progressBar.Minimum = 0
        $progressBar.Maximum = $computerList.Count
        $progressBar.Step = 1
        $progressForm.Controls.Add($progressBar)
        
        # Show progress form without waiting
        $progressForm.Show()
        $progressForm.Refresh()
        
        try {
            # Initialize an array to store results
            $results = @()
            $currentComputer = 0
            
            # Process each computer
            foreach ($computer in $computerList) {
                $currentComputer++
                $progressLabel.Text = "Processing computer $currentComputer of $($computerList.Count): $computer"
                $progressBar.Value = $currentComputer
                $progressForm.Refresh()
                
                try {
                    # Get all properties using Get-ADComputer
                    # This command uses -Properties * to get all properties and is compatible with all PowerShell versions
                    $adComputer = Get-ADComputer -Identity $computer -Properties * -ErrorAction Stop
                    $results += $adComputer
                }
                catch {
                    Write-Warning "Failed to retrieve information for computer '$computer': $_"
                    # Add a simple object to the results to show the error
                    $errorObject = [PSCustomObject]@{
                        Name = $computer
                        Error = $_.Exception.Message
                    }
                    $results += $errorObject
                }
            }
            
            # Export results to CSV
            $results | Export-Csv -Path $outputPath -NoTypeInformation
            
            $progressForm.Close()
            
            # Show completion message
            [System.Windows.Forms.MessageBox]::Show("Export completed to: $outputPath", "Export Complete", [System.Windows.Forms.MessageBoxButtons]::OK, [System.Windows.Forms.MessageBoxIcon]::Information)
        }
        catch {
            $progressForm.Close()
            [System.Windows.Forms.MessageBox]::Show("An error occurred: $_", "Error", [System.Windows.Forms.MessageBoxButtons]::OK, [System.Windows.Forms.MessageBoxIcon]::Error)
        }
    }
}
