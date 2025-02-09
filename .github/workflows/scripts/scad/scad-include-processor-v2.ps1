# Params for the script
param (
    [Parameter(Mandatory = $true)]
    [string[]]$pathArray,  # The input path (file or folder)

    [Parameter(Mandatory = $false)]
    [string]$outputFolderPath # Default to "output" folder in the same directory as the input file
)

# Define classes
class ScadFile {
    [string]$Path
    [string]$Content
    [string]$Name
    [bool]$IsProcessed
    [Import[]]$Imports
    [Import[]]$Includes
    [Import[]]$Uses
    [Logic[]]$Modules
    [Logic[]]$Functions

    # Default constructor
    ScadFile() {}

    # Constructor with path and content
    ScadFile([string]$path, [string]$content) {
        $this.Path = $path
        $this.Content = $content
        $this.Name = Split-Path $path -Leaf
        $this.IsProcessed = $false
        $this.Imports = @()
        $this.Includes = @()
        $this.Uses = @()
        $this.Modules = @()
        $this.Functions = @()
    }
}

class Import {
    [string]$Content
    [string]$Name
    [string]$Path
    [Logic[]]$Modules
    [Logic[]]$Functions
    [ImportType]$Type
    

    # Default constructor
    Import([string]$name, [ImportType]$type) {
        $this.Name = $name
        $this.Content = $null
        $this.Path = $null
        $this.Modules = @()
        $this.Functions = @()
        $this.Type = $type
    }

    Import([string]$name, [string]$content, [string]$path, [ImportType]$type) {
        $this.Name = $name
        $this.Content = $content
        $this.Path = $path
        $this.Modules = @()
        $this.Functions = @()
        $this.Type = $type
    }
}

class Include {
    [string]$Content
    [string]$Name
    [string]$Path
    [Logic[]]$Modules
    [Logic[]]$Functions
    [ImportType]$Type
    

    # Default constructor
    Include([string]$name) {
        $this.Name = $name
        $this.Content = $null
        $this.Path = $null
        $this.Modules = @()
        $this.Functions = @()
    }

    Include([string]$name, [string]$content, [string]$path) {
        $this.Name = $name
        $this.Content = $content
        $this.Path = $path
        $this.Modules = @()
        $this.Functions = @()
        $this.Type = Type.Unknown
    }
}

class Logic {
    [string]$Name
    [string]$Content
    [LogicType]$Type

    Logic() {}

    Logic([string]$name, [string]$content, [LogicType]$type) {
        $this.Name = $name
        $this.Content = $content
        $this.Type = $type
    }
}

enum ImportType {
    Unknown
    Include
    Use
}

