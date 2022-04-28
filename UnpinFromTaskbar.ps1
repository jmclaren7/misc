$unpin_taskbar_apps = 
    "Microsoft Store",
    "Microsoft Edge",
    "Mail"

Foreach ($thisapp in $unpin_taskbar_apps){
 ((New-Object -Com Shell.Application).NameSpace('shell:::{4234d49b-0245-4df3-b780-3893943456e1}').Items() | ?{$_.Name -eq $thisapp}).Verbs() | ?{$_.Name.replace('&','') -match 'Unpin from taskbar'} | %{$_.DoIt(); $exec = $true}
}


# Helper code for pinning but it requires pttb.exe from github
$pin_taskbar_apps = 
     "C:\Windows\System32\calc.exe",
     "C:\Program Files\Google\Chrome\Application\chrome.exe"


$pttb = "c:\pttb.exe"

Foreach ($thisapp in $pin_taskbar_apps){
    If(Test-Path -Path $thisapp -PathType Leaf){
        $Desc = [System.Diagnostics.FileVersionInfo]::GetVersionInfo($thisapp).FileDescription
        If(-Not (Test-Path -Path $env:APPDATA"\Microsoft\Internet Explorer\Quick Launch\User Pinned\TaskBar\$Desc.lnk" -PathType Leaf)){
            .$pttb $thisapp
        }
    }
 }