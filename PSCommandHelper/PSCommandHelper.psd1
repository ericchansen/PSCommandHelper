@{
    RootModule        = 'PSCommandHelper.psm1'
    ModuleVersion     = '0.2.0'
    GUID              = 'a3f8b2c1-4d5e-6f7a-8b9c-0d1e2f3a4b5c'
    Author            = 'Eric Hansen'
    Description       = 'Learn PowerShell by doing. Detects bash/Linux commands and suggests PowerShell equivalents with explanations.'
    PowerShellVersion = '7.0'

    FunctionsToExport = @(
        'Enable-PSCommandHelper'
        'Disable-PSCommandHelper'
        'Get-CommandMapping'
        'Register-PSCommandHelperPrompt'
        'Unregister-PSCommandHelperPrompt'
    )

    CmdletsToExport   = @()
    VariablesToExport  = @()
    AliasesToExport    = @()

    PrivateData = @{
        PSData = @{
            Tags         = @('PowerShell', 'Learning', 'Bash', 'Linux', 'Helper', 'Education')
            ProjectUri   = 'https://github.com/ericchansen/PSCommandHelper'
            LicenseUri   = 'https://github.com/ericchansen/PSCommandHelper/blob/main/LICENSE'
            ReleaseNotes = 'v0.2.0: Two-tier detection (CommandNotFoundAction + prompt handler for aliased commands), $PSStyle support, cross-platform install, Type metadata on all mappings.'
        }
    }
}
