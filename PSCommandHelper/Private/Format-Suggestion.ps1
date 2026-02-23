function Format-Suggestion {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)]
        [hashtable]$Mapping,

        [Parameter(Mandatory)]
        [string]$OriginalCommand
    )

    # Use $PSStyle if available (PS 7.2+), otherwise raw ANSI
    $hasPSStyle = $null -ne (Get-Variable -Name PSStyle -ErrorAction SilentlyContinue)
    $isInteractive = $Host.Name -eq 'ConsoleHost'

    if ($hasPSStyle -and $isInteractive) {
        $reset   = $PSStyle.Reset
        $bold    = $PSStyle.Bold
        $dim     = $PSStyle.Formatting.FormatAccent
        $yellow  = $PSStyle.Foreground.Yellow
        $green   = $PSStyle.Foreground.Green
        $cyan    = $PSStyle.Foreground.Cyan
        $magenta = $PSStyle.Foreground.Magenta
    }
    elseif ($isInteractive) {
        $esc     = [char]27
        $reset   = "$esc[0m"
        $bold    = "$esc[1m"
        $dim     = "$esc[2m"
        $yellow  = "$esc[33m"
        $green   = "$esc[32m"
        $cyan    = "$esc[36m"
        $magenta = "$esc[35m"
    }
    else {
        # Non-interactive: no color
        $reset = $bold = $dim = $yellow = $green = $cyan = $magenta = ''
    }

    $divider = "$dim$('─' * 60)$reset"

    # Adapt header by type
    $type = $Mapping.Type
    switch ($type) {
        'Aliased' {
            $header  = "💡 $yellow${bold}PSCommandHelper$reset  ${dim}(alias tip)$reset"
            $youTyped = "  $dim You typed:$reset  $yellow$OriginalCommand$reset"
            $tryThis  = "  $dim PS equivalent:$reset $green${bold}$($Mapping.PowerShell)$reset"
            $note     = "  ${dim}Note: ``$($Mapping.Bash)`` is already aliased in PS, but the flags differ.$reset"
        }
        'Executable' {
            $header  = "💡 $yellow${bold}PSCommandHelper$reset  ${dim}(native alternative)$reset"
            $youTyped = "  $dim You typed:$reset  $yellow$OriginalCommand$reset"
            $tryThis  = "  $dim PS-native:$reset   $green${bold}$($Mapping.PowerShell)$reset"
            $note     = "  ${dim}Note: ``$($Mapping.Bash)`` exists as a Windows .exe, but the PS-native version returns rich objects.$reset"
        }
        default {
            $header  = "💡 $yellow${bold}PSCommandHelper$reset"
            $youTyped = "  $dim You typed:$reset  $yellow$OriginalCommand$reset"
            $tryThis  = "  $dim Try this:$reset   $green${bold}$($Mapping.PowerShell)$reset"
            $note     = $null
        }
    }

    Write-Host ""
    Write-Host $divider
    Write-Host "  $header"
    Write-Host ""
    Write-Host $youTyped
    Write-Host $tryThis
    Write-Host ""
    Write-Host "  $cyan$($Mapping.Explanation)$reset"

    if ($note) {
        Write-Host $note
    }

    if ($Mapping.Example) {
        Write-Host ""
        Write-Host "  ${dim}Example:$reset"
        Write-Host "  $magenta$bold> $($Mapping.Example)$reset"
    }

    Write-Host $divider
    Write-Host ""
}
