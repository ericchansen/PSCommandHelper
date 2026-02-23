function Disable-PSCommandHelper {
    <#
    .SYNOPSIS
        Deactivates the PSCommandHelper command-not-found handler.
    .DESCRIPTION
        Removes the CommandNotFoundAction handler that was registered by Enable-PSCommandHelper.
    #>
    [CmdletBinding()]
    param()

    if ($script:PSCommandHelperHandler) {
        $current = $ExecutionContext.InvokeCommand.CommandNotFoundAction
        if ($current) {
            $newHandler = [Delegate]::Remove($current, $script:PSCommandHelperHandler)
            $ExecutionContext.InvokeCommand.CommandNotFoundAction = $newHandler
        }
        $script:PSCommandHelperHandler = $null
        Write-Host "🔴 PSCommandHelper disabled." -ForegroundColor Yellow
    }
    else {
        Write-Verbose "PSCommandHelper is not currently enabled."
    }
}
