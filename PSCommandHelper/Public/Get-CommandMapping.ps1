function Get-CommandMapping {
    <#
    .SYNOPSIS
        Browse or search the bash-to-PowerShell command mapping table.
    .DESCRIPTION
        Lists all available bash → PowerShell command mappings, or filters them by a search term.
        Useful for proactive learning — browse the table to discover PowerShell equivalents.
    .PARAMETER Search
        Optional search term to filter mappings. Searches both bash and PowerShell columns.
    .PARAMETER Type
        Optional filter by detection type: Hook, Aliased, or Executable.
    .EXAMPLE
        Get-CommandMapping
        Lists all mappings.
    .EXAMPLE
        Get-CommandMapping -Search "grep"
        Shows mappings related to grep.
    .EXAMPLE
        Get-CommandMapping -Type Hook
        Shows only commands that trigger the CommandNotFoundAction hook.
    .EXAMPLE
        Get-CommandMapping -Search "file"
        Shows mappings with "file" in any field.
    #>
    [CmdletBinding()]
    param(
        [Parameter(Position = 0)]
        [string]$Search,

        [Parameter()]
        [ValidateSet('Hook', 'Aliased', 'Executable')]
        [string]$Type
    )

    $map = Get-BashToPowerShellMap

    if ($Search) {
        $map = $map | Where-Object {
            $_.Bash -like "*$Search*" -or
            $_.PowerShell -like "*$Search*" -or
            $_.Explanation -like "*$Search*"
        }
    }

    if ($Type) {
        $map = $map | Where-Object { $_.Type -eq $Type }
    }

    if (-not $map) {
        Write-Host "No mappings found for '$Search'." -ForegroundColor Yellow
        return
    }

    $esc = [char]27
    $reset   = "$esc[0m"
    $bold    = "$esc[1m"
    $yellow  = "$esc[33m"
    $green   = "$esc[32m"
    $cyan    = "$esc[36m"
    $dim     = "$esc[2m"

    Write-Host ""
    Write-Host "  ${bold}📖 Bash → PowerShell Mappings$reset"
    if ($Search) {
        Write-Host "  ${dim}Filtered by: '$Search'$reset"
    }
    Write-Host "  $dim$('─' * 56)$reset"

    foreach ($entry in $map) {
        $typeTag = switch ($entry.Type) { 'Hook' { '🔵' } 'Aliased' { '🟡' } 'Executable' { '🟢' } default { '⚪' } }
        Write-Host "  $typeTag $yellow$($entry.Bash.PadRight(20))$reset → $green${bold}$($entry.PowerShell)$reset"
        Write-Host "  $dim$($entry.Explanation)$reset"
        Write-Host ""
    }

    Write-Host "  $dim$($map.Count) mapping(s) shown.$reset"
    Write-Host ""
}
