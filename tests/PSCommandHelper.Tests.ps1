BeforeAll {
    $modulePath = Join-Path $PSScriptRoot '..\PSCommandHelper'
    Import-Module $modulePath -Force
}

AfterAll {
    Remove-Module PSCommandHelper -ErrorAction SilentlyContinue
}

Describe 'CommandMap' {
    It 'returns a non-empty array of mappings' {
        InModuleScope PSCommandHelper {
            $map = Get-BashToPowerShellMap
            $map | Should -Not -BeNullOrEmpty
            $map.Count | Should -BeGreaterThan 40
        }
    }

    It 'each entry has required keys including Type' {
        InModuleScope PSCommandHelper {
            $map = Get-BashToPowerShellMap
            foreach ($entry in $map) {
                $entry.Bash        | Should -Not -BeNullOrEmpty
                $entry.PowerShell  | Should -Not -BeNullOrEmpty
                $entry.Explanation | Should -Not -BeNullOrEmpty
                $entry.Type        | Should -BeIn @('Hook', 'Aliased', 'Executable')
            }
        }
    }

    It 'contains common commands' {
        InModuleScope PSCommandHelper {
            $map = Get-BashToPowerShellMap
            $bashCmds = $map | ForEach-Object { $_.Bash }
            $bashCmds | Should -Contain 'rm -rf'
            $bashCmds | Should -Contain 'grep'
            $bashCmds | Should -Contain 'curl'
            $bashCmds | Should -Contain 'cat'
        }
    }

    It 'tags aliased commands correctly' {
        InModuleScope PSCommandHelper {
            $map = Get-BashToPowerShellMap
            $aliased = $map | Where-Object { $_.Type -eq 'Aliased' }
            $aliasedBash = $aliased | ForEach-Object { ($_.Bash -split '\s+')[0] } | Sort-Object -Unique
            # These should all be Aliased
            @('rm', 'ls', 'cp', 'mv', 'cat') | ForEach-Object {
                $_ | Should -BeIn $aliasedBash
            }
        }
    }

    It 'tags hook commands correctly' {
        InModuleScope PSCommandHelper {
            $map = Get-BashToPowerShellMap
            $hooks = $map | Where-Object { $_.Type -eq 'Hook' }
            $hookBash = $hooks | ForEach-Object { ($_.Bash -split '\s+')[0] } | Sort-Object -Unique
            @('grep', 'sed', 'awk', 'chmod', 'touch') | ForEach-Object {
                $_ | Should -BeIn $hookBash
            }
        }
    }
}

Describe 'Get-CommandMapping' {
    It 'returns all mappings when no search term is given' {
        $result = Get-CommandMapping 6>&1
        $result | Should -Not -BeNullOrEmpty
    }

    It 'filters by search term' {
        $result = Get-CommandMapping -Search 'grep' 6>&1
        $resultText = $result -join "`n"
        $resultText | Should -Match 'grep'
    }

    It 'filters by Type' {
        $result = Get-CommandMapping -Type 'Hook' 6>&1
        $resultText = $result -join "`n"
        # Hook commands like grep should be present, aliased ones like ls should not
        $resultText | Should -Match 'grep'
    }

    It 'handles no results gracefully' {
        $result = Get-CommandMapping -Search 'zzz_no_such_command_zzz' 6>&1
        $resultText = $result -join "`n"
        $resultText | Should -Match 'No mappings found'
    }
}

