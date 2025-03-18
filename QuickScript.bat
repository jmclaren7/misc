@echo off
REM This is script combines a number of useful commands into one multiple choice menu.
REM Useful when combined with the tool box feature of some remote access tools like ScreenConnect.
REM https://github.com/jmclaren7/misc/blob/master/QuickScript.bat

REM ================================================================
:option
cls
echo.
echo Hostname: %computername% 
echo User: %userdomain%\%username%
Call :AdminStatus
powershell -NoProfile -ExecutionPolicy Bypass -command ^
"$ErrorActionPreference='silentlycontinue';$p=(Get-Date)-(Get-CimInstance Win32_OperatingSystem -Property LastBootUpTime ^-Namespace root\cimv2).LastBootUpTime;$c=if($p.Days-gt7){'red'}else{(get-host).ui.rawui.ForegroundColor};Write-Host ('Uptime: ' + $p.Days + 'd ' + $p.Hours + 'h ' + $p.Minutes + 'm ' + $p.Seconds + 's') -ForegroundColor $c;$p=Get-Item 'HKLM:\SOFTWARE\Policies\Microsoft\Windows\WindowsUpdate';$v=Get-Item 'HKLM:SOFTWARE\Microsoft\Windows NT\CurrentVersion';$t=if($p.GetValue('TargetReleaseVersion')){' (Targeting: '+[string]$p.GetValue('ProductVersion')+' '+[string]$p.GetValue('TargetReleaseVersionInfo')+')'};Write-Host 'OS:' ((Get-WmiObject Win32_OperatingSystem).Caption) $v.GetValue('DisplayVersion') $t"
echo.  
echo  1. Computer Management   Q. Set Timezone Eastern  A. Disable Fast Startup Using Registry
echo  2. System Properties     W. Edit Hosts File       S. Domain Information (PS Download)
echo  3. Command Prompt        E. Get Wifi Passwords    D. Set Last Logged On User
echo  4. Network Control Panel R. Get IP Information    F. Dell Command Update Installer
echo  5. Print Management      T.                       G. DNS Agent No Internet Fix
echo  6. Print Control Panel   Y.                       H. Restart Explorer With UAC Bypass (2016/2019/2022?)
echo  7. Group Policy Editor   U. VM Hosts Preset       J. Enable SMBv1 and reboot
echo  8. TPM Management        I. Veeam Preset          K. Add Run As to MSI files
echo  9. Advanced Firewall     O. Other Servers Preset  L. Target Windows 11 24H2
echo  0. Power Settings        P. Tech Machine Preset
echo.
choice /C 1234567890abcdefghijklmnopqrstuvwxyz /N
goto option%errorlevel%
REM ================================================================


:option1
compmgmt.msc
exit

:option2
SystemPropertiesComputerName.exe
exit

:option3
cmd.exe
exit

:option4
ncpa.cpl
exit

:option5
printmanagement.msc
exit

:option6
start shell:::{A8A91A66-3A7D-4424-8D24-04E180695C7A}
exit

:option7
gpedit.msc
exit

:option8
tpm.msc
exit

:option9
wf.msc
exit

::0
:option10
control.exe powercfg.cpl,,3
exit

:: A 
:option11
reg add "HKLM\SYSTEM\CurrentControlSet\Control\Session Manager\Power" /f /v HiberbootEnabled /t REG_DWORD /d 0
pause
exit

:: B 
:option12
exit

:: C 
:option13
exit

:: D 
:option14
cls
echo Set last logged on user.
set /p id=Enter the username:
reg delete HKLM\Software\Microsoft\Windows\CurrentVersion\Authentication\LogonUI /f /v LastLoggedOnUserSID
reg delete HKLM\Software\Microsoft\Windows\CurrentVersion\Authentication\LogonUI /f /v LastLoggedOnDisplayName
reg add HKLM\Software\Microsoft\Windows\CurrentVersion\Authentication\LogonUI /f /v LastLoggedOnUser /d "%id%"
reg add HKLM\Software\Microsoft\Windows\CurrentVersion\Authentication\LogonUI /f /v LastLoggedOnSAMUser /d "%id%"
echo.
echo Kill WinLogon.exe to refresh logon screen? (Yes only if you are back stage)
choice /C yn /N /M "y/n: "
goto killwinlogon-%errorlevel%

