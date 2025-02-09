param (
    [Parameter(Mandatory = $true)]
    [string[]]$pathArray,  # The input path (file or folder)

    [Parameter(Mandatory = $false)]
    [string]$outputFolderPath # Default to "output" folder in the same directory as the input file
)

function Invoke-ProcessScadFilesInFolder {
    param (
        [string]$folderPath,
        [string]$outputFolderPath
    )

    $scadFiles = Get-ChildItem -Path $folderPath -Filter "*.scad" -Recurse
    foreach ($scadFile in $scadFiles) {
        Invoke-ProcessScadFile -filePath $scadFile.FullName -outputFolderPath $outputFolderPath
    }
}

function Invoke-ProcessScadFile {
    param (
        [string]$filePath,
        [string]$outputFolderPath
    )

    Write-Host "Processing file: $filePath"

    $fileDetails = Get-Item -Path $filePath

    # Read the file content and put it in a Scadfile object
    $fileContent = Get-Content -Path $filePath -Raw

    $scadFile = New-Object ScadFile -ArgumentList $fileDetails.FullName, $fileContent

    if (-not $scadFile) {
        Write-Error "Failed to create ScadFile object for file: $filePath"
        return
    }

    # Get the include names from the file content
    $scadFile.Includes = Get-Includes-From-ScadFile -scadFile $scadFile
    Write-Host "Retrived Includes"

    # Read the content of each include and put it in an Include object
    $includeFiles = Read-IncludeFiles -scadFile $scadFile
    Write-Host "Read Includes"

    # Write the new content to the file
    $newScadFile = New-ScadFile -scadFile $scadFile -includeFiles $includeFiles
    Write-Host "New Scad File Created"

    # Write the new content to a new file in the output folder
    Publish-ScadFile-To-Output -scadFile $newScadFile -outputFolderPath $outputFolderPath

    Write-Host "Finished Processing file:" $scadFile.Name
}

