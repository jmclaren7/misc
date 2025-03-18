# This script is used as a readable version of powershell code from QuickScripts.bat

$scriptBlock = {
    $ErrorActionPreference = 'silentlycontinue'

    $p = (Get-Date) - (Get-CimInstance Win32_OperatingSystem -Property LastBootUpTime -Namespace root\cimv2).LastBootUpTime
    $c = if ($p.Days -gt 7) { 'red' } else { (get-host).ui.rawui.ForegroundColor }
    Write-Host ('Uptime: ' + $p.Days + 'd ' + $p.Hours + 'h ' + $p.Minutes + 'm ' + $p.Seconds + 's') -ForegroundColor $c

    $p = Get-Item 'HKLM:\SOFTWARE\Policies\Microsoft\Windows\WindowsUpdate'
    $v = Get-Item 'HKLM:SOFTWARE\Microsoft\Windows NT\CurrentVersion' 
    $t = if($p.GetValue('TargetReleaseVersion')){' (Targeting: ' + [string]$p.GetValue('ProductVersion') + ' ' + [string]$p.GetValue('TargetReleaseVersionInfo') + ')'}
    Write-Host 'OS:' ((Get-WmiObject Win32_OperatingSystem).Caption) $v.GetValue('DisplayVersion') $t

}
& $scriptBlock

"=============================================="
$compressed = Compress-ScriptBlock -ScriptBlock $scriptBlock -PassThru
$compressed
"=============================================="
$bytes = [System.Text.Encoding]::Unicode.GetBytes($compressed)
$encodedScript = [Convert]::ToBase64String($bytes)
$encodedScript
"=============================================="