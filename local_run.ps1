# Get the repository root
$repoRoot = (Get-Location).Path
Write-Host "Repository root: $repoRoot"

# Scan recursively for all .scad files
$scadFiles = Get-ChildItem -Path $repoRoot -Recurse -Filter "*.scad" -File
if (-not $scadFiles -or $scadFiles.Count -eq 0) {
    Write-Host "No SCAD files found. Exiting..."
    exit 0
}
$changedScad = $scadFiles.FullName
Write-Host "SCAD files to process: $($changedScad -join ', ')"

# Define the path to the SCAD include processor script (adjust filename if necessary)
$processorScript = Join-Path -Path $repoRoot -ChildPath ".github/workflows/scripts/scad/scad-include-processor-v2.ps1"

if (-not (Test-Path $processorScript)) {
    Write-Error "SCAD processor script not found: $processorScript"
    exit 1
}

# Set output folder path (default "output" folder in repo root)
$outputFolderPath = Join-Path -Path $repoRoot -ChildPath "output"

# Ensure output folder exists
if (-not (Test-Path -Path $outputFolderPath)) {
    New-Item -ItemType Directory -Path $outputFolderPath | Out-Null
    Write-Host "Created output folder: $outputFolderPath"
}

# Run the SCAD include processor script with all .scad files
Write-Host "Processing SCAD files..."
& $processorScript -pathArray $changedScad -outputFolderPath $outputFolderPath

Write-Host "Processing complete. Processed files are in: $outputFolderPath"
