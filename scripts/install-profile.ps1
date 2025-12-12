Write-Host "Installing PowerShell profile..." -ForegroundColor Cyan

# Source profile folder in repo
$SourceProfileFolder = Join-Path $PSScriptRoot "..\powershell\profile"
$SourceProfile = Join-Path $SourceProfileFolder "Microsoft.PowerShell_profile.ps1"

# Profile dependencies
$ProfileDependencies = @(
    "history-utils.ps1",
    "oh-my-posh-utils.ps1"
)

# Basic sanity checks
if (-not $PROFILE) {
    Write-Warning "PowerShell profile variable is not available."
    Write-Warning "Please install PowerShell first."
    exit 1
}

$DestinationProfile = $PROFILE
$DestinationFolder  = Split-Path $DestinationProfile

# PowerShell should already have created this folder
if (-not (Test-Path $DestinationFolder)) {
    Write-Warning "PowerShell profile folder does not exist:"
    Write-Warning $DestinationFolder
    Write-Warning "PowerShell does not appear to be initialized correctly."
    Write-Warning "Please start PowerShell once or reinstall it."
    exit 1
}

# Source files must exist
if (-not (Test-Path $SourceProfile)) {
    Write-Warning "Source profile file not found:"
    Write-Warning $SourceProfile
    exit 1
}

# If destination profile does not exist, copy profile + dependencies
if (-not (Test-Path $DestinationProfile)) {
    Write-Host "No existing profile found. Installing profile and dependencies..."
    
    # Copy main profile
    Copy-Item $SourceProfile $DestinationProfile
    
    # Copy dependencies
    foreach ($dep in $ProfileDependencies) {
        $sourceDep = Join-Path $SourceProfileFolder $dep
        $destDep = Join-Path $DestinationFolder $dep
        
        if (Test-Path $sourceDep) {
            Copy-Item $sourceDep $destDep -Force
            Write-Host "  - Copied $dep" -ForegroundColor Gray
        }
    }
    
    Write-Host "Profile installed successfully." -ForegroundColor Green
    exit 0
}

# Compare content if profile already exists
$SourceContent      = Get-Content $SourceProfile -Raw
$DestinationContent = Get-Content $DestinationProfile -Raw

if ($SourceContent -eq $DestinationContent) {
    Write-Host "Profile already present and identical. Nothing to do." -ForegroundColor Green
    exit 0
}

# Conflict handling
Write-Warning "An existing PowerShell profile was found and differs from the provided one."
Write-Host ""
Write-Host "Choose an action:" -ForegroundColor Yellow
Write-Host "  [1] Overwrite existing profile"
Write-Host "  [2] Keep existing profile"
Write-Host "  [3] Generate diff file for manual review"
$choice = Read-Host "Your choice (1/2/3)"

switch ($choice) {
    "1" {
        # Overwrite profile + dependencies
        Copy-Item $SourceProfile $DestinationProfile -Force
        
        foreach ($dep in $ProfileDependencies) {
            $sourceDep = Join-Path $SourceProfileFolder $dep
            $destDep = Join-Path $DestinationFolder $dep
            
            if (Test-Path $sourceDep) {
                Copy-Item $sourceDep $destDep -Force
            }
        }
        
        Write-Host "Profile and dependencies overwritten." -ForegroundColor Green
    }
    "2" {
        Write-Host "Existing profile kept unchanged." -ForegroundColor Yellow
    }
    "3" {
        $DiffFile = Join-Path $PSScriptRoot "profile.diff.txt"
        Compare-Object `
            ($SourceContent -split "`n") `
            ($DestinationContent -split "`n") |
            Out-File $DiffFile
        Write-Host "Diff file created: $DiffFile" -ForegroundColor Yellow
        Write-Host "Please review and merge manually."
    }
    default {
        Write-Host "Invalid choice. No action taken."
    }
}
