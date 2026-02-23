function Format-Suggestion {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)]
        [hashtable]$Mapping,

        [Parameter(Mandatory)]
        [string]$OriginalCommand
    )

    $esc = [char]27

    # Colors
    $reset    = "$esc[0m"
    $bold     = "$esc[1m"
    $dim      = "$esc[2m"
    $yellow   = "$esc[33m"
    $green    = "$esc[32m"
    $cyan     = "$esc[36m"
    $magenta  = "$esc[35m"
    $bgDark   = "$esc[48;5;236m"

    $divider = "$dim$('─' * 60)$reset"

    Write-Host ""
    Write-Host $divider
    Write-Host "  💡 $yellow${bold}PSCommandHelper$reset"
    Write-Host ""
    Write-Host "  $dim You typed:$reset  $yellow$OriginalCommand$reset"
    Write-Host "  $dim Try this:$reset   $green${bold}$($Mapping.PowerShell)$reset"
    Write-Host ""
    Write-Host "  $cyan$($Mapping.Explanation)$reset"

    if ($Mapping.Example) {
        Write-Host ""
        Write-Host "  ${dim}Example:$reset"
        Write-Host "  $magenta$bold> $($Mapping.Example)$reset"
    }

    Write-Host $divider
    Write-Host ""
}
