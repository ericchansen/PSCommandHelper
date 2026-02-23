# Bash → PowerShell command mapping table
# Each entry: @{ Bash = '...'; PowerShell = '...'; Explanation = '...'; Example = '...' }

function Get-BashToPowerShellMap {
    @(
        # ── File Operations ──────────────────────────────────────────
        @{ Bash = 'rm -rf'; PowerShell = 'Remove-Item -Recurse -Force'; Explanation = 'Remove-Item deletes files/folders. -Recurse handles subdirectories, -Force skips confirmation.'; Example = 'Remove-Item ./build -Recurse -Force' }
        @{ Bash = 'rm -r'; PowerShell = 'Remove-Item -Recurse'; Explanation = 'Remove-Item -Recurse deletes a directory and everything inside it.'; Example = 'Remove-Item ./old-folder -Recurse' }
        @{ Bash = 'rm -f'; PowerShell = 'Remove-Item -Force'; Explanation = 'Remove-Item -Force deletes without prompting for confirmation.'; Example = 'Remove-Item ./file.tmp -Force' }
        @{ Bash = 'rm'; PowerShell = 'Remove-Item'; Explanation = 'Remove-Item (alias: ri, del) deletes files and folders.'; Example = 'Remove-Item ./file.txt' }
        @{ Bash = 'cp -r'; PowerShell = 'Copy-Item -Recurse'; Explanation = 'Copy-Item -Recurse copies a directory and all its contents.'; Example = 'Copy-Item ./src ./backup -Recurse' }
        @{ Bash = 'cp'; PowerShell = 'Copy-Item'; Explanation = 'Copy-Item (alias: copy, ci) copies files or directories.'; Example = 'Copy-Item ./file.txt ./backup.txt' }
        @{ Bash = 'mv'; PowerShell = 'Move-Item'; Explanation = 'Move-Item (alias: move, mi) moves or renames files and directories.'; Example = 'Move-Item ./old.txt ./new.txt' }
        @{ Bash = 'mkdir -p'; PowerShell = 'New-Item -ItemType Directory -Force'; Explanation = 'New-Item -ItemType Directory creates a folder. -Force creates parent dirs if needed.'; Example = 'New-Item -ItemType Directory -Path ./a/b/c -Force' }
        @{ Bash = 'mkdir'; PowerShell = 'New-Item -ItemType Directory'; Explanation = 'New-Item -ItemType Directory creates a new folder.'; Example = 'New-Item -ItemType Directory -Path ./my-folder' }
        @{ Bash = 'touch'; PowerShell = 'New-Item -ItemType File'; Explanation = 'New-Item -ItemType File creates an empty file (or use Set-Content for content).'; Example = 'New-Item -ItemType File -Path ./newfile.txt' }
        @{ Bash = 'cat'; PowerShell = 'Get-Content'; Explanation = 'Get-Content (alias: gc, type) reads file contents to the pipeline.'; Example = 'Get-Content ./readme.md' }
        @{ Bash = 'ls -la'; PowerShell = 'Get-ChildItem -Force'; Explanation = 'Get-ChildItem -Force shows all items including hidden. PS has no -la flag — it always shows details.'; Example = 'Get-ChildItem -Force' }
        @{ Bash = 'ls -l'; PowerShell = 'Get-ChildItem'; Explanation = 'Get-ChildItem (alias: gci, dir) lists directory contents with details by default.'; Example = 'Get-ChildItem ./src' }
        @{ Bash = 'ls -R'; PowerShell = 'Get-ChildItem -Recurse'; Explanation = 'Get-ChildItem -Recurse lists all files/folders recursively.'; Example = 'Get-ChildItem ./src -Recurse' }
        @{ Bash = 'ls'; PowerShell = 'Get-ChildItem'; Explanation = 'Get-ChildItem (alias: gci, dir, ls) lists directory contents.'; Example = 'Get-ChildItem' }
        @{ Bash = 'find'; PowerShell = 'Get-ChildItem -Recurse -Filter'; Explanation = 'Get-ChildItem -Recurse with -Filter or Where-Object replaces find for file searches.'; Example = 'Get-ChildItem -Recurse -Filter "*.log"' }
        @{ Bash = 'ln -s'; PowerShell = 'New-Item -ItemType SymbolicLink'; Explanation = 'New-Item -ItemType SymbolicLink creates a symbolic link. Requires -Target for destination.'; Example = 'New-Item -ItemType SymbolicLink -Path ./link -Target ./original' }
        @{ Bash = 'chmod'; PowerShell = 'Set-Acl / icacls'; Explanation = 'PowerShell uses Set-Acl or icacls.exe for file permissions (Windows ACLs, not Unix modes).'; Example = 'icacls ./file.txt /grant "Users:R"' }
        @{ Bash = 'chown'; PowerShell = 'Set-Acl'; Explanation = 'Set-Acl modifies file ownership/permissions via Access Control Lists.'; Example = '$acl = Get-Acl ./file.txt; Set-Acl -Path ./file.txt -AclObject $acl' }
        @{ Bash = 'stat'; PowerShell = 'Get-Item | Format-List *'; Explanation = 'Get-Item returns a FileInfo object with all metadata. Pipe to Format-List * to see everything.'; Example = 'Get-Item ./file.txt | Format-List *' }
        @{ Bash = 'realpath'; PowerShell = 'Resolve-Path'; Explanation = 'Resolve-Path returns the absolute path of a relative or wildcard path.'; Example = 'Resolve-Path ./some/../file.txt' }
        @{ Bash = 'basename'; PowerShell = 'Split-Path -Leaf'; Explanation = 'Split-Path -Leaf extracts the filename from a path.'; Example = 'Split-Path -Leaf "C:\Users\me\file.txt"' }
        @{ Bash = 'dirname'; PowerShell = 'Split-Path -Parent'; Explanation = 'Split-Path -Parent extracts the directory portion of a path.'; Example = 'Split-Path -Parent "C:\Users\me\file.txt"' }

        # ── Text Processing ──────────────────────────────────────────
        @{ Bash = 'grep -r'; PowerShell = 'Select-String -Recurse'; Explanation = 'Select-String searches text with regex. -Recurse searches all files in subdirectories.'; Example = 'Select-String -Path ./src -Pattern "TODO" -Recurse' }
        @{ Bash = 'grep -i'; PowerShell = 'Select-String -CaseSensitive:$false'; Explanation = 'Select-String is case-insensitive by default. Use -CaseSensitive to make it strict.'; Example = 'Select-String -Path ./log.txt -Pattern "error"' }
        @{ Bash = 'grep'; PowerShell = 'Select-String'; Explanation = 'Select-String (alias: sls) searches for text patterns in files or pipeline input.'; Example = 'Select-String -Path ./app.log -Pattern "error"' }
        @{ Bash = 'sed'; PowerShell = '-replace operator or ForEach-Object'; Explanation = 'Use -replace for regex substitution, or (Get-Content | ForEach-Object) for line-by-line transforms.'; Example = '(Get-Content ./file.txt) -replace "old", "new" | Set-Content ./file.txt' }
        @{ Bash = 'awk'; PowerShell = 'ForEach-Object with -split'; Explanation = 'PowerShell splits fields with -split and processes with ForEach-Object or Select-Object.'; Example = 'Get-Content ./data.txt | ForEach-Object { ($_ -split "\s+")[1] }' }
        @{ Bash = 'head'; PowerShell = 'Select-Object -First'; Explanation = 'Select-Object -First N returns the first N items from the pipeline.'; Example = 'Get-Content ./log.txt | Select-Object -First 10' }
        @{ Bash = 'tail'; PowerShell = 'Select-Object -Last'; Explanation = 'Select-Object -Last N returns the last N items. Use Get-Content -Tail for efficient file tailing.'; Example = 'Get-Content ./log.txt -Tail 20' }
        @{ Bash = 'tail -f'; PowerShell = 'Get-Content -Wait -Tail'; Explanation = 'Get-Content -Wait streams new lines as they are appended (like tail -f).'; Example = 'Get-Content ./app.log -Wait -Tail 10' }
        @{ Bash = 'wc -l'; PowerShell = 'Measure-Object -Line'; Explanation = 'Measure-Object -Line counts lines. Also supports -Word and -Character.'; Example = 'Get-Content ./file.txt | Measure-Object -Line' }
        @{ Bash = 'wc'; PowerShell = 'Measure-Object'; Explanation = 'Measure-Object counts lines (-Line), words (-Word), characters (-Character), or computes stats.'; Example = 'Get-Content ./file.txt | Measure-Object -Line -Word -Character' }
        @{ Bash = 'sort'; PowerShell = 'Sort-Object'; Explanation = 'Sort-Object sorts pipeline input by property. Use -Unique to deduplicate.'; Example = 'Get-Content ./names.txt | Sort-Object' }
        @{ Bash = 'uniq'; PowerShell = 'Sort-Object -Unique'; Explanation = 'Sort-Object -Unique removes duplicates (bash uniq requires sorted input; PS does too with Get-Unique).'; Example = 'Get-Content ./list.txt | Sort-Object -Unique' }
        @{ Bash = 'cut'; PowerShell = 'ForEach-Object with -split or .Substring()'; Explanation = 'Use -split to break lines into fields, then index the field you want.'; Example = 'Get-Content ./csv.txt | ForEach-Object { ($_ -split ",")[0] }' }
        @{ Bash = 'tr'; PowerShell = '-replace or .Replace()'; Explanation = 'Use the -replace operator for character translation or string .Replace() method.'; Example = '"hello world" -replace " ", "_"' }
        @{ Bash = 'tee'; PowerShell = 'Tee-Object'; Explanation = 'Tee-Object sends output to a file AND passes it down the pipeline.'; Example = 'Get-Process | Tee-Object -FilePath ./procs.txt' }
        @{ Bash = 'diff'; PowerShell = 'Compare-Object'; Explanation = 'Compare-Object compares two sets of objects and shows differences.'; Example = 'Compare-Object (Get-Content ./a.txt) (Get-Content ./b.txt)' }

        # ── System / Process ─────────────────────────────────────────
        @{ Bash = 'ps aux'; PowerShell = 'Get-Process'; Explanation = 'Get-Process (alias: gps, ps) lists all running processes with details.'; Example = 'Get-Process | Sort-Object CPU -Descending | Select-Object -First 10' }
        @{ Bash = 'ps'; PowerShell = 'Get-Process'; Explanation = 'Get-Process lists running processes. Use -Name or -Id to filter.'; Example = 'Get-Process -Name "code"' }
        @{ Bash = 'kill'; PowerShell = 'Stop-Process'; Explanation = 'Stop-Process (alias: kill) terminates a process by -Id or -Name.'; Example = 'Stop-Process -Id 1234' }
        @{ Bash = 'kill -9'; PowerShell = 'Stop-Process -Force'; Explanation = 'Stop-Process -Force forcefully terminates a process (like SIGKILL).'; Example = 'Stop-Process -Id 1234 -Force' }
        @{ Bash = 'top'; PowerShell = 'Get-Process | Sort-Object CPU -Descending'; Explanation = 'No direct top equivalent, but sorting Get-Process by CPU approximates it.'; Example = 'while ($true) { Clear-Host; Get-Process | Sort-Object CPU -Descending | Select-Object -First 15; Start-Sleep 2 }' }
        @{ Bash = 'df'; PowerShell = 'Get-PSDrive or Get-Volume'; Explanation = 'Get-PSDrive shows drive usage. Get-Volume provides detailed disk info.'; Example = 'Get-Volume | Format-Table DriveLetter, SizeRemaining, Size' }
        @{ Bash = 'du'; PowerShell = 'Get-ChildItem -Recurse | Measure-Object -Property Length -Sum'; Explanation = 'Measure directory size by summing file lengths recursively.'; Example = 'Get-ChildItem ./src -Recurse | Measure-Object -Property Length -Sum' }
        @{ Bash = 'env'; PowerShell = 'Get-ChildItem Env:'; Explanation = 'The Env: drive contains all environment variables as key-value pairs.'; Example = 'Get-ChildItem Env: | Sort-Object Name' }
        @{ Bash = 'export'; PowerShell = '$env:VAR = "value"'; Explanation = 'Set environment variables with $env:NAME syntax. Persists for the session.'; Example = '$env:NODE_ENV = "production"' }
        @{ Bash = 'which'; PowerShell = 'Get-Command'; Explanation = 'Get-Command (alias: gcm) finds where a command is defined — cmdlet, alias, function, or exe.'; Example = 'Get-Command git' }
        @{ Bash = 'whoami'; PowerShell = '[Environment]::UserName or whoami.exe'; Explanation = 'whoami.exe works on Windows. Alternatively, [Environment]::UserName is pure PowerShell.'; Example = '[Environment]::UserName' }
        @{ Bash = 'hostname'; PowerShell = '[Environment]::MachineName or hostname.exe'; Explanation = 'hostname.exe works, or use the .NET [Environment]::MachineName property.'; Example = '[Environment]::MachineName' }
        @{ Bash = 'uname'; PowerShell = '$PSVersionTable.OS'; Explanation = '$PSVersionTable contains OS and PowerShell version info.'; Example = '$PSVersionTable.OS' }
        @{ Bash = 'uptime'; PowerShell = '(Get-CimInstance Win32_OperatingSystem).LastBootUpTime'; Explanation = 'Calculate uptime from the last boot time via CIM/WMI.'; Example = '(Get-Date) - (Get-CimInstance Win32_OperatingSystem).LastBootUpTime' }
        @{ Bash = 'xargs'; PowerShell = 'ForEach-Object'; Explanation = 'PowerShell pipelines pass objects directly — ForEach-Object processes each one.'; Example = 'Get-ChildItem *.log | ForEach-Object { Remove-Item $_ }' }

        # ── Networking ───────────────────────────────────────────────
        @{ Bash = 'curl'; PowerShell = 'Invoke-RestMethod or Invoke-WebRequest'; Explanation = 'Invoke-RestMethod auto-parses JSON. Invoke-WebRequest returns full response with headers.'; Example = 'Invoke-RestMethod https://api.github.com/zen' }
        @{ Bash = 'wget'; PowerShell = 'Invoke-WebRequest -OutFile'; Explanation = 'Invoke-WebRequest -OutFile downloads a file from a URL.'; Example = 'Invoke-WebRequest -Uri "https://example.com/file.zip" -OutFile ./file.zip' }
        @{ Bash = 'ping'; PowerShell = 'Test-Connection'; Explanation = 'Test-Connection sends ICMP echo requests (like ping) with PowerShell object output.'; Example = 'Test-Connection google.com -Count 4' }
        @{ Bash = 'ifconfig'; PowerShell = 'Get-NetIPAddress'; Explanation = 'Get-NetIPAddress shows IP configuration. Get-NetAdapter shows network adapters.'; Example = 'Get-NetIPAddress | Where-Object AddressFamily -eq "IPv4"' }
        @{ Bash = 'netstat'; PowerShell = 'Get-NetTCPConnection'; Explanation = 'Get-NetTCPConnection shows active TCP connections with state and owning process.'; Example = 'Get-NetTCPConnection -State Listen' }
        @{ Bash = 'ss'; PowerShell = 'Get-NetTCPConnection'; Explanation = 'Get-NetTCPConnection is the PowerShell equivalent of both netstat and ss.'; Example = 'Get-NetTCPConnection | Where-Object State -eq "Established"' }
        @{ Bash = 'nslookup'; PowerShell = 'Resolve-DnsName'; Explanation = 'Resolve-DnsName performs DNS queries with rich object output.'; Example = 'Resolve-DnsName google.com' }
        @{ Bash = 'scp'; PowerShell = 'Copy-Item -ToSession / -FromSession'; Explanation = 'Copy-Item with PS Remoting sessions copies files over WinRM. Or use scp.exe if OpenSSH is installed.'; Example = 'Copy-Item ./file.txt -ToSession $s -Destination "C:\remote\path"' }
        @{ Bash = 'ssh'; PowerShell = 'Enter-PSSession or ssh.exe'; Explanation = 'Enter-PSSession opens an interactive remote PowerShell session. Or use the OpenSSH ssh.exe client.'; Example = 'Enter-PSSession -HostName server01 -UserName admin' }

        # ── Misc / Shell ─────────────────────────────────────────────
        @{ Bash = 'echo'; PowerShell = 'Write-Output'; Explanation = 'Write-Output (alias: echo) sends objects to the pipeline. Write-Host writes directly to console.'; Example = 'Write-Output "Hello, PowerShell!"' }
        @{ Bash = 'printf'; PowerShell = 'Write-Host -f or [string]::Format()'; Explanation = 'Use -f format operator or [string]::Format() for formatted strings.'; Example = '"Name: {0}, Age: {1}" -f "Alice", 30' }
        @{ Bash = 'clear'; PowerShell = 'Clear-Host'; Explanation = 'Clear-Host (alias: cls, clear) clears the terminal screen.'; Example = 'Clear-Host' }
        @{ Bash = 'history'; PowerShell = 'Get-History'; Explanation = 'Get-History (alias: h, history) shows command history for the current session.'; Example = 'Get-History | Select-Object -Last 20' }
        @{ Bash = 'alias'; PowerShell = 'Get-Alias / Set-Alias'; Explanation = 'Get-Alias lists aliases. Set-Alias creates new ones. New-Alias prevents overwriting.'; Example = 'Set-Alias -Name ll -Value Get-ChildItem' }
        @{ Bash = 'man'; PowerShell = 'Get-Help'; Explanation = 'Get-Help (alias: help) shows documentation for cmdlets. Use -Full or -Examples for more.'; Example = 'Get-Help Get-Process -Examples' }
        @{ Bash = 'sudo'; PowerShell = 'Start-Process -Verb RunAs or sudo (PS 7.5+)'; Explanation = 'Start-Process -Verb RunAs elevates to admin. PowerShell 7.5+ supports the sudo command natively on Windows.'; Example = 'Start-Process pwsh -Verb RunAs' }
        @{ Bash = 'exit'; PowerShell = 'exit'; Explanation = 'exit works the same — closes the current PowerShell session.'; Example = 'exit' }
        @{ Bash = 'source'; PowerShell = '. (dot-source)'; Explanation = 'Dot-sourcing (.) runs a script in the current scope, importing its functions and variables.'; Example = '. ./my-script.ps1' }
        @{ Bash = 'sleep'; PowerShell = 'Start-Sleep'; Explanation = 'Start-Sleep pauses execution for a specified number of seconds.'; Example = 'Start-Sleep -Seconds 5' }
        @{ Bash = 'date'; PowerShell = 'Get-Date'; Explanation = 'Get-Date returns the current date/time as a DateTime object with rich formatting.'; Example = 'Get-Date -Format "yyyy-MM-dd HH:mm:ss"' }
        @{ Bash = 'cal'; PowerShell = 'No built-in; use Get-Date and culture info'; Explanation = 'PowerShell has no cal command. You can script a calendar with Get-Date and loops.'; Example = 'Get-Date -Format "MMMM yyyy"' }
        @{ Bash = 'tar'; PowerShell = 'Compress-Archive / Expand-Archive'; Explanation = 'Compress-Archive creates .zip files. Expand-Archive extracts them. For .tar.gz, use tar.exe.'; Example = 'Compress-Archive -Path ./folder -DestinationPath ./archive.zip' }
        @{ Bash = 'zip'; PowerShell = 'Compress-Archive'; Explanation = 'Compress-Archive creates zip archives from files or directories.'; Example = 'Compress-Archive -Path ./docs -DestinationPath ./docs.zip' }
        @{ Bash = 'unzip'; PowerShell = 'Expand-Archive'; Explanation = 'Expand-Archive extracts zip files to a destination directory.'; Example = 'Expand-Archive -Path ./archive.zip -DestinationPath ./output' }

        # ── Piping / Redirection ─────────────────────────────────────
        @{ Bash = '> file'; PowerShell = 'Out-File or > (redirect)'; Explanation = 'PowerShell supports > for redirection. Out-File gives more control over encoding.'; Example = 'Get-Process > ./procs.txt' }
        @{ Bash = '>> file'; PowerShell = 'Out-File -Append or >>'; Explanation = '>> appends output. Out-File -Append does the same with encoding options.'; Example = '"new line" >> ./log.txt' }
        @{ Bash = '2>&1'; PowerShell = '*>&1 or 2>&1'; Explanation = 'PowerShell supports stream redirection. *>&1 merges all streams into output.'; Example = 'command 2>&1 | Out-File ./all-output.txt' }
        @{ Bash = '/dev/null'; PowerShell = '$null or Out-Null'; Explanation = 'Assign to $null or pipe to Out-Null to discard output.'; Example = 'Get-Process | Out-Null' }
    )
}
