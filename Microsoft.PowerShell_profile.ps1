#File location: /Users/<username>/.config/powershell/Microsoft.PowerShell_profile.ps1
#requires -Version 7

# Add Homebrew directories to PowerShell PATH
$env:PATH += [IO.Path]::PathSeparator + '/opt/homebrew/bin:/opt/homebrew/sbin'

oh-my-posh init pwsh --config 'https://raw.githubusercontent.com/RylandDeGregory/Config/master/oh-my-posh-ryland.json' | Invoke-Expression

Set-PSReadLineOption -Colors @{ 'Command' = [ConsoleColor]::DarkYellow }
Set-PSReadLineOption -PredictionSource HistoryAndPlugin
Set-PSReadLineOption -PredictionViewStyle ListView
Set-PSReadLineOption -HistorySearchCursorMovesToEnd

Set-PSReadLineKeyHandler -Key Tab -Function Complete
Set-PSReadLineKeyHandler -Key UpArrow -Function HistorySearchBackward
Set-PSReadLineKeyHandler -Key DownArrow -Function HistorySearchForward

if ($IsMacOS) {
    Set-PSReadLineKeyHandler -Key Ctrl+Shift+UpArrow -Function PreviousSuggestion
    Set-PSReadLineKeyHandler -Key Ctrl+Shift+DownArrow -Function NextSuggestion
} else {
    Set-PSReadLineKeyHandler -Key Ctrl+UpArrow -Function PreviousSuggestion
    Set-PSReadLineKeyHandler -Key Ctrl+DownArrow -Function NextSuggestion
}

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

function Resolve-HostName {
    param (
        [Parameter(Mandatory, ValueFromPipeline, Position = 0)]
        [string] $HostName
    )
    return [System.Net.Dns]::GetHostAddresses($HostName).IPAddressToString
}

function Uninstall-OldModule {
    param(
        # Array of modules to uninstall
        [Parameter(Mandatory)]
        $Modules
    )
    foreach ($Module in $Modules) {
        if ($Module.Count -gt 1) {
            $LatestVersion = $Module.Group | Sort-Object Version | Select-Object Version -Last 1
            Write-Output "Removing all versions of $($Module.Name) except latest installed: $($LatestVersion.Version)"
            $Module.Group | Where-Object { $_.Version -ne $LatestVersion.Version } | ForEach-Object {
                Write-Warning "Uninstalling $($_.Name) version $($_.Version)"
                Uninstall-PSResource -Name $_.Name -Version $_.Version
            }
        } else {
            Write-Output "One version of $($Module.Name) installed: $($Module.Group.Version)"
        }
    }
}
New-Alias -Name 'Uninstall-OldModules' -Value Uninstall-OldModule
# $WinModules = Get-Module -ListAvailable Az* | Where-Object { $_.Path -like '*WindowsPowerShell*' } | Group-Object Name
# $CoreModules = Get-Module -ListAvailable Az* | Where-Object { $_.Path -notlike '*WindowsPowerShell*' } | Group-Object Name

function Delete-MultipleGitBranches {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory)]
        [string] $BranchPattern
    )
    git branch | Where-Object { $_.Trim() -like $BranchPattern } | ForEach-Object { git branch -D $_.Trim() }
}

function Restart-AppService {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory)]
        [string] $WebhookURL
    )

    $Username = $WebhookURL.Split('https://').Split(':')[1].Split('@')[0]
    $Password = $WebhookURL.Split('https://').Split(':')[2].Split('@')[0]
    $Headers  = @{ 'Authorization' = "Basic $([Convert]::ToBase64String([Text.Encoding]::ASCII.GetBytes("$Username`:$Password")))" }

    Invoke-RestMethod -Method Post -Uri "https://$($WebhookURL.Split('@')[1])" -Headers $Headers -UserAgent 'powershell/1.0'
}
