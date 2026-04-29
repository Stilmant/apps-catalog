param(
    [Parameter(Mandatory = $true)]
    [string]$CatalogPath
)

function Get-NormalizedWingetPackageId {
    param(
        [Parameter(Mandatory = $true)]
        [string]$PackageId
    )

    $knownSuffixes = @(
        'EXE',
        'MSI',
        'MSIX',
        'MSIXBUNDLE',
        'APPX',
        'APPXBUNDLE',
        'PORTABLE',
        'ZIP',
        'BURN',
        'INNO',
        'NULLSOFT',
        'WIX'
    )

    $normalizedPackageId = $PackageId.Trim()

    while ($normalizedPackageId -match '\.([^.]+)$') {
        $suffix = $Matches[1].ToUpperInvariant()

        if ($suffix -notin $knownSuffixes) {
            break
        }

        $normalizedPackageId = $normalizedPackageId.Substring(0, $normalizedPackageId.LastIndexOf('.'))
    }

    return $normalizedPackageId
}

function Get-InstalledWingetPackageIds {
    $exportPath = Join-Path ([System.IO.Path]::GetTempPath()) ("apps-catalog-winget-export-{0}.json" -f [System.Guid]::NewGuid())

    try {
        winget export -o $exportPath --source winget --accept-source-agreements --disable-interactivity *> $null

        if ($LASTEXITCODE -ne 0 -or -not (Test-Path $exportPath)) {
            throw "winget export failed."
        }

        $exportedPackages = (Get-Content $exportPath -Raw | ConvertFrom-Json).Sources.Packages
        $installedPackageIds = [System.Collections.Generic.HashSet[string]]::new([System.StringComparer]::OrdinalIgnoreCase)
        $normalizedInstalledPackageIds = [System.Collections.Generic.HashSet[string]]::new([System.StringComparer]::OrdinalIgnoreCase)

        foreach ($package in $exportedPackages) {
            if (-not $package.PackageIdentifier) {
                continue
            }

            [void]$installedPackageIds.Add($package.PackageIdentifier)
            [void]$normalizedInstalledPackageIds.Add((Get-NormalizedWingetPackageId -PackageId $package.PackageIdentifier))
        }

        return @{
            ExactIds = $installedPackageIds
            NormalizedIds = $normalizedInstalledPackageIds
        }
    }
    finally {
        if (Test-Path $exportPath) {
            Remove-Item $exportPath -Force -ErrorAction SilentlyContinue
        }
    }
}

function Test-WingetPackageInstalled {
    param(
        [Parameter(Mandatory = $true)]
        [string]$PackageId,

        [Parameter(Mandatory = $true)]
        [hashtable]$InstalledPackageIndex
    )

    if ($InstalledPackageIndex.ExactIds.Contains($PackageId)) {
        return $true
    }

    $normalizedPackageId = Get-NormalizedWingetPackageId -PackageId $PackageId
    return $InstalledPackageIndex.NormalizedIds.Contains($normalizedPackageId)
}

$resolvedCatalogPath = Resolve-Path $CatalogPath -ErrorAction SilentlyContinue

if (-not $resolvedCatalogPath) {
    Write-Warning "Catalog not found: $CatalogPath"
    exit 1
}

$catalog = Get-Content $resolvedCatalogPath -Raw | ConvertFrom-Json

if (-not $catalog.Sources) {
    Write-Warning "Catalog file does not contain any packages: $resolvedCatalogPath"
    exit 1
}

$installedPackageIndex = Get-InstalledWingetPackageIds
$missingPackages = @()

foreach ($source in $catalog.Sources) {
    foreach ($package in $source.Packages) {
        $packageId = $package.PackageIdentifier

        if (-not $packageId) {
            continue
        }

        Write-Host "Checking $packageId" -ForegroundColor Yellow

        if (-not (Test-WingetPackageInstalled -PackageId $packageId -InstalledPackageIndex $installedPackageIndex)) {
            $missingPackages += $packageId
            continue
        }

        Write-Host "  Installed" -ForegroundColor Green
    }
}

if ($missingPackages.Count -eq 0) {
    Write-Host "All catalog packages are already installed." -ForegroundColor Green
    exit 0
}

Write-Warning "The following packages are missing:"
foreach ($packageId in $missingPackages) {
    Write-Warning "  - $packageId"
}

exit 1