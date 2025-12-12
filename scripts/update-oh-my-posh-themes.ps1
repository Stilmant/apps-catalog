# ==========================================================
# Update Oh My Posh Themes (explicit, reproducible)
# ==========================================================

$ErrorActionPreference = 'Stop'

Write-Host "Updating Oh My Posh themes..." -ForegroundColor Cyan

# ----------------------------------------------------------
# Configuration
# ----------------------------------------------------------

$UpstreamBaseUrl = "https://raw.githubusercontent.com/JanDeDobbeleer/oh-my-posh/main/themes"

$Themes = @{
    Full    = "jandedobbeleer.omp.json"
    Minimal = "stelbent-compact.minimal.omp.json"
}

$RepoRoot = Split-Path -Parent $PSScriptRoot
$VendorDir = Join-Path $RepoRoot "powershell\oh-my-posh\upstream"
$RuntimeDir = Join-Path $HOME ".config\oh-my-posh"

# ----------------------------------------------------------
# Preconditions
# ----------------------------------------------------------

if (-not (Get-Command oh-my-posh -ErrorAction SilentlyContinue)) {
    Write-Warning "oh-my-posh is not installed. Aborting."
    return
}

# ----------------------------------------------------------
# Ensure directories exist
# ----------------------------------------------------------

New-Item -ItemType Directory -Force -Path $VendorDir | Out-Null
New-Item -ItemType Directory -Force -Path $RuntimeDir | Out-Null

# ----------------------------------------------------------
# Download and install themes
# ----------------------------------------------------------

foreach ($entry in $Themes.GetEnumerator()) {

    $Kind = $entry.Key
    $FileName = $entry.Value

    $SourceUrl = "$UpstreamBaseUrl/$FileName"
    $VendorPath = Join-Path $VendorDir $FileName

    Write-Host "Fetching $Kind theme: $FileName" -ForegroundColor Gray

    try {
        Invoke-WebRequest -Uri $SourceUrl -OutFile $VendorPath -UseBasicParsing
    }
    catch {
        Write-Warning "Failed to download $FileName"
        continue
    }

    $TargetName = if ($Kind -eq "Full") { "full.omp.json" } else { "minimal.omp.json" }
    $RuntimePath = Join-Path $RuntimeDir $TargetName

    Copy-Item -Path $VendorPath -Destination $RuntimePath -Force

    Write-Host "Installed $Kind theme → $RuntimePath" -ForegroundColor Green
}

# ----------------------------------------------------------
# Done
# ----------------------------------------------------------

Write-Host "Oh My Posh themes updated successfully." -ForegroundColor Cyan
Write-Host "Restart your terminal to apply changes." -ForegroundColor DarkGray
