<#
.SYNOPSIS
    Installs PSCommandHelper and adds it to your PowerShell profile.
.DESCRIPTION
    Copies the PSCommandHelper module to your user Modules folder and
    adds Import-Module + Enable-PSCommandHelper to your $PROFILE so
    it activates automatically in every new session.
.PARAMETER NoProfile
    Skip modifying $PROFILE. You can add the import lines yourself.
#>
[CmdletBinding()]
param(
    [switch]$NoProfile
)

$ErrorActionPreference = 'Stop'

# Determine target module path (cross-platform)
$userModulePaths = $env:PSModulePath -split [IO.Path]::PathSeparator
# Pick the first user-scoped path (typically user's home-based modules directory)
$targetBase = $userModulePaths | Where-Object {
    $_ -like "*$([Environment]::GetFolderPath('UserProfile'))*" -or
    $_ -like "$HOME*"
} | Select-Object -First 1

if (-not $targetBase) {
    # Fallback: first path in PSModulePath
    $targetBase = $userModulePaths[0]
}

$modulesDir = Join-Path $targetBase 'PSCommandHelper'
$sourceDir  = Join-Path $PSScriptRoot 'PSCommandHelper'

if (-not (Test-Path $sourceDir)) {
    Write-Error "Cannot find the PSCommandHelper module folder at '$sourceDir'. Run this script from the repo root."
    return
}

# Copy module files
Write-Host "📦 Installing PSCommandHelper to: $modulesDir" -ForegroundColor Cyan

if (Test-Path $modulesDir) {
    Remove-Item $modulesDir -Recurse -Force
}
Copy-Item $sourceDir $modulesDir -Recurse -Force

Write-Host "✅ Module files copied." -ForegroundColor Green

# Validate the module loads
try {
    Import-Module $modulesDir -Force -ErrorAction Stop
    Write-Host "✅ Module loads successfully." -ForegroundColor Green
    Remove-Module PSCommandHelper -ErrorAction SilentlyContinue
}
catch {
    Write-Error "Module failed to load: $_"
    return
}

# Update $PROFILE
if (-not $NoProfile) {
    $profilePath = $PROFILE.CurrentUserCurrentHost

    # Create profile if it doesn't exist
    if (-not (Test-Path $profilePath)) {
        New-Item -ItemType File -Path $profilePath -Force | Out-Null
        Write-Host "📄 Created new profile at: $profilePath" -ForegroundColor Cyan
    }

    $profileContent = Get-Content $profilePath -Raw -ErrorAction SilentlyContinue

    $importLine = 'Import-Module PSCommandHelper'
    $enableLine = 'Enable-PSCommandHelper'

    $linesToAdd = @()

    if ($profileContent -notmatch [regex]::Escape($importLine)) {
        $linesToAdd += $importLine
    }
    if ($profileContent -notmatch [regex]::Escape($enableLine)) {
        $linesToAdd += $enableLine
    }

    if ($linesToAdd.Count -gt 0) {
        $block = "`n# PSCommandHelper - learn PowerShell by doing`n" + ($linesToAdd -join "`n") + "`n"
        Add-Content -Path $profilePath -Value $block
        Write-Host "✅ Added to profile: $profilePath" -ForegroundColor Green
        Write-Host "   Lines added:" -ForegroundColor DarkGray
        $linesToAdd | ForEach-Object { Write-Host "     $_" -ForegroundColor DarkGray }
    }
    else {
        Write-Host "ℹ️  Profile already contains PSCommandHelper lines." -ForegroundColor Yellow
    }
}
else {
    Write-Host "ℹ️  Skipped profile modification (-NoProfile). Add these lines to your `$PROFILE manually:" -ForegroundColor Yellow
    Write-Host "     Import-Module PSCommandHelper" -ForegroundColor DarkGray
    Write-Host "     Enable-PSCommandHelper" -ForegroundColor DarkGray
}

Write-Host ""
Write-Host "🎉 Done! Restart PowerShell or run:" -ForegroundColor Green
Write-Host "     Import-Module PSCommandHelper; Enable-PSCommandHelper" -ForegroundColor Cyan
Write-Host ""
