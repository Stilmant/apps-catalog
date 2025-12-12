oh-my-posh init pwsh --config "$env:POSH_THEMES_PATH\paradox.omp.json" | Invoke-Expression

# Remove default alias
if (Test-Path alias:history) {
    Remove-Item alias:history
}

# New history function
function history {
    param(
        [string]$Pattern = '*'
    )

    $path = (Get-PSReadLineOption).HistorySavePath
    $all  = Get-Content $path

    for ($i = 0; $i -lt $all.Count; $i++) {
        $cmd = $all[$i]

        if ($cmd -like "*$Pattern*") {
            # $i + 1 = vrai numéro de ligne dans l'historique
            "{0,6}  {1}" -f ($i + 1), $cmd
        }
    }
}


Set-PSReadLineKeyHandler -Key Enter -ScriptBlock {
    param($key, $arg)

    $line   = $null
    $cursor = $null
    [Microsoft.PowerShell.PSConsoleReadLine]::GetBufferState([ref]$line, [ref]$cursor)

    if ($line -match '^!(\d+)$') {
        $n = [int]$matches[1]

        $path  = (Get-PSReadLineOption).HistorySavePath
        $lines = Get-Content $path

        if ($n -ge 1 -and $n -le $lines.Count) {
            $cmd = $lines[$n - 1]
            [Microsoft.PowerShell.PSConsoleReadLine]::Replace(0, $line.Length, $cmd)
            [Microsoft.PowerShell.PSConsoleReadLine]::AcceptLine()
            return
        }
        else {
            [Console]::Beep()
            Write-Host "`nNuméro d'historique invalide: $n"
            [Microsoft.PowerShell.PSConsoleReadLine]::RevertLine()
            return
        }
    }

    [Microsoft.PowerShell.PSConsoleReadLine]::AcceptLine()
}