:: E 
:option15
REM (netsh wlan show profiles) | Select-String "\:(.+)$" | %{$name=$_.Matches.Groups[1].Value.Trim(); $_} | %{(netsh wlan show profile name="$name" key=clear)}  | Select-String "Key Content\W+\:(.+)$" | %{$pass=$_.Matches.Groups[1].Value.Trim(); $_} | %{[PSCustomObject]@{ PROFILE_NAME=$name;PASSWORD=$pass }} | Format-Table -AutoSize
PowerShell.exe -ec KABuAGUAdABzAGgAIAB3AGwAYQBuACAAcwBoAG8AdwAgAHAAcgBvAGYAaQBsAGUAcwApACAAfAAgAFMAZQBsAGUAYwB0AC0AUwB0AHIAaQBuAGcAIAAiAFwAOgAoAC4AKwApACQAIgAgAHwAIAAlAHsAJABuAGEAbQBlAD0AJABfAC4ATQBhAHQAYwBoAGUAcwAuAEcAcgBvAHUAcABzAFsAMQBdAC4AVgBhAGwAdQBlAC4AVAByAGkAbQAoACkAOwAgACQAXwB9ACAAfAAgACUAewAoAG4AZQB0AHMAaAAgAHcAbABhAG4AIABzAGgAbwB3ACAAcAByAG8AZgBpAGwAZQAgAG4AYQBtAGUAPQAiACQAbgBhAG0AZQAiACAAawBlAHkAPQBjAGwAZQBhAHIAKQB9ACAAIAB8ACAAUwBlAGwAZQBjAHQALQBTAHQAcgBpAG4AZwAgACIASwBlAHkAIABDAG8AbgB0AGUAbgB0AFwAVwArAFwAOgAoAC4AKwApACQAIgAgAHwAIAAlAHsAJABwAGEAcwBzAD0AJABfAC4ATQBhAHQAYwBoAGUAcwAuAEcAcgBvAHUAcABzAFsAMQBdAC4AVgBhAGwAdQBlAC4AVAByAGkAbQAoACkAOwAgACQAXwB9ACAAfAAgACUAewBbAFAAUwBDAHUAcwB0AG8AbQBPAGIAagBlAGMAdABdAEAAewAgAFAAUgBPAEYASQBMAEUAXwBOAEEATQBFAD0AJABuAGEAbQBlADsAUABBAFMAUwBXAE8AUgBEAD0AJABwAGEAcwBzACAAfQB9ACAAfAAgAEYAbwByAG0AYQB0AC0AVABhAGIAbABlACAALQBBAHUAdABvAFMAaQB6AGUA
exit

:: F 
:option16
PowerShell.exe -Command "$ProgressPreference = 'SilentlyContinue';$ua='Mozilla/5.0 (Windows NT; Windows NT 10.0; en-US) AppleWebKit/534.6 (KHTML, like Gecko) Chrome/7.0.500.0 Safari/534.6';iwr 'https://dl.dell.com/FOLDER11201586M/1/Dell-Command-Update-Windows-Universal-Application_0XNVX_WIN_5.2.0_A00.EXE' -useragent $ua -outfile 'dcu.exe';saps 'dcu.exe'"
exit

:: G 
:option17
reg add "HKEY_LOCAL_MACHINE\SOFTWARE\POLICIES\MICROSOFT\Windows\NetworkConnectivityStatusIndicator" /v UseGlobalDNS /t REG_DWORD /d 1 /f
exit

:: H 
:option18
Call :Admin
taskkill /f /FI "USERNAME eq $env:UserName"/im explorer.exe
pause
c:\windows\explorer.exe /nouaccheck
pause
exit

:: I 
:option19
tzutil /s "Eastern Standard Time"
Call :SetBackground Green
Call :HideSearch
Call :EnableInactivityTimeout
Call :Timeout 600
Call :AddLoginMessage Warning, "This system is for use by authorized personnel only. Only use this system for backup management."
reg add HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Winlogon /f /v DisableCad /t REG_DWORD /d 0
reg add HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System /f /v LocalAccountTokenFilterPolicy /t REG_DWORD /d 1
reg add HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System /f /v dontdisplaylastusername /t REG_DWORD /d 1
exit

