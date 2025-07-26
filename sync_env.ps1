<#
.SYNOPSIS
    Synchronizes a parent .env file with the .env files in all immediate subdirectories.

.DESCRIPTION
    This script looks for a '.env' file in the current directory (the "parent") and
    iterates through all immediate child directories (one level deep).

    - If a child directory does not have a '.env' file, it copies the parent .env file into it.
    - If a child directory already has a '.env' file, it merges the parent's file into it:
        - Keys that exist in both files will be updated with the value from the parent.
        - Keys that only exist in the parent will be added to the child.
        - Keys that only exist in the child will be left untouched.
        - Comments and blank lines in the child file are preserved.

.USAGE
    1. Place this script in your root stacks directory (e.g., C:\docker\stacks).
    2. Place your master .env file in the same directory.
    3. Open a PowerShell terminal, navigate to the directory, and run the script:
       .\sync_env.ps1

    Note: You may need to adjust your execution policy to run local scripts.
    You can do this for the current session by running:
    Set-ExecutionPolicy -Scope Process -ExecutionPolicy Bypass
#>

# --- Configuration ---
$parentEnvFile = ".env"
$scriptDir = Get-Location

# --- Pre-flight Check ---
# Ensure the parent .env file exists before we start.
$parentEnvPath = Join-Path -Path $scriptDir -ChildPath $parentEnvFile
if (-not (Test-Path -Path $parentEnvPath -PathType Leaf)) {
    Write-Error "Error: Parent .env file not found at '$parentEnvPath'."
    exit 1
}

Write-Host "Starting environment file synchronization..."
Write-Host "=========================================="

# --- Main Logic ---

# Read the parent .env file into a dictionary for easy lookup.
# The value will be the entire line (e.g., "KEY=VALUE").
$parentData = [System.Collections.Specialized.OrderedDictionary]::new()
Get-Content -Path $parentEnvPath | ForEach-Object {
    if ($_ -match '^\s*([^#\s].*?)=') {
        $key = $Matches[1].Trim()
        $parentData[$key] = $_
    }
}

# Get all immediate subdirectories of the current directory.
Get-ChildItem -Path $scriptDir -Directory | ForEach-Object {
    $childDir = $_
    $childDirName = $childDir.Name
    $childEnvPath = Join-Path -Path $childDir.FullName -ChildPath $parentEnvFile

    Write-Host ""
    Write-Host "Processing directory: '$childDirName'"

    # --- Case 1: Child .env file does not exist ---
    if (-not (Test-Path -Path $childEnvPath -PathType Leaf)) {
        Write-Host "  -> .env file not found. Creating it from parent."
        Copy-Item -Path $parentEnvPath -Destination $childEnvPath
        Write-Host "  -> Done."
    }
    # --- Case 2: Child .env file already exists ---
    else {
        Write-Host "  -> .env file found. Merging/updating keys from parent."

        $childLines = Get-Content -Path $childEnvPath
        $newLines = [System.Collections.Generic.List[string]]::new()
        $processedKeys = [System.Collections.Generic.HashSet[string]]::new()

        # Process existing lines in the child file
        foreach ($line in $childLines) {
            if ($line -match '^\s*([^#\s].*?)=') {
                $key = $Matches[1].Trim()
                $null = $processedKeys.Add($key)

                # If the key exists in the parent, use the parent's line (value).
                # CORRECTED: OrderedDictionary uses .Contains(), not .ContainsKey()
                if ($parentData.Contains($key)) {
                    $newLines.Add($parentData[$key])
                    Write-Host "    [*] Updating key with parent's value: $key"
                } else {
                    # Key is unique to the child, so keep the original line.
                    $newLines.Add($line)
                }
            } else {
                # It's a comment or blank line, so keep it as is.
                $newLines.Add($line)
            }
        }

        # Add any new keys from the parent that were not in the child at all.
        foreach ($key in $parentData.Keys) {
            if (-not $processedKeys.Contains($key)) {
                Write-Host "    [+] Adding missing key: $key"
                $newLines.Add($parentData[$key])
            }
        }

        # Overwrite the child file with the newly constructed content.
        Set-Content -Path $childEnvPath -Value $newLines
        Write-Host "  -> Done."
    }
}

Write-Host ""
Write-Host "=========================================="
Write-Host "Synchronization complete."