function Publish-ScadFile-To-Output {
    param (
        [ScadFile]$scadFile,
        [string]$outputFolderPath
    )

    $repoRoot = (Get-Location).Path
    $filePath = $scadFile.Path
    
    # Ensure the file path is absolute
    if (-not (Test-Path -Path $filePath -PathType Leaf)) {
        $filePath = Join-Path -Path $repoRoot -ChildPath $filePath
    }

    if ($filePath.Length -le $repoRoot.Length) {
        Write-Error "The file path is shorter than or equal to the repository root path."
        return
    }

    # Calculate the relative path from the repository root
    $relativePath = $filePath.Substring($repoRoot.Length).TrimStart('\', '/')
    $outputFilePath = Join-Path -Path $outputFolderPath -ChildPath $relativePath
    Write-Host "Publishing file to: $outputFilePath"

    # Ensure the directory for the output file exists
    $outputDirectory = Split-Path -Path $outputFilePath -Parent
    if (-not (Test-Path -Path $outputDirectory)) {
        New-Item -ItemType Directory -Path $outputDirectory -Force | Out-Null
    }

    # Write the new content to the output file
    Set-Content -Path $outputFilePath -Value $scadFile.Content -Force
}

function New-ScadFile {
    param (
        [ScadFile]$scadFile,
        [Include[]]$includeFiles
    )

    $newContent = $scadFile.Content

    # Remove the include line from the content of the ScadFile where the include was found only if the include has content
    foreach ($include in $includeFiles) {
        if ($include.Content) {
            $pattern = "include\s+<($($include.Name -join '|'))>\s*(\r?\n|\r)?"

            # Remove matches while preserving line endings
            $newContent = $newContent -replace $pattern, ''

            # Add the content of the include to the new content at the end of the file start with a new line and a comment line with the include name for reference 
            $newContent += "`n// Include: $($include.Name)"
            $newContent += "`n$($include.Content)"
        }
    }

    $scadFile.Content = $newContent
    $scadFile.IsProcessed = $true

    return $scadFile
}

function Read-IncludeFiles {
    param (
        [ScadFile]$scadFile
    )

    $scadDirectory = Split-Path -Path $scadFile.Path

    $includeArrary = @()

    foreach ($includeName in $scadFile.Includes) {
        try {
            $found = Find-File -directory $scadDirectory -fileName $includeName

            if ($found) {
                Write-Verbose "Found include file: $includeName at $($found.FullName)"

                # Create and populate an Include object
                $include = [Include]::new($includeName)
                $include.Path = $found.FullName
                $include.Content = Get-Content -Path $found.FullName -Raw

                $includeArrary += $include
            }
            
            $foundInclude = Find-Include-File -scadDirectory $scadDirectory -includeFileName $includeName

            # check that $foundInclude is not null and is and Include object
            if ($foundInclude -and $foundInclude -is [Include]) {
                $includeArrary += $foundInclude
            }
        } catch {
            Write-Warning "Could not read file: $includeName. $_"
        }
    }

    return $includeArrary
}

function Find-File {
    param (
        [Parameter(Mandatory = $true)]
        [string]$directory,
        [Parameter(Mandatory = $true)]
        [string]$fileName
    )

        # Define search locations
        $searchLocations = @(
            # Same folder as the file
            $directory,
    
            # Subfolders within the current folder (recursive)
            (Get-ChildItem -Path $scadDirectory -Directory -Recurse -ErrorAction SilentlyContinue | ForEach-Object { $_.FullName }),
    
            # Sibling folders in the same parent directory
            (Get-ChildItem -Path $parentDirectory -Directory -ErrorAction SilentlyContinue | ForEach-Object { $_.FullName }),
    
            # Repository root
            (Get-PSDrive -Name ((Get-Item -Path $directory).PSDrive.Name)).Root
        )
    
        try {
            foreach ($location in $searchLocations) {
                # Skip null or invalid paths
                if (-not $location -or -not (Test-Path -Path $location)) {
                    continue
                }
    
                # Search for the file in the current location
                $found = Get-ChildItem -Path $location -Filter $fileName -File -ErrorAction SilentlyContinue |
                         Select-Object -First 1
    
                if ($found) {
                    Write-Verbose "Found file: $fileName at $($found.FullName)"
                    return $found
                }
            }
    
            # Log a warning if the file was not found
            Write-Warning "No file found for: $fileName"
            return $null
        }
        catch {
            # Handle unexpected errors
            Write-Warning "Error searching for include file '$includeFileName': $_"
            return $null
        }
}

function Find-Include-File {
    param (
        [Parameter(Mandatory = $true)]
        [string]$scadDirectory,

        [Parameter(Mandatory = $true)]
        [string]$includeFileName
    )

    

    # If the include already exists as an absolute path, use it directly
    if (Test-Path -Path $includeFileName -PathType Leaf) {
        return New-Object Include -ArgumentList $includeFileName, (Get-Content -Path $includeFileName -Raw), $includeFileName
    }

    # Define the parent directory
    # $parentDirectory = Split-Path -Parent $scadDirectory

    # # Define search locations
    # $searchLocations = @(
    #     # Same folder as the file
    #     $scadDirectory,

    #     # Subfolders within the current folder (recursive)
    #     (Get-ChildItem -Path $scadDirectory -Directory -Recurse -ErrorAction SilentlyContinue | ForEach-Object { $_.FullName }),

    #     # Sibling folders in the same parent directory
    #     (Get-ChildItem -Path $parentDirectory -Directory -ErrorAction SilentlyContinue | ForEach-Object { $_.FullName }),

    #     # Repository root
    #     (Get-PSDrive -Name ((Get-Item -Path $scadDirectory).PSDrive.Name)).Root
    # )


    try {
        $found = Find-File -directory $scadDirectory -fileName $includeFileName

        if ($found) {
            Write-Verbose "Found include file: $includeFileName at $($found.FullName)"

            # Create and populate an Include object
            $include = [Include]::new($includeFileName)
            $include.Path = $found.FullName
            $include.Content = Get-Content -Path $found.FullName -Raw

            return $include
        }



        # foreach ($location in $searchLocations) {
        #     # Skip null or invalid paths
        #     if (-not $location -or -not (Test-Path -Path $location)) {
        #         continue
        #     }

        #     # Search for the file in the current location
        #     $found = Get-ChildItem -Path $location -Filter $includeFileName -File -ErrorAction SilentlyContinue |
        #              Select-Object -First 1

        #     if ($found) {
        #         Write-Verbose "Found include file: $includeFileName at $($found.FullName)"

        #         # Create and populate an Include object
        #         $include = [Include]::new($includeFileName)
        #         $include.Path = $found.FullName
        #         $include.Content = Get-Content -Path $found.FullName -Raw

        #         return $include
        #     }
        # }

        # Log a warning if the file was not found
        Write-Warning "No file found for include: $includeFileName"
        return $null
    }
    catch {
        # Handle unexpected errors
        Write-Warning "Error searching for include file '$includeFileName': $_"
        return $null
    }
}

function Get-Includes-From-ScadFile {
    param (
        [ScadFile]$scadFile
    )

    $includeArray = @()

     # Split content into lines and find all matches
    $includeMatches = $scadFile.Content | Select-String -Pattern 'include\s+<(.+?)>' -AllMatches

    # Extract each match
    foreach ($match in $includeMatches) {
        foreach ($group in $match.Matches) {
            # Add the include to the array of includes. create an Include object with the name of the include
            $includeName = $group.Groups[1].Value
            # Add the include to the array of includes
            $includeArray += $includeName
        }
    }

    Write-Verbose "Total includes found: $($includeArray.Count)"
    return $includeArray
}

function Test-FolderExists {
    param (
        [string]$folderPath
    )
    if (-not (Test-Path -Path $folderPath)) {
        New-Item -ItemType Directory -Path $folderPath | Out-Null
    }
}

# Main script logic

# Set default output folder path if not provided
if (-not $outputFolderPath) {
    $repoRoot = (Get-Location).Path
    $outputFolderPath = Join-Path -Path $repoRoot -ChildPath "output"
    Write-Host "Output folder path not provided. Using default: $outputFolderPath"
}

# Ensure the output folder exists
if (-not (Test-Path -Path $outputFolderPath)) {
    New-Item -ItemType Directory -Path $outputFolderPath | Out-Null
    Write-Host "Created output folder: $outputFolderPath"
}

if (-not $pathArray -or $pathArray.Count -eq 0) {
    Write-Error "No paths provided to process."
    exit 1
}
# Check if the path is a file or a folder
Write-Host "Processing Files: $($pathArray -join ', ')"
Write-Host "Processing Files: $pathArray"
Write-Host "Type of pathArray: $($pathArray.GetType().Name)"

foreach ($path in $pathArray) {
    Write-Host "Processing Path: $path"
    
    if ([string]::IsNullOrWhiteSpace($path)) {
        Write-Warning "Skipping empty path."
        continue
    }

    if (Test-Path $path) {
        if (Test-Path $path -PathType Leaf) {
            Write-Host "Processing file: $path"
            Invoke-ProcessScadFile -filePath $path -outputFolderPath $outputFolderPath
        } elseif (Test-Path $path -PathType Container) {
            Write-Host "Processing folder: $path"
            Invoke-ProcessScadFilesInFolder -folderPath $path -outputFolderPath $outputFolderPath
        } else {
            Write-Warning "The path is neither a valid file or a folder: $path"
        }
    } else {
        Write-Warning "The provided path does not exist: $path"
    }
}

class ScadFile {
    [string]$Path
    [string]$Content
    [string]$Name
    [bool]$IsProcessed
    [array]$Includes

    # Default constructor
    ScadFile() {}

    # Constructor with path and content
    ScadFile([string]$path, [string]$content) {
        $this.Path = $path
        $this.Content = $content
        $this.Name = Split-Path $path -Leaf
        $this.IsProcessed = $false
        $this.Includes = @()
    }
}

class Include {
    [string]$Content
    [string]$Name
    [string]$Path

    # Default constructor
    Include([string]$name) {
        $this.Name = $name
        $this.Content = $null
        $this.Path = $null
    }

    Include([string]$name, [string]$content, [string]$path) {
        $this.Name = $name
        $this.Content = $content
        $this.Path = $path
    }
}