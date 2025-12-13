# PowerShell history utilities
# Enhanced history function and !n recall keybinding

# Remove default alias and create a new alias to override the cmdlet
if (Test-Path alias:history) {
    Remove-Item alias:history -Force
}

# Remove the built-in Get-History cmdlet from the current session scope
Remove-Item function:history -ErrorAction SilentlyContinue

# New history function with pattern filtering
function global:history {
    param(
        [string]$Pattern = '*'
    )

    $path = (Get-PSReadLineOption).HistorySavePath
    $all  = Get-Content $path

    for ($i = 0; $i -lt $all.Count; $i++) {
        $cmd = $all[$i]

        if ($cmd -like "*$Pattern*") {
            # $i + 1 = true line number in history
            "{0,6}  {1}" -f ($i + 1), $cmd
        }
    }
}

# Enable !n recall (e.g., !42 to execute command #42 from history)
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
            Write-Host "`nInvalid history number: $n"
            [Microsoft.PowerShell.PSConsoleReadLine]::RevertLine()
            return
        }
    }

    [Microsoft.PowerShell.PSConsoleReadLine]::AcceptLine()
}
