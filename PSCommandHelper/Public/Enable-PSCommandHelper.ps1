function Enable-PSCommandHelper {
    <#
    .SYNOPSIS
        Activates the PSCommandHelper to suggest PowerShell equivalents for bash commands.
    .DESCRIPTION
        Registers a CommandNotFoundAction handler in PowerShell 7+ that intercepts
        unrecognized commands, matches them against a bash-to-PowerShell mapping table,
        and displays a colorful educational suggestion.
    #>
    [CmdletBinding()]
    param()

    if ($PSVersionTable.PSVersion.Major -lt 7) {
        Write-Warning "PSCommandHelper requires PowerShell 7 or later. Current version: $($PSVersionTable.PSVersion)"
        return
    }

    # Prevent double-registration
    if ($script:PSCommandHelperHandler) {
        Write-Verbose "PSCommandHelper is already enabled."
        return
    }

    # Pre-load data and function references for the closure
    # (the handler runs outside module scope, so private functions aren't visible)
    $map = Get-BashToPowerShellMap
    $formatFunc = Get-Command Format-Suggestion

    $handler = {
        param($sender, [System.Management.Automation.CommandLookupEventArgs]$eventArgs)

        $commandName = $eventArgs.CommandName

        $matched = $null

        # Exact match first
        $matched = $map | Where-Object { $_.Bash -eq $commandName } | Select-Object -First 1

        # Fallback: match on the base command word
        if (-not $matched) {
            $baseCmd = ($commandName -split '\s+')[0]
            $matched = $map | Where-Object { $_.Bash -eq $baseCmd } | Select-Object -First 1
        }

        if ($matched) {
            & $formatFunc -Mapping $matched -OriginalCommand $commandName
        }
    }

    $handler = $handler.GetNewClosure()

    # Cast to the proper delegate type for CommandNotFoundAction
    $typedHandler = $handler -as [System.EventHandler[System.Management.Automation.CommandLookupEventArgs]]

    $current = $ExecutionContext.InvokeCommand.CommandNotFoundAction
    if ($current) {
        $ExecutionContext.InvokeCommand.CommandNotFoundAction = [Delegate]::Combine($current, $typedHandler)
    }
    else {
        $ExecutionContext.InvokeCommand.CommandNotFoundAction = $typedHandler
    }

    # Store typed delegate reference for clean removal
    $script:PSCommandHelperHandler = $typedHandler

    Write-Host "✅ PSCommandHelper enabled. Type a bash command to see the PowerShell equivalent!" -ForegroundColor Green
}