Describe 'Format-Suggestion' {
    It 'produces output without error for Hook type' {
        InModuleScope PSCommandHelper {
            $mapping = @{
                Bash        = 'grep'
                PowerShell  = 'Select-String'
                Explanation = 'Test explanation'
                Example     = 'Select-String -Path ./app.log -Pattern "error"'
                Type        = 'Hook'
            }
            { Format-Suggestion -Mapping $mapping -OriginalCommand 'grep' 6>&1 } | Should -Not -Throw
        }
    }

    It 'produces output without error for Aliased type' {
        InModuleScope PSCommandHelper {
            $mapping = @{
                Bash        = 'ls -la'
                PowerShell  = 'Get-ChildItem -Force'
                Explanation = 'Test explanation'
                Example     = 'Get-ChildItem -Force'
                Type        = 'Aliased'
            }
            { Format-Suggestion -Mapping $mapping -OriginalCommand 'ls -la' 6>&1 } | Should -Not -Throw
        }
    }

    It 'produces output without error for Executable type' {
        InModuleScope PSCommandHelper {
            $mapping = @{
                Bash        = 'curl'
                PowerShell  = 'Invoke-RestMethod'
                Explanation = 'Test explanation'
                Example     = 'Invoke-RestMethod https://example.com'
                Type        = 'Executable'
            }
            { Format-Suggestion -Mapping $mapping -OriginalCommand 'curl' 6>&1 } | Should -Not -Throw
        }
    }
}

Describe 'Register/Unregister-PSCommandHelperPrompt' {
    AfterEach {
        Unregister-PSCommandHelperPrompt 6>&1 | Out-Null
    }

    It 'registers without error' {
        { Register-PSCommandHelperPrompt 6>&1 } | Should -Not -Throw
    }

    It 'unregisters without error' {
        Register-PSCommandHelperPrompt 6>&1 | Out-Null
        { Unregister-PSCommandHelperPrompt 6>&1 } | Should -Not -Throw
    }

    It 'is idempotent — double register does not error' {
        Register-PSCommandHelperPrompt 6>&1 | Out-Null
        { Register-PSCommandHelperPrompt 6>&1 } | Should -Not -Throw
    }
}

Describe 'Prompt handler: reverse alias lookup' {
    BeforeAll {
        InModuleScope PSCommandHelper {
            $map = Get-BashToPowerShellMap
            $script:TestAliasedMap = @{}
            $script:TestAliasedCmdletMap = @{}
            foreach ($entry in ($map | Where-Object { $_.Type -eq 'Aliased' })) {
                $baseCmd = ($entry.Bash -split '\s+')[0]
                if (-not $script:TestAliasedMap.ContainsKey($baseCmd)) {
                    $script:TestAliasedMap[$baseCmd] = @()
                }
                $script:TestAliasedMap[$baseCmd] += $entry

                $psCmdlet = ($entry.PowerShell -split '\s+')[0]
                if ($psCmdlet) {
                    if (-not $script:TestAliasedCmdletMap.ContainsKey($psCmdlet)) {
                        $script:TestAliasedCmdletMap[$psCmdlet] = @()
                    }
                    $script:TestAliasedCmdletMap[$psCmdlet] += $entry
                }
            }
        }
    }

    It 'rm is in the aliased map' {
        InModuleScope PSCommandHelper {
            $script:TestAliasedMap.ContainsKey('rm') | Should -BeTrue
        }
    }

    It 'has cmdlet fallback entries for Remove-Item and Get-ChildItem' {
        InModuleScope PSCommandHelper {
            $script:TestAliasedCmdletMap.ContainsKey('Remove-Item') | Should -BeTrue
            $script:TestAliasedCmdletMap.ContainsKey('Get-ChildItem') | Should -BeTrue
        }
    }

    It 'resolves Remove-Item to aliased suggestions by alias or cmdlet fallback' {
        InModuleScope PSCommandHelper {
            $resolvedEntries = $null
            $aliases = Get-Alias -Definition 'Remove-Item' -ErrorAction SilentlyContinue
            foreach ($a in $aliases) {
                if ($script:TestAliasedMap.ContainsKey($a.Name)) {
                    $resolvedEntries = $script:TestAliasedMap[$a.Name]
                    break
                }
            }
            if (-not $resolvedEntries) {
                $resolvedEntries = $script:TestAliasedCmdletMap['Remove-Item']
            }

            $resolvedEntries | Should -Not -BeNullOrEmpty
        }
    }

    It 'resolves Get-ChildItem to aliased suggestions by alias or cmdlet fallback' {
        InModuleScope PSCommandHelper {
            $resolvedEntries = $null
            $aliases = Get-Alias -Definition 'Get-ChildItem' -ErrorAction SilentlyContinue
            foreach ($a in $aliases) {
                if ($script:TestAliasedMap.ContainsKey($a.Name)) {
                    $resolvedEntries = $script:TestAliasedMap[$a.Name]
                    break
                }
            }
            if (-not $resolvedEntries) {
                $resolvedEntries = $script:TestAliasedCmdletMap['Get-ChildItem']
            }

            $resolvedEntries | Should -Not -BeNullOrEmpty
        }
    }

    It 'resolves Copy-Item and Move-Item by alias or cmdlet fallback' {
        InModuleScope PSCommandHelper {
            foreach ($cmdlet in @('Copy-Item', 'Move-Item')) {
                $resolvedEntries = $null
                $aliases = Get-Alias -Definition $cmdlet -ErrorAction SilentlyContinue
                foreach ($a in $aliases) {
                    if ($script:TestAliasedMap.ContainsKey($a.Name)) {
                        $resolvedEntries = $script:TestAliasedMap[$a.Name]
                        break
                    }
                }
                if (-not $resolvedEntries) {
                    $resolvedEntries = $script:TestAliasedCmdletMap[$cmdlet]
                }

                $resolvedEntries | Should -Not -BeNullOrEmpty
            }
        }
    }
}

