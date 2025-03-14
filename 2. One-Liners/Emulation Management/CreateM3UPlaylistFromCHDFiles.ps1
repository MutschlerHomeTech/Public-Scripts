# Get the current directory
$folderPath = Get-Location
# Remove existing .m3u files in the current directory
Get-ChildItem -Path $folderPath -Filter *.m3u | Remove-Item -Force
# Get all .chd files in the current directory
$chdFiles = Get-ChildItem -Path $folderPath -Filter *.chd
# Group .chd files by base name (without the disc part and extension)
$groupedFiles = $chdFiles | Group-Object { $_.BaseName -replace '\s+\(Disc\s+\d+\)$', '' }
foreach ($group in $groupedFiles) {
# Determine the .m3u file name (without disc number and extension)
$m3uFileName = Join-Path $folderPath ($group.Name + ".m3u")
# Create or overwrite the .m3u file and write each .chd file name to it
$group.Group | ForEach-Object {Add-Content -Path $m3uFileName -Value $_.Name}}