enum LogicType {
    Unknown
    Module
    Function
}

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

    $scadFile.Modules = Get-ModulesFromFile -filePath $scadFile.Path
    $scadFile.Functions = Get-FunctionsFromFile -filePath $scadFile.Path

    # $scadFile.Modules = Get-LogicParts-From-ScadFileContent -Content $scadFile.Content -Type Module
    # $scadFile.Functions = Get-LogicParts-From-ScadFileContent -Content $scadFile.Content -Type Function

    if (-not $scadFile) {
        Write-Error "Failed to create ScadFile object for file: $filePath"
        return
    }
    

    # Get the include names from the file content
    # $scadFile.Includes = Get-Includes-From-ScadFile -scadFile $scadFile
    # $includes = Get-Includes-From-ScadFile -Content $scadFile.Content
    # if (-not $includes) {
    #     $includes = @()
    # }
    $includes = Get-Imports-From-ScadFile -scadFile $scadFile -type Include
    if (-not $includes) {
        $includes = @()
    }
    $uses = Get-Imports-From-ScadFile -scadFile $scadFile -type Use
    if (-not $uses) {
        $uses = @()
    }

    $scadFile.Imports = $includes + $uses

    $scadFile.Includes = Get-Imports-From-ScadFile -scadFile $scadFile -type Include
    $scadFile.Uses = Get-Imports-From-ScadFile -scadFile $scadFile -type Use
    Write-Host "Retrived Includes"

    # $includes = Read-ImportsFromScadFile -scadFile $scadFile -type Include
    # $uses = Read-ImportsFromScadFile -scadFile $scadFile -type Use

    $imports = Read-ImportsFromScadFile -scadFile $scadFile
    if (-not $imports) {
        $imports = @()
    }
    $scadFile.Imports = $imports

    # $scadFile.Includes = Read-ImportsFromScadFile -scadFile $scadFile -type Include
    # $scadFile.Uses = Read-ImportsFromScadFile -scadFile $scadFile -type Use

    # Read the content of each include and put it in an Include object
    # $includeFiles = Read-IncludeFiles -scadFile $scadFile
    # Write-Host "Read Includes"

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

    if ($scadFile.Imports.Count -eq 0) {
        Write-Host "No imports found for $($scadFile.Name). Returning original content."
        $scadFile.IsProcessed = $true
        return $scadFile
    }

    $newContent = $scadFile.Content

    # Remove the include line from the content of the ScadFile where the include was found only if the include has content
    foreach ($import in $scadFile.Imports) {
        if ($import.Content) {
            
            if ($import.Type -eq [ImportType]::Include) {
                $pattern = "include\s+<($($import.Name))>\s*(\r?\n|\r)?"
                $replacement = "`n`n// === Include: $($import.Name) === `n`n$($import.Content)`n`n// === End Include: $($import.Name) ===`n`n"
            }
            elseif ($import.Type -eq [ImportType]::Use) {
                $pattern = "use\s+<($($import.Name))>\s*(\r?\n|\r)?"
                # for use, only need to add the content of modules and functions
                $moduleContent = $import.Modules | ForEach-Object { $_.Content } -join "`n"
                $functionContent = $import.Functions | ForEach-Object { $_.Content } -join "`n"
                $replacement = "`n`n// === Use: $($import.Name) === `n`n$($moduleContent)`n`n$($functionContent)`n`n// === End Use: $($import.Name) ===`n`n"
            }
            else {
                Write-Warning "Unknown import type: $($import.Type)"
                continue
            }
            
            # Replace include statement with actual content, preserving the structure
            $newContent = $newContent -replace $pattern, $replacement
        }
    }

    $scadFile.Content = $newContent
    $scadFile.IsProcessed = $true

    return $scadFile
}

