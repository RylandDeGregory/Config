#File location: /Users/<username>/.config/powershell/Microsoft.PowerShell_profile.ps1
oh-my-posh --init --shell pwsh --config '~\oh-my-posh-theme.omp.json' | Invoke-Expression

Set-PSReadLineOption -Colors @{ 'Command' = [ConsoleColor]::DarkYellow }
Set-PSReadLineOption -PredictionSource HistoryAndPlugin
Set-PSReadLineOption -PredictionViewStyle ListView
Set-PSReadLineOption -HistorySearchCursorMovesToEnd

Set-PSReadlineKeyHandler -Key Tab -Function Complete
Set-PSReadLineKeyHandler -Key UpArrow -Function HistorySearchBackward
Set-PSReadLineKeyHandler -Key DownArrow -Function HistorySearchForward
Set-PSReadLineKeyHandler -Key Ctrl+UpArrow -Function PreviousSuggestion
Set-PSReadLineKeyHandler -Key Ctrl+DownArrow -Function NextSuggestion

function New-Base64String {
    param (
        [Parameter(Mandatory, ValueFromPipeline, Position = 0)]
        [string] $Text
    )
    return [System.Convert]::ToBase64String([System.Text.Encoding]::UTF8.GetBytes($Text))
}
New-Alias -Name 'ToBase64' -Value New-Base64String
function New-StringFromBase64 {
    param (
        [Parameter(Mandatory, ValueFromPipeline, Position = 0)]
        [string] $Text
    )
    return [System.Text.Encoding]::UTF8.GetString([System.Convert]::FromBase64String($Text))
}
New-Alias -Name 'FromBase64' -Value New-StringFromBase64

function Resolve-IP {
    param (
        [Parameter(Mandatory, ValueFromPipeline, Position = 0)]
        [IPAddress] $IPAddress
    )
    return [System.Net.Dns]::GetHostByAddress("$($IPAddress.IPAddressToString)").HostName
}