:: J 
:option20
Powershell.exe -EP Bypass Enable-WindowsOptionalFeature -Online -NoRestart -FeatureName SMB1Protocol;Restart-Computer -Force
exit

:: K 
:option21
reg add HKEY_CLASSES_ROOT\Msi.Package\shell\runas\command /f /ve /d "C:\Windows\System32\msiexec.exe /i \"%1\" %*"
exit

:: L 
:option22
reg add HKLM\SOFTWARE\Policies\Microsoft\Windows\WindowsUpdate /f /v TargetReleaseVersion /t REG_DWORD /d 00000001
reg add HKLM\SOFTWARE\Policies\Microsoft\Windows\WindowsUpdate /f /v ProductVersion /d "Windows 11"
reg add HKLM\SOFTWARE\Policies\Microsoft\Windows\WindowsUpdate /f /v TargetReleaseVersionInfo /d "24H2" 
exit

:: M 
:option23
exit

:: N 
:option24
exit

:: O 
:option25
Call :SetBackground Orange
Call :HideSearch
Call :AddLoginMessage Warning, "This system is for use by authorized personnel only."
exit

:: P 
:option26
Call :SetBackground Gray
Call :HideSearch
exit

:: Q 
:option27
tzutil /s "Eastern Standard Time"
exit

:: R 
:option28
PowerShell.exe -Command "Write-Host 'Public IP: ' -NoNewline; (Invoke-WebRequest -UseBasicParsing -Uri 'http://icanhazip.com').Content.Trim()"
PowerShell.exe -Command "& {Get-NetIPConfiguration | Where-Object { $_.IPv4DefaultGateway -ne $null } | Select-Object -Property InterfaceAlias, @{Name='IPv4Address';Expression={$_.IPv4Address.IPAddress}}, @{Name='IPv4DefaultGateway';Expression={$_.IPv4DefaultGateway.NextHop}}, @{Name='DNSServers';Expression={$_.DNSServer.ServerAddresses}} | Format-List}"
pause
goto option

:: S 
:option29
PowerShell.exe -Command ". { iwr -useb https://raw.githubusercontent.com/jmclaren7/misc/master/domain-info.ps1 } | iex; domain-info"
exit

:: T 
:option30
exit

:: U 
:option31
tzutil /s "Eastern Standard Time"
Call :SetBackground Red
Call :Timeout 600
Call :HideSearch
Call :EnableInactivityTimeout
Call :AddLoginMessage Warning, "This system is for use by authorized personnel only. Only use this system for Hyper-V server management."
reg add HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Winlogon /f /v DisableCad /t REG_DWORD /d 0
reg add HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System /f /v LocalAccountTokenFilterPolicy /t REG_DWORD /d 1
reg add HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System /f /v dontdisplaylastusername /t REG_DWORD /d 1
exit

:: V 
:option32
exit

:: W 
:option33
start notepad.exe C:\Windows\System32\drivers\etc\hosts
exit

:: X 
:option34
exit

:: Y 
:option35
exit

:: Z 
:option36
exit




:AutoDCU
cls
PowerShell.exe -Command "$ProgressPreference = 'SilentlyContinue';$ua='Mozilla/5.0 (Windows NT; Windows NT 10.0; en-US) AppleWebKit/534.6 (KHTML, like Gecko) Chrome/7.0.500.0 Safari/534.6';iwr 'https://dl.dell.com/FOLDER10408436M/1/Dell-Command-Update-Windows-Universal-Application_1WR6C_WIN_5.0.0_A00.EXE' -useragent $ua -outfile 'dcu.exe'"
PowerShell.exe -Command "saps 'dcu.exe' /s"

echo Waiting for Dell Command Update to install...
PowerShell.exe -Command do{$count++; if(Test-Path "$env:ProgramFiles\Dell\CommandUpdate\dcu-cli.exe"){ Write-Host "Found"; Break }; Start-Sleep 1} until ($count -ge 10)

