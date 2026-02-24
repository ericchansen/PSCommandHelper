function Unregister-PSCommandHelperPrompt {
    <#
    .SYNOPSIS
        Removes the prompt wrapper installed by Register-PSCommandHelperPrompt.
    #>
    [CmdletBinding()]
    param()

    if ($script:OriginalPrompt) {
        $function:global:prompt = $script:OriginalPrompt
        $script:OriginalPrompt = $null
        $script:AliasedCommandMap = $null
        $script:AliasedCmdletMap = $null
    }
}
