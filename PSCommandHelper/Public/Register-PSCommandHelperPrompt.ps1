function Register-PSCommandHelperPrompt {
    <#
    .SYNOPSIS
        Registers a prompt wrapper that catches bash-style flag errors on aliased commands.
    .DESCRIPTION
        Commands like ls, rm, cp are aliased in PowerShell, so CommandNotFoundAction
        doesn't fire for them. But when users pass bash-style flags (ls -la, rm -rf),
        PowerShell errors on the unrecognized parameters. This prompt wrapper detects
        those errors and shows educational suggestions.
    #>
    [CmdletBinding()]
    param()

    # Prevent double-registration
    if ($script:OriginalPrompt) {
        Write-Verbose "PSCommandHelper prompt handler is already registered."
        return
    }

    # Save the current prompt
    $script:OriginalPrompt = $function:prompt

    # Build the aliased-command lookup from the map
    $map = Get-BashToPowerShellMap
    $aliasedMap = @{}
    foreach ($entry in ($map | Where-Object { $_.Type -eq 'Aliased' })) {
        $baseCmd = ($entry.Bash -split '\s+')[0]
        if (-not $aliasedMap.ContainsKey($baseCmd)) {
            $aliasedMap[$baseCmd] = @()
        }
        $aliasedMap[$baseCmd] += $entry
    }
    $script:AliasedCommandMap = $aliasedMap
    $script:FormatFunc = Get-Command Format-Suggestion

    $function:global:prompt = {
        # Check if the last command failed
        if (-not $? -and $global:Error.Count -gt 0) {
            $lastErr = $global:Error[0]
            try {
                # Extract the command name from the error
                $cmdName = $null
                if ($lastErr.InvocationInfo -and $lastErr.InvocationInfo.MyCommand) {
                    $cmdName = $lastErr.InvocationInfo.MyCommand.Name
                }
                elseif ($lastErr.CategoryInfo -and $lastErr.CategoryInfo.Activity) {
                    $cmdName = $lastErr.CategoryInfo.Activity
                }

                if ($cmdName) {
                    # Check if an alias resolves to a known command
                    $alias = Get-Alias -Name $cmdName -ErrorAction SilentlyContinue
                    $lookupName = if ($alias) { $cmdName } else { $null }

                    # Also check if the failing command itself is in our aliased map
                    if (-not $lookupName -and $script:AliasedCommandMap.ContainsKey($cmdName)) {
                        $lookupName = $cmdName
                    }

                    # Reverse lookup: $cmdName may be the resolved cmdlet (e.g. Remove-Item)
                    # Find aliases that point TO this cmdlet (e.g. rm → Remove-Item)
                    if (-not $lookupName) {
                        $reverseAliases = Get-Alias -Definition $cmdName -ErrorAction SilentlyContinue
                        foreach ($ra in $reverseAliases) {
                            if ($script:AliasedCommandMap.ContainsKey($ra.Name)) {
                                $lookupName = $ra.Name
                                break
                            }
                        }
                    }

                    if ($lookupName -and $script:AliasedCommandMap.ContainsKey($lookupName)) {
                        $errString = $lastErr.ToString()
                        # Only show for parameter-binding or argument errors (bash-style flags)
                        $isParamError = $lastErr.Exception -is [System.Management.Automation.ParameterBindingException] -or
                                        $errString -match 'is not recognized as' -or
                                        $errString -match 'A positional parameter cannot be found' -or
                                        $errString -match 'Cannot find a parameter'

                        if ($isParamError) {
                            # Find the best matching entry using flag-aware comparison
                            $line = if ($lastErr.InvocationInfo) { $lastErr.InvocationInfo.Line.Trim() } else { $lookupName }
                            $entries = $script:AliasedCommandMap[$lookupName]

                            # Extract and normalize flags from the typed line
                            $lineFlags = [System.Collections.Generic.HashSet[char]]::new()
                            $lineParts = ($line -split '\s+') | Select-Object -Skip 1
                            foreach ($part in $lineParts) {
                                if ($part -match '^-([A-Za-z0-9]+)$') {
                                    foreach ($ch in $Matches[1].ToCharArray()) { [void]$lineFlags.Add($ch) }
                                }
                            }

                            $bestMatch = $null
                            $bestScore = -1
                            foreach ($entry in $entries) {
                                $entryFlags = [System.Collections.Generic.HashSet[char]]::new()
                                $entryParts = ($entry.Bash -split '\s+') | Select-Object -Skip 1
                                foreach ($part in $entryParts) {
                                    if ($part -match '^-([A-Za-z0-9]+)$') {
                                        foreach ($ch in $Matches[1].ToCharArray()) { [void]$entryFlags.Add($ch) }
                                    }
                                }
                                # Score: entry flags must be a subset of typed flags; more flags = better match
                                if ($entryFlags.Count -gt 0 -and $entryFlags.IsSubsetOf($lineFlags)) {
                                    if ($entryFlags.Count -gt $bestScore) {
                                        $bestScore = $entryFlags.Count
                                        $bestMatch = $entry
                                    }
                                }
                            }

                            # Fallback: substring match or base command
                            if (-not $bestMatch) {
                                $bestMatch = $entries | Sort-Object { $_.Bash.Length } -Descending |
                                             Where-Object { $line -match [regex]::Escape($_.Bash) } |
                                             Select-Object -First 1
                            }
                            if (-not $bestMatch) {
                                $bestMatch = $entries | Select-Object -First 1
                            }

                            & $script:FormatFunc -Mapping $bestMatch -OriginalCommand $line
                        }
                    }
                }
            }
            catch {
                # Silently ignore errors in the prompt handler
            }
        }

        # Call the original prompt
        & $script:OriginalPrompt
    }
}
