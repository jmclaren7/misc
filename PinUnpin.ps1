# Unpin from taskbar
$unpin_taskbar_apps = 
    "Microsoft Store",
    "Microsoft Edge",
    "Mail"

Foreach ($thisapp in $unpin_taskbar_apps){
 ((New-Object -Com Shell.Application).NameSpace('shell:::{4234d49b-0245-4df3-b780-3893943456e1}').Items() | ?{$_.Name -eq $thisapp}).Verbs() | ?{$_.Name.replace('&','') -match 'Unpin from taskbar'} | %{$_.DoIt(); $exec = $true}
}

# Search bar off
Set-ItemProperty -Path HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Search -Name SearchBoxTaskbarMode -Value 0 -Type DWord -Force

# Quick Access
$o = New-Object -ComObject shell.application 
#$o.Namespace('P:\').Self.InvokeVerb("pintohome")
#$o.Namespace('Q:\').Self.InvokeVerb("pintohome")


# Pin to taskbar (requires pttb.exe)
$pin_taskbar_apps = 
    "C:\Program Files\Google\Chrome\Application\chrome.exe"
$pttbexe = "$PSScriptRoot\pttb.exe"

if (Get-Item -Path $pttb -ErrorAction Ignore) {
    Foreach ($thisapp in $pin_taskbar_apps){
        If(Test-Path -Path $thisapp -PathType Leaf){
            $Desc = [System.Diagnostics.FileVersionInfo]::GetVersionInfo($thisapp).FileDescription
            If(-Not (Test-Path -Path $env:APPDATA"\Microsoft\Internet Explorer\Quick Launch\User Pinned\TaskBar\$Desc.lnk" -PathType Leaf)){
                .$pttbexe $thisapp
            }
        }
     }
 }

