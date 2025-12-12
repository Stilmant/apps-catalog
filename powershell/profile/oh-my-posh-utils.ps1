# ===============================
# Oh My Posh Initialization
# ===============================

# 1. Is oh-my-posh available?
if (-not (Get-Command oh-my-posh -ErrorAction SilentlyContinue)) {
    return
}

# 2. Define config candidates (ordered by preference)
$OhMyPoshConfigs = @(
    "$HOME\.config\oh-my-posh\full.omp.json",
    "$HOME\.config\oh-my-posh\minimal.omp.json",
    "$env:POSH_THEMES_PATH\paradox.omp.json"
)

# 3. Select the first existing config
$ConfigPath = $OhMyPoshConfigs | Where-Object { Test-Path $_ } | Select-Object -First 1

if (-not $ConfigPath) {
    return
}

# 4. Initialize Oh My Posh
oh-my-posh init pwsh --config $ConfigPath | Invoke-Expression
