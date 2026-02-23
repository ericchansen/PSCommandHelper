@{
    RootModule        = 'PSCommandHelper.psm1'
    ModuleVersion     = '0.1.0'
    GUID              = 'a3f8b2c1-4d5e-6f7a-8b9c-0d1e2f3a4b5c'
    Author            = 'Eric Hansen'
    Description       = 'Learn PowerShell by doing. Detects bash/Linux commands and suggests PowerShell equivalents with explanations.'
    PowerShellVersion = '7.0'

    FunctionsToExport = @(
        'Enable-PSCommandHelper'
        'Disable-PSCommandHelper'
        'Get-CommandMapping'
    )

    CmdletsToExport   = @()
    VariablesToExport  = @()
    AliasesToExport    = @()

    PrivateData = @{
        PSData = @{
            Tags       = @('PowerShell', 'Learning', 'Bash', 'Linux', 'Helper', 'Education')
            ProjectUri = ''
        }
    }
}