function Read-ImportsFromScadFile {
    param (
        [ScadFile]$scadFile
        # ,
        # [ImportType]$type
    )

    $scadDirectory = Split-Path -Path $scadFile.Path

    $importArrary = @()

    foreach ($import in $scadFile.Imports) {
        $processingImport = $import
        try {
            $found = Find-File -directory $scadDirectory -fileName $processingImport.Name

            if ($found) {
                Write-Verbose "Found include file: $import.Name at $($found.FullName)"

                $foundImport = New-Object Import -ArgumentList @($import.Name, $import.Type)

                $foundImport.Path = $found.FullName
                $foundImport.Content = Get-Content -Path $found.FullName -Raw
                $foundImport.Modules = Get-ModulesFromFile -filePath $found.FullName
                if (-not $foundImport.Modules) {
                    $foundImport.Modules = @()
                }
                $foundImport.Functions = Get-FunctionsFromFile -filePath $found.FullName
                if (-not $foundImport.Functions) {
                    $foundImport.Functions = @()
                }

                $importArrary += $foundImport
            }
        } catch {
            Write-Warning "Could not read file: $($import.Name) . $_"
        }
    }

    return $importArrary

    # if ($type -eq [ImportType]::Include) {
    #     $imports = $scadFile.Includes
    # } elseif ($type -eq [ImportType]::Use) {
    #     $imports = $scadFile.Uses
    # } else {
    #     Write-Warning "Unknown import type: $type"
    #     return $importArrary
    # }

    # foreach ($import in $imports) {
    #     $processingImport = $import
    #     try {
    #         $found = Find-File -directory $scadDirectory -fileName $processingImport.Name

    #         if ($found) {
    #             Write-Verbose "Found include file: $import.Name at $($found.FullName)"

    #             $foundImport = New-Object Import -ArgumentList @($import.Name, $type)

    #             # Create and populate an Include object
    #             $foundImport.Path = $found.FullName
    #             $foundImport.Content = Get-Content -Path $found.FullName -Raw
    #             $foundImport.Modules = Get-ModulesFromFile -filePath $found.FullName
    #             if (-not $foundImport.Modules) {
    #                 $foundImport.Modules = @()
    #             }
    #             $foundImport.Functions = Get-FunctionsFromFile -filePath $found.FullName
    #             if (-not $foundImport.Functions) {
    #                 $foundImport.Functions = @()
    #             }

    #             $importArrary += $foundImport
    #         }
    #     } catch {
    #         Write-Warning "Could not read file: $($import.Name) . $_"
    #     }
    # }

    # return $importArrary
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
                $include = New-Object Include -ArgumentList $includeName
                $include.Path = $found.FullName
                $include.Content = Get-Content -Path $found.FullName -Raw
                $include.Modules = Get-ModulesFromFile -filePath $include.Path
                $include.Functions = Get-FunctionsFromFile -filePath $include.Path
                $include.Type = [ImportType]::Include

                $includeArrary += $include
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
            (Get-ChildItem -Path $directory -Directory -Recurse -ErrorAction SilentlyContinue | ForEach-Object { $_.FullName }),
    
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

function Get-Imports-From-ScadFile {
    param (
        [ScadFile]$scadFile,
        [ImportType]$type
    )

    $importArray = @()

     # Split content into lines and find all matches
    $includeMatches = $scadFile.Content | Select-String -Pattern "$($type.ToString().ToLower())\s+<(.+?)>" -AllMatches

    # Extract each match
    foreach ($match in $includeMatches) {
        foreach ($group in $match.Matches) {
            # Add the include to the array of includes. create an Include object with the name of the include
            $includeName = $group.Groups[1].Value

            $import = New-Object Import -ArgumentList @($includeName, $type)

            # Add the include to the array of includes
            $importArray += $import
        }
    }

    Write-Verbose "Total $($type) found: $($importArray.Count)"
    return $importArray
}

function Get-ModulesFromFile {
    param (
        [string]$filePath
    )

    $modules = @()
    $currentModule = $null
    $currentContent = @()

    foreach ($line in Get-Content -Path $filePath) {
        if ($line -match 'module\s+(\w+)\s*\(') {
            if ($currentModule) {
                # Updated to use enum value [LogicType]::Module instead of Module class
                $modules += New-Object Logic -ArgumentList $currentModule, ($currentContent -join "`n"), [LogicType]::Module
            }
            $currentModule = $matches[1]
            $currentContent = @($line)
        } elseif ($currentModule) {
            $currentContent += $line
        }
    }

    if ($currentModule) {
        $modules += New-Object Logic -ArgumentList $currentModule, ($currentContent -join "`n"), [LogicType]::Module
    }

    return $modules
    # ...existing code...
}

function Get-FunctionsFromFile {
    param (
        [string]$filePath
    )

    $functions = @()
    $currentFunction = $null
    $currentContent = @()

    foreach ($line in Get-Content -Path $filePath) {
        if ($line -match 'function\s+(\w+)\s*\(') {
            if ($currentFunction) {
                # Updated to use enum value [LogicType]::Function instead of Function class
                $functionObject = New-Object Logic -ArgumentList $currentFunction, ($currentContent -join "`n"), [LogicType]::Function
                $functions += $functionObject
            }
            $currentFunction = $matches[1]
            $currentContent = @($line)
        } elseif ($currentFunction) {
            $currentContent += $line
        }
    }

    if ($currentFunction) {
        $functionObject = New-Object Logic -ArgumentList $currentFunction, ($currentContent -join "`n"), [LogicType]::Function
        $functions += $functionObject
    }

    return $functions
    # ...existing code...
}

function Get-LogicParts-From-ScadFileContent {
    param (
        [string]$Content,
        [LogicType]$Type
    )

    $logicArrary = @()
    $currentLogic = $null
    $currentContent = @()

    if ($Type -eq [LogicType]::Module) {
        $regex = 'module\s+(\w+)\s*\('
    }
    elseif ($Type -eq [LogicType]::Function) {
        $regex = 'function\s+(\w+)\s*\('
    }
    else {
        Write-Warning "Unknown logic type: $Type"
        return $logicArrary
    }

    foreach ($line in $Content) {
        if ($line -match $regex) {
            if ($currentLogic) {
                $logicArrary += New-Object Logic -ArgumentList $currentLogic, ($currentContent -join "`n"), $Type
            }
            $currentLogic = $matches[1]
            $currentContent = @($line)
        } elseif ($currentLogic) {
            $currentContent += $line
        }
    }

    if ($currentLogic) {
        $logicArrary += New-Object Logic -ArgumentList $currentLogic, ($currentContent -join "`n"), $Type
    }

    return $logicArrary
}
# ...existing code...

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

foreach ($path in $pathArray) {
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