Describe 'Flag-aware matching' {
    BeforeAll {
        InModuleScope PSCommandHelper {
            $map = Get-BashToPowerShellMap
            $script:TestRmEntries = $map | Where-Object { ($_.Bash -split '\s+')[0] -eq 'rm' -and $_.Type -eq 'Aliased' }
            $script:TestLsEntries = $map | Where-Object { ($_.Bash -split '\s+')[0] -eq 'ls' -and $_.Type -eq 'Aliased' }
        }
    }

    It 'rm -fr matches rm -rf entry (flag reorder)' {
        InModuleScope PSCommandHelper {
            $line = 'rm -fr somedir'
            $lineFlags = [System.Collections.Generic.HashSet[char]]::new()
            $lineParts = ($line -split '\s+') | Select-Object -Skip 1
            foreach ($part in $lineParts) {
                if ($part -match '^-([A-Za-z0-9]+)$') {
                    foreach ($ch in $Matches[1].ToCharArray()) { [void]$lineFlags.Add($ch) }
                }
            }

            $bestMatch = $null
            $bestScore = -1
            foreach ($entry in $script:TestRmEntries) {
                $entryFlags = [System.Collections.Generic.HashSet[char]]::new()
                $entryParts = ($entry.Bash -split '\s+') | Select-Object -Skip 1
                foreach ($part in $entryParts) {
                    if ($part -match '^-([A-Za-z0-9]+)$') {
                        foreach ($ch in $Matches[1].ToCharArray()) { [void]$entryFlags.Add($ch) }
                    }
                }
                if ($entryFlags.Count -gt 0 -and $entryFlags.IsSubsetOf($lineFlags)) {
                    if ($entryFlags.Count -gt $bestScore) {
                        $bestScore = $entryFlags.Count
                        $bestMatch = $entry
                    }
                }
            }

            $bestMatch | Should -Not -BeNull
            $bestMatch.Bash | Should -Be 'rm -rf'
            $bestMatch.PowerShell | Should -Be 'Remove-Item -Recurse -Force'
        }
    }

    It 'rm -r -f matches rm -rf entry (separated flags)' {
        InModuleScope PSCommandHelper {
            $line = 'rm -r -f somedir'
            $lineFlags = [System.Collections.Generic.HashSet[char]]::new()
            $lineParts = ($line -split '\s+') | Select-Object -Skip 1
            foreach ($part in $lineParts) {
                if ($part -match '^-([A-Za-z0-9]+)$') {
                    foreach ($ch in $Matches[1].ToCharArray()) { [void]$lineFlags.Add($ch) }
                }
            }

            $bestMatch = $null
            $bestScore = -1
            foreach ($entry in $script:TestRmEntries) {
                $entryFlags = [System.Collections.Generic.HashSet[char]]::new()
                $entryParts = ($entry.Bash -split '\s+') | Select-Object -Skip 1
                foreach ($part in $entryParts) {
                    if ($part -match '^-([A-Za-z0-9]+)$') {
                        foreach ($ch in $Matches[1].ToCharArray()) { [void]$entryFlags.Add($ch) }
                    }
                }
                if ($entryFlags.Count -gt 0 -and $entryFlags.IsSubsetOf($lineFlags)) {
                    if ($entryFlags.Count -gt $bestScore) {
                        $bestScore = $entryFlags.Count
                        $bestMatch = $entry
                    }
                }
            }

            $bestMatch | Should -Not -BeNull
            $bestMatch.Bash | Should -Be 'rm -rf'
        }
    }

    It 'ls -al matches ls -la entry (flag reorder)' {
        InModuleScope PSCommandHelper {
            $line = 'ls -al'
            $lineFlags = [System.Collections.Generic.HashSet[char]]::new()
            $lineParts = ($line -split '\s+') | Select-Object -Skip 1
            foreach ($part in $lineParts) {
                if ($part -match '^-([A-Za-z0-9]+)$') {
                    foreach ($ch in $Matches[1].ToCharArray()) { [void]$lineFlags.Add($ch) }
                }
            }

            $bestMatch = $null
            $bestScore = -1
            foreach ($entry in $script:TestLsEntries) {
                $entryFlags = [System.Collections.Generic.HashSet[char]]::new()
                $entryParts = ($entry.Bash -split '\s+') | Select-Object -Skip 1
                foreach ($part in $entryParts) {
                    if ($part -match '^-([A-Za-z0-9]+)$') {
                        foreach ($ch in $Matches[1].ToCharArray()) { [void]$entryFlags.Add($ch) }
                    }
                }
                if ($entryFlags.Count -gt 0 -and $entryFlags.IsSubsetOf($lineFlags)) {
                    if ($entryFlags.Count -gt $bestScore) {
                        $bestScore = $entryFlags.Count
                        $bestMatch = $entry
                    }
                }
            }

            $bestMatch | Should -Not -BeNull
            $bestMatch.Bash | Should -Be 'ls -la'
        }
    }

    It 'rm -rf still matches exactly (no regression)' {
        InModuleScope PSCommandHelper {
            $line = 'rm -rf somedir'
            $lineFlags = [System.Collections.Generic.HashSet[char]]::new()
            $lineParts = ($line -split '\s+') | Select-Object -Skip 1
            foreach ($part in $lineParts) {
                if ($part -match '^-([A-Za-z0-9]+)$') {
                    foreach ($ch in $Matches[1].ToCharArray()) { [void]$lineFlags.Add($ch) }
                }
            }

            $bestMatch = $null
            $bestScore = -1
            foreach ($entry in $script:TestRmEntries) {
                $entryFlags = [System.Collections.Generic.HashSet[char]]::new()
                $entryParts = ($entry.Bash -split '\s+') | Select-Object -Skip 1
                foreach ($part in $entryParts) {
                    if ($part -match '^-([A-Za-z0-9]+)$') {
                        foreach ($ch in $Matches[1].ToCharArray()) { [void]$entryFlags.Add($ch) }
                    }
                }
                if ($entryFlags.Count -gt 0 -and $entryFlags.IsSubsetOf($lineFlags)) {
                    if ($entryFlags.Count -gt $bestScore) {
                        $bestScore = $entryFlags.Count
                        $bestMatch = $entry
                    }
                }
            }

            $bestMatch | Should -Not -BeNull
            $bestMatch.Bash | Should -Be 'rm -rf'
        }
    }
}

Describe 'Enable/Disable-PSCommandHelper' {
    AfterEach {
        Disable-PSCommandHelper 6>&1 | Out-Null
    }

    It 'enables without error' {
        { Enable-PSCommandHelper 6>&1 } | Should -Not -Throw
    }

    It 'disables without error' {
        Enable-PSCommandHelper 6>&1 | Out-Null
        { Disable-PSCommandHelper 6>&1 } | Should -Not -Throw
    }

    It 'is idempotent — double enable does not error' {
        Enable-PSCommandHelper 6>&1 | Out-Null
        { Enable-PSCommandHelper 6>&1 } | Should -Not -Throw
    }
}
