# PSCommandHelper

> Learn PowerShell by doing. When you type a bash command that doesn't work in PowerShell, PSCommandHelper suggests the PowerShell equivalent — with an explanation.

## What it does

PSCommandHelper uses **two-tier detection** to catch bash commands in PowerShell 7:

1. **CommandNotFoundAction hook** — catches commands that don't exist at all (`grep`, `awk`, `sed`, `chmod`, `touch`, etc.)
2. **Prompt handler** — catches aliased commands used with bash-style flags (`ls -la`, `rm -rf`, `ps aux`, etc.)

```
────────────────────────────────────────────────────────────
  💡 PSCommandHelper

  You typed:  grep
  Try this:   Select-String

  Select-String (alias: sls) searches for text patterns in files or pipeline input.

  Example:
  > Select-String -Path ./app.log -Pattern "error"
────────────────────────────────────────────────────────────
```

It **does not** run the command for you — the goal is to help you learn, not to auto-correct.

## Installation

### Quick install

```powershell
git clone https://github.com/ericchansen/PSCommandHelper.git
cd PSCommandHelper
.\install.ps1
```

This copies the module to your user Modules folder and adds it to your `$PROFILE`. Works on Windows, Linux, and macOS.

### Manual install

1. Copy the `PSCommandHelper` folder to a directory in your `$env:PSModulePath`
2. Add these lines to your `$PROFILE`:

```powershell
Import-Module PSCommandHelper
Enable-PSCommandHelper
```

## Usage

Once installed, just use PowerShell normally. When you type a bash command that isn't recognized, you'll see a helpful suggestion.

### Browse all mappings

```powershell
Get-CommandMapping
```

### Search for a specific command

```powershell
Get-CommandMapping -Search "grep"
Get-CommandMapping -Search "file"
```

### Filter by detection type

```powershell
Get-CommandMapping -Type Hook        # Commands that trigger the hook (grep, sed, awk...)
Get-CommandMapping -Type Aliased     # Commands aliased in PS (ls, rm, cp, cat...)
Get-CommandMapping -Type Executable  # Commands that exist as .exe (curl, ping, ssh...)
```

### Temporarily disable

```powershell
Disable-PSCommandHelper
```

### Re-enable

```powershell
Enable-PSCommandHelper
```

## How detection works

Each mapping is tagged with a `Type` that determines how it's detected:

| Type | Icon | Detection Method | Examples |
|------|------|-----------------|----------|
| **Hook** | 🔵 | `CommandNotFoundAction` — command doesn't exist in PS | `grep`, `awk`, `sed`, `chmod`, `touch`, `head`, `tail` |
| **Aliased** | 🟡 | Prompt handler — command exists as a PS alias but bash-style flags fail | `ls -la`, `rm -rf`, `cp -r`, `ps aux`, `kill -9` |
| **Executable** | 🟢 | Informational — command resolves as a Windows .exe | `curl`, `ping`, `ssh`, `tar`, `netstat` |

## Covered commands

The built-in mapping table covers **75+ bash commands** across these categories:

| Category | Examples |
|----------|----------|
| **File operations** | `rm`, `cp`, `mv`, `mkdir`, `touch`, `cat`, `ls`, `find`, `chmod`, `ln -s` |
| **Text processing** | `grep`, `sed`, `awk`, `head`, `tail`, `wc`, `sort`, `uniq`, `cut`, `tr`, `diff` |
| **System/process** | `ps`, `kill`, `top`, `df`, `du`, `env`, `export`, `which`, `whoami` |
| **Networking** | `curl`, `wget`, `ping`, `ifconfig`, `netstat`, `ssh`, `scp`, `nslookup` |
| **Shell/misc** | `echo`, `clear`, `history`, `alias`, `man`, `sudo`, `source`, `tar`, `zip` |
| **Piping/redirection** | `> file`, `>> file`, `2>&1`, `/dev/null` |

## Requirements

- **PowerShell 7.0+** (uses `CommandNotFoundAction` which is not available in Windows PowerShell 5.1)
- **PS 7.2+** recommended for `$PSStyle` color support (falls back to raw ANSI on 7.0-7.1)

## Running tests

```powershell
Invoke-Pester ./tests/PSCommandHelper.Tests.ps1
```

## License

MIT
