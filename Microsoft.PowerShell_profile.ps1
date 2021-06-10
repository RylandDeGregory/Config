File location: /Users/<username>/.config/powershell/Microsoft.PowerShell_profile.ps1
---
Set-PoshPrompt -Theme "~/.oh-my-posh-theme.omp.json"
Set-PSReadLineOption -Colors @{ "Command" = [ConsoleColor]::DarkYellow }
Set-PSReadlineKeyHandler -Key Tab -Function MenuComplete
Set-PSReadLineKeyHandler -Key UpArrow -Function HistorySearchBackward
Set-PSReadLineKeyHandler -Key DownArrow -Function HistorySearchForward
