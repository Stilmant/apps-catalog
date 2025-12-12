param(
    [string]$CatalogFolder = (Join-Path $PSScriptRoot "..\winget-apps-catalogs")
)

Write-Host "Starting full setup (winget catalogs)" -ForegroundColor Cyan

$files = @(
    "base.json",
    "dev.json",
    "tools.json",
    "apps.json",
    "hardware.json"
)

foreach ($file in $files) {
    $catalogPath = Join-Path $CatalogFolder $file

    if (-not (Test-Path $catalogPath)) {
        Write-Warning "Catalog not found: $catalogPath"
        Write-Warning "Run this script from a full repo checkout, or pass -CatalogFolder."
        exit 1
    }

    Write-Host "Installing from $catalogPath" -ForegroundColor Yellow
    winget import $catalogPath --disable-interactivity
}

Write-Host "All installations completed" -ForegroundColor Green
