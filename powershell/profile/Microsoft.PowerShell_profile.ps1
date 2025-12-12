# ===============================
# PowerShell Profile
# ===============================

# --- Core safety ----------------------------------------------------

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

# Prevent profile failure from breaking the shell
function Invoke-Safely {
    param (
        [Parameter(Mandatory)]
        [ScriptBlock]$Script
    )

    try {
        & $Script
    }
    catch {
        # Intentionally swallow errors to keep shell usable
        Write-Verbose "Profile step skipped: $($_.Exception.Message)"
    }
}

# --- Core user behavior (PSReadLine) --------------------------------

Import-Module PSReadLine -ErrorAction SilentlyContinue

Set-PSReadLineOption -PredictionSource History
Set-PSReadLineOption -EditMode Windows
Set-PSReadLineOption -HistoryNoDuplicates
Set-PSReadLineOption -MaximumHistoryCount 10000

# --- Oh My Posh (optional UI layer) ---------------------------------

Invoke-Safely {
    . (Join-Path $PSScriptRoot "oh-my-posh-utils.ps1")
}

# --- History utilities ----------------------------------------------

Invoke-Safely {
    . (Join-Path $PSScriptRoot "history-utils.ps1")
}

# --- End of profile -------------------------------------------------


