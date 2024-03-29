@echo off
REM ================================================================
REM ================================================================
:main
cls  
echo 1. Computer Managment 
echo 2. System Properties
echo 3. 
echo 4. 
echo 5. 
echo 6. [MMC+CPL]
echo 7. [Presets]
echo 8. [Misc]
echo 9. 


echo.  
choice /C 123456789 /N /M "Select an option: "
goto main%errorlevel%

:main1
compmgmt.msc
exit

:main2
SystemPropertiesComputerName.exe
exit

:main3
exit

:main4
exit

:main5
exit

:main6
goto mmcs
exit

:main7
goto presets
exit

:main8
goto scripts
exit

:main9
exit




REM ================================================================
REM ================================================================
:mmcs
cls  
echo 1. Computer Managment 
echo 2. Group Policy Editor
echo 3. Print Managment
echo 4. TPM Management
echo 5. Advanced Firewall
echo 6. Power Settings
echo 7. 
echo 8. 
echo 9. [Main Menu]

echo.  
choice /C 123456789 /N /M "Select an option: "
goto mmcs%errorlevel%

:mmcs1
compmgmt.msc
exit

:mmcs2
gpedit.msc
exit

:mmcs3
printmanagement.msc
exit

:mmcs4
tpm.msc
exit

:mmcs5
wf.msc
exit

:mmcs6
control.exe powercfg.cpl,,3
exit

:mmcs7
exit

:mmcs8
exit

:mmcs9
goto main
exit



REM ================================================================
REM ================================================================
:presets
cls  
echo 1. VMHosts Preset
echo 2. RSupport Preset
echo 3. Veeam Preset
echo 4. Other Servers Preset
echo 5. 
echo 6. 
echo 7. 
echo 8. 
echo 9. [Main Menu]

echo.  
choice /C 123456789 /N /M "Select an option: "
goto presets%errorlevel%

:presets1
Call :SetBackground Red
Call :Timeout 600
Call :HideSearch
Call :AddLoginMessage Warning!, "Authorized personnel only. Only use this machine for Hyper-V server managment!"
reg add HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System /v LocalAccountTokenFilterPolicy /t REG_DWORD /d 1
exit

:presets2
Call :SetBackground Gray
Call :Timeout 600
Call :HideSearch
exit

:presets3
Call :SetBackground Green
Call :HideSearch
Call :Timeout 600
Call :AddLoginMessage Warning!, "Authorized personnel only. Only use this machine for backup managment!"
exit

:presets4
Call :SetBackground Orange
Call :HideSearch
Call :AddLoginMessage Warning!, "Authorized personnel only."
exit

:presets5
exit

:presets6
exit

:presets7
exit

:presets8
exit

:presets9
goto main

REM ================================================================
REM ================================================================
:scripts
cls  
echo 1. Domain Information (PS Download)
echo 2. Set Last Logged On User
echo 3. Dell Command Update
echo 4. Umbrella No Internet Fix
echo 5. Set Target Version To Windows 10 21H2
echo 6. Restart Explorer With UAC Bypass
echo 7. Disable ScreenConnect (for machines that use disabled by default script)
echo 8. Add Run As to MSI files
echo 9. [Main Menu]

echo.  
choice /C 123456789 /N /M "Select an option: "
goto scripts%errorlevel%

:scripts1
PowerShell.exe -Command ". { iwr -useb https://raw.githubusercontent.com/jmclaren7/misc/master/domain-info.ps1 } | iex; domain-info"
exit

:scripts2
cls
echo Set last logged on user.
set /p id=Enter the username:
reg add HKLM\Software\Microsoft\Windows\CurrentVersion\Authentication\LogonUI /f /v LastLoggedOnUserSID /d ""
reg add HKLM\Software\Microsoft\Windows\CurrentVersion\Authentication\LogonUI /f /v LastLoggedOnDisplayName /d ""
reg add HKLM\Software\Microsoft\Windows\CurrentVersion\Authentication\LogonUI /f /v LastLoggedOnUser /d "%id%"
reg add HKLM\Software\Microsoft\Windows\CurrentVersion\Authentication\LogonUI /f /v LastLoggedOnSAMUser /d "%id%"
echo.
echo Kill WinLogon.exe to refresh logon screen? (Yes only if you are back stage)
choice /C yn /N /M "y/n: "
goto killwinlogon-%errorlevel%
:killwinlogon-2
exit
:killwinlogon-1
taskkill /f /t /im winlogon.exe

:scripts3
PowerShell.exe -Command "$ProgressPreference = 'SilentlyContinue';$ua='Mozilla/5.0 (Windows NT; Windows NT 10.0; en-US) AppleWebKit/534.6 (KHTML, like Gecko) Chrome/7.0.500.0 Safari/534.6';iwr 'https://dl.dell.com/FOLDER08911630M/1/Dell-Command-Update-Application_T97XP_WIN_4.6.0_A00.EXE' -useragent $ua -outfile 'dell-cu.exe';saps 'dell-cu.exe'"
REM start https://dl.dell.com/FOLDER08334841M/4/Dell-Command-Update-Application_W4HP2_WIN_4.5.0_A00_02.EXE
exit

:scripts4
reg add "HKEY_LOCAL_MACHINE\SOFTWARE\POLICIES\MICROSOFT\Windows\NetworkConnectivityStatusIndicator" /v UseGlobalDNS /t REG_DWORD /d 1 /f
exit

:scripts5
reg add HKEY_LOCAL_MACHINE\SOFTWARE\Policies\Microsoft\Windows\WindowsUpdate /v TargetReleaseVersion /t REG_DWORD /d 00000001 /f
reg add HKEY_LOCAL_MACHINE\SOFTWARE\Policies\Microsoft\Windows\WindowsUpdate /v ProductVersion /d "Windows 10" /f
reg add HKEY_LOCAL_MACHINE\SOFTWARE\Policies\Microsoft\Windows\WindowsUpdate /v TargetReleaseVersionInfo /d "21H2" /f

exit

:scripts6
Call :Admin
taskkill /f /im explorer.exe
start c:\windows\explorer.exe /nouaccheck
exit

:scripts7
reg add "HKLM\SOFTWARE\RTScripts\DisabledByDefault" /v Enable /t REG_DWORD /d 0 /f
exit

:scripts8
reg add HKEY_CLASSES_ROOT\Msi.Package\shell\runas\command /f /ve /d "C:\Windows\System32\msiexec.exe /i \"%1\" %*"
exit

:scripts9
goto main


REM ================================================================
REM ================================================================
:AddLoginMessage
reg add "HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System" /v legalnoticecaption /t REG_SZ /d "%~1" /f
reg add "HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System" /v legalnoticetext /t REG_SZ /d "%~2" /f
exit /B 0

:HideSearch
reg add "HKEY_CURRENT_USER\SOFTWARE\Microsoft\Windows\CurrentVersion\Search" /v SearchboxTaskbarMode /t REG_DWORD /d 0 /f
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
reg add "HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\Policies\System" /v Wallpaper /t REG_SZ /d "%BGFullPath%" /f
reg add "HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\Policies\System" /v WallpaperStyle /t REG_SZ /d 1 /f
taskkill /F /IM explorer.exe & start explorer
exit /B 0

:Timeout
reg add "HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System" /v InactivityTimeoutSecs /t REG_DWORD /d %~1 /f


:Admin
echo Administrative permissions required. Detecting permissions...
net session >nul 2>&1
if %errorLevel% == 0 (
  echo Success: Administrative permissions confirmed, continuing.
) else (
  echo Failure: Not running with elevated permisions, please restart tool.
  pause >nul
  exit
)
    
