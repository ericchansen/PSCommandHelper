# PSCommandHelper

> Learn PowerShell by doing. When you type a bash command that doesn't exist in PowerShell, PSCommandHelper suggests the PowerShell equivalent — with an explanation.

## What it does

When you type a bash/Linux command in PowerShell 7 that doesn't resolve (like `rm -rf`, `grep`, `curl`, etc.), PSCommandHelper intercepts the error and shows you:

```
────────────────────────────────────────────────────────────
  💡 PSCommandHelper

  You typed:  rm -rf
  Try this:   Remove-Item -Recurse -Force

  Remove-Item deletes files/folders. -Recurse handles subdirectories, -Force skips confirmation.

  Example:
  > Remove-Item ./build -Recurse -Force
────────────────────────────────────────────────────────────
```

It **does not** run the command for you — the goal is to help you learn, not to auto-correct.

## Installation

### Quick install

```powershell
git clone <repo-url> powershell-helper
cd powershell-helper
.\install.ps1
```

This copies the module to your `Documents\PowerShell\Modules` folder and adds it to your `$PROFILE`.

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

### Temporarily disable

```powershell
Disable-PSCommandHelper
```

### Re-enable

```powershell
Enable-PSCommandHelper
```

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

## Running tests

```powershell
Invoke-Pester ./tests/PSCommandHelper.Tests.ps1
```

## How it works

PowerShell 7 exposes the `$ExecutionContext.InvokeCommand.CommandNotFoundAction` event. When the shell can't find a command by name, this event fires **before** the error is shown. PSCommandHelper registers a handler that:

1. Receives the unrecognized command name
2. Looks it up in a hashtable of bash → PowerShell mappings
3. Displays a colorful, educational suggestion
4. Lets the original error propagate (so you know the command didn't run)

## License

MIT