Reg.exe add "HKLM\SOFTWARE\DELL\UpdateService\Clients\CommandUpdate\Preferences\CFG" /v "ShowSetupPopup" /t REG_DWORD /d "0" /f
Reg.exe add "HKLM\SOFTWARE\DELL\UpdateService\Clients\CommandUpdate\Preferences\Settings\AdvancedDriverRestore" /v "IsAdvancedDriverRestoreEnabled" /t REG_DWORD /d "0" /f
Reg.exe add "HKLM\SOFTWARE\DELL\UpdateService\Clients\CommandUpdate\Preferences\Settings\General" /v "UserConsentDefault" /t REG_DWORD /d "0" /f
Reg.exe add "HKLM\SOFTWARE\DELL\UpdateService\Clients\CommandUpdate\Preferences\Settings\General" /v "SuspendBitLocker" /t REG_DWORD /d "1" /f
Reg.exe add "HKLM\SOFTWARE\DELL\UpdateService\Clients\CommandUpdate\Preferences\Settings\Schedule" /v "ScheduleMode" /t REG_SZ /d "ManualUpdates" /f
Reg.exe add "HKLM\SOFTWARE\DELL\UpdateService\Service\UpdateScheduler" /v "CurrentUpdateState" /t REG_SZ /d "WaitForScan" /f

REM PowerShell.exe -Command start "shell:AppsFolder\$(Get-StartApps 'Dell Command | Update' | select -ExpandProperty AppId)"
"%ProgramFiles%\Dell\CommandUpdate\dcu-cli.exe" /scan
"%ProgramFiles%\Dell\CommandUpdate\dcu-cli.exe" /applyUpdates -reboot=enable
cmd.exe
exit

REM ================================================================
REM ================================================================

:killwinlogon-2
exit

:killwinlogon-1
taskkill /f /t /im winlogon.exe
exit

:AddLoginMessage
reg add "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System" /f /v legalnoticecaption /t REG_SZ /d "%~1"
reg add "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System" /f /v legalnoticetext /t REG_SZ /d "%~2"
exit /B 0

:HideSearch
reg add "HKCU\SOFTWARE\Microsoft\Windows\CurrentVersion\Search" /f /v SearchboxTaskbarMode /t REG_DWORD /d 0
taskkill /F /IM explorer.exe & start explorer
exit /B 0

:SetBackground
SET BR=%~1
SET BG=%~2
SET BB=%~3
IF "%~1"=="Red"    (SET BR=D1 & SET BG=34 & SET BB=38)
IF "%~1"=="Green"  (SET BR=00 & SET BG=B3 & SET BB=36)
IF "%~1"=="Blue"   (SET BR=00 & SET BG=8C & SET BB=FF)
IF "%~1"=="Orange" (SET BR=FF & SET BG=8C & SET BB=00)
IF "%~1"=="Blue"   (SET BR=22 & SET BG=33 & SET BB=44)
IF "%~1"=="Purple" (SET BR=22 & SET BG=33 & SET BB=44)
IF "%~1"=="Gray"   (SET BR=7F & SET BG=7F & SET BB=7F)
set BGPath=%ProgramData%\RTScripts
set BGFullPath=%BGPath%\backgroundpixel.bmp
mkdir %BGPath%
>backgroundpixel.tmp echo(42 4D 3A 00 00 00 00 00 00 00 36 00 00 00 28 00 00 00 01 00 00 00 01 00 00 00 01 00 18 00 00 00 00 00 00 00 00 00 12 0B 00 00 12 0B 00 00 00 00 00 00 00 00 00 00 %BB% %BG% %BR% 00
certutil -f -decodehex backgroundpixel.tmp %BGFullPath% >nul
del backgroundpixel.tmp
reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\Policies\System" /f /v Wallpaper /t REG_SZ /d "%BGFullPath%"
reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\Policies\System" /f /v WallpaperStyle /t REG_SZ /d 1
taskkill /F /IM explorer.exe & start explorer
exit /B 0

:Timeout
reg add "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System" /f /v InactivityTimeoutSecs /t REG_DWORD /d %~1
exit /B 0

:AdminStatus
net session >nul 2>&1
if %errorLevel% == 0 (
  echo Running Elevated: Yes
  exit /B 1
) else (
  REM echo Running Elevated: No
  echo Running Elevated: [91mNo[0m
  exit /B 0
)
