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

    It 'each entry has required keys' {
        InModuleScope PSCommandHelper {
            $map = Get-BashToPowerShellMap
            foreach ($entry in $map) {
                $entry.Bash        | Should -Not -BeNullOrEmpty
                $entry.PowerShell  | Should -Not -BeNullOrEmpty
                $entry.Explanation | Should -Not -BeNullOrEmpty
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
}

Describe 'Get-CommandMapping' {
    It 'returns all mappings when no search term is given' {
        $result = Get-CommandMapping 6>&1
        # Should produce output (Write-Host captured via 6>&1)
        $result | Should -Not -BeNullOrEmpty
    }

    It 'filters by search term' {
        $result = Get-CommandMapping -Search 'grep' 6>&1
        $resultText = $result -join "`n"
        $resultText | Should -Match 'grep'
    }

    It 'handles no results gracefully' {
        $result = Get-CommandMapping -Search 'zzz_no_such_command_zzz' 6>&1
        $resultText = $result -join "`n"
        $resultText | Should -Match 'No mappings found'
    }
}

Describe 'Format-Suggestion' {
    It 'produces output without error' {
        InModuleScope PSCommandHelper {
            $mapping = @{
                Bash        = 'rm -rf'
                PowerShell  = 'Remove-Item -Recurse -Force'
                Explanation = 'Test explanation'
                Example     = 'Remove-Item ./test -Recurse -Force'
            }
            { Format-Suggestion -Mapping $mapping -OriginalCommand 'rm -rf' 6>&1 } | Should -Not -Throw
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
