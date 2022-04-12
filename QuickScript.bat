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
echo 6. [MMC]
echo 7. [Presets]
echo 8. [Scripts]
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
echo 6. 
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
echo 4. 
echo 5. 
echo 6. 
echo 7. 
echo 8. 
echo 9. [Main Menu]

echo.  
choice /C 123456789 /N /M "Select an option: "
goto presets%errorlevel%

:presets1
Call :BackgroundRed
Call :HideSearch
Call :AddLoginMessage Warning!, "This system is only for use by authorized personnel. Only use this machine for Hyper-V server managment, not to be used for any other purpose."
reg add HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System /v LocalAccountTokenFilterPolicy /t REG_DWORD /d 1
exit

:presets2
Call :BackgroundGray
Call :HideSearch
exit

:presets3
Call :BackgroundGreen
Call :HideSearch
:AddLoginMessage Warning!, "This system is only for use by authorized personnel. Only use this machine for backup managment."
exit

:presets4
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
echo 6. 
echo 7. 
echo 8. 
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
reg delete HKLM\Software\Microsoft\Windows\CurrentVersion\Authentication\LogonUI /v LastLoggedOnUserSID /f
reg delete HKLM\Software\Microsoft\Windows\CurrentVersion\Authentication\LogonUI /v LastLoggedOnDisplayName /f
reg add HKLM\Software\Microsoft\Windows\CurrentVersion\Authentication\LogonUI /v LastLoggedOnUser /d %id% /f
reg add HKLM\Software\Microsoft\Windows\CurrentVersion\Authentication\LogonUI /v LastLoggedOnSAMUser /d %id% /f
exit

:scripts3
REM PowerShell.exe -Command "wget 'https://dl.dell.com/FOLDER07820512M/1/Dell-Command-Update-Application_8DGG4_WIN_4.4.0_A00.EXE' -outfile 'dell-cu.exe';saps 'dell-cu.exe'"
start https://dl.dell.com/FOLDER07820512M/1/Dell-Command-Update-Application_8DGG4_WIN_4.4.0_A00.EXE
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
exit

:scripts7
exit

:scripts8
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

:BackgroundGreen
>backgroundpixel.tmp echo(42 4D 3A 00 00 00 00 00 00 00 36 00 00 00 28 00 00 00 01 00 00 00 01 00 00 00 01 00 18 00 00 00 00 00 00 00 00 00 12 0B 00 00 12 0B 00 00 00 00 00 00 00 00 00 00 36 B3 00 00
goto SetBackground

:BackgroundBlue
>backgroundpixel.tmp echo(42 4D 3A 00 00 00 00 00 00 00 36 00 00 00 28 00 00 00 01 00 00 00 01 00 00 00 01 00 18 00 00 00 00 00 00 00 00 00 12 0B 00 00 12 0B 00 00 00 00 00 00 00 00 00 00 FF 8C 00 00
goto SetBackground

:BackgroundOrange
>backgroundpixel.tmp echo(42 4D 3A 00 00 00 00 00 00 00 36 00 00 00 28 00 00 00 01 00 00 00 01 00 00 00 01 00 18 00 00 00 00 00 00 00 00 00 12 0B 00 00 12 0B 00 00 00 00 00 00 00 00 00 00 00 8C FF 00
goto SetBackground

:BackgroundRed
>backgroundpixel.tmp echo(42 4D 3A 00 00 00 00 00 00 00 36 00 00 00 28 00 00 00 01 00 00 00 01 00 00 00 01 00 18 00 00 00 00 00 00 00 00 00 12 0B 00 00 12 0B 00 00 00 00 00 00 00 00 00 00 38 34 D1 00
goto SetBackground

:BackgroundGray
>backgroundpixel.tmp echo(42 4D 3A 00 00 00 00 00 00 00 36 00 00 00 28 00 00 00 01 00 00 00 01 00 00 00 01 00 18 00 00 00 00 00 00 00 00 00 12 0B 00 00 12 0B 00 00 00 00 00 00 00 00 00 00 7F 7F 7F 00
goto SetBackground

:SetBackground
certutil -f -decodehex backgroundpixel.tmp %UserProfile%\Pictures\backgroundpixel.bmp >nul
del backgroundpixel.tmp
Powershell -NoLogo -NonInteractive -NoProfile -ExecutionPolicy Bypass -Encoded WwBTAHkAcwB0AGUAbQAuAFQAZQB4AHQALgBFAG4AYwBvAGQAaQBuAGcAXQA6ADoAVQBUAEYAOAAuAEcAZQB0AFMAdAByAGkAbgBnACgAWwBTAHkAcwB0AGUAbQAuAEMAbwBuAHYAZQByAHQAXQA6ADoARgByAG8AbQBCAGEAcwBlADYANABTAHQAcgBpAG4AZwAoACgAJwB7ACIAUwBjAHIAaQBwAHQAIgA6ACIASgBHAE4AdgBaAEcAVQBnAFAAUwBCAEEASgB3ADAASwBkAFgATgBwAGIAbQBjAGcAVQAzAGwAegBkAEcAVgB0AEwAbABKADEAYgBuAFIAcABiAFcAVQB1AFMAVwA1ADAAWgBYAEoAdgBjAEYATgBsAGMAbgBaAHAAWQAyAFYAegBPAHcAMABLAGIAbQBGAHQAWgBYAE4AdwBZAFcATgBsAEkARgBkAHAAYgBqAE0AeQBlAHcAMABLAEkAQwBBAGcASQBIAEIAMQBZAG0AeABwAFkAeQBCAGoAYgBHAEYAegBjAHkAQgBYAFkAVwB4AHMAYwBHAEYAdwBaAFgASgA3AEQAUQBvAGcASQBDAEEAZwBJAEMAQgBiAFIARwB4AHMAUwBXADEAdwBiADMASgAwAEsAQwBKADEAYwAyAFYAeQBNAHoASQB1AFoARwB4AHMASQBpAHcAZwBRADIAaABoAGMAbABOAGwAZABEADEARABhAEcARgB5AFUAMgBWADAATABrAEYAMQBkAEcAOABwAFgAUQAwAEsASQBDAEEAZwBJAEMAQQBnAGMAMwBSAGgAZABHAGwAagBJAEMAQgBsAGUASABSAGwAYwBtADQAZwBhAFcANQAwAEkARgBOADUAYwAzAFIAbABiAFYAQgBoAGMAbQBGAHQAWgBYAFIAbABjAG4ATgBKAGIAbQBaAHYASQBDAGgAcABiAG4AUQBnAGQAVQBGAGoAZABHAGwAdgBiAGkAQQBzAEkARwBsAHUAZABDAEIAMQBVAEcARgB5AFkAVwAwAGcATABDAEIAegBkAEgASgBwAGIAbQBjAGcAYgBIAEIAMgBVAEcARgB5AFkAVwAwAGcATABDAEIAcABiAG4AUQBnAFoAbgBWAFgAYQBXADUASgBiAG0AawBwAEkARABzAE4AQwBpAEEAZwBJAEMAQQBnAEkASABCADEAWQBtAHgAcABZAHkAQgB6AGQARwBGADAAYQBXAE0AZwBkAG0AOQBwAFoAQwBCAFQAWgBYAFIAWABZAFcAeABzAGMARwBGAHcAWgBYAEkAbwBjADMAUgB5AGEAVwA1AG4ASQBIAFIAbwBaAFYAQgBoAGQARwBnAHAAZQAxAE4ANQBjADMAUgBsAGIAVgBCAGgAYwBtAEYAdABaAFgAUgBsAGMAbgBOAEoAYgBtAFoAdgBLAEQASQB3AEwARABBAHMAZABHAGgAbABVAEcARgAwAGEAQwB3AHoASwBUAHQAOQBEAFEAbwBnAEkAQwBBAGcAZgBRADAASwBmAFEAMABLAEoAMABBAE4AQwBtAEYAawBaAEMAMQAwAGUAWABCAGwASQBDAFIAagBiADIAUgBsAEQAUQBwAGIAVgAyAGwAdQBNAHoASQB1AFYAMgBGAHMAYgBIAEIAaABjAEcAVgB5AFgAVABvADYAVQAyAFYAMABWADIARgBzAGIASABCAGgAYwBHAFYAeQBLAEMASQBrAEsAQwBSAGwAYgBuAFkANgBWAFYATgBGAFUAbABCAFMAVAAwAFoASgBUAEUAVQBwAFgARgBCAHAAWQAzAFIAMQBjAG0AVgB6AFgARwBKAGgAWQAyAHQAbgBjAG0AOQAxAGIAbQBSAHcAYQBYAGgAbABiAEMANQBpAGIAWABBAGkASwBRADAASwAiAH0AJwAgAHwAIABDAG8AbgB2AGUAcgB0AEYAcgBvAG0ALQBKAHMAbwBuACkALgBTAGMAcgBpAHAAdAApACkAIAB8ACAAaQBlAHgA
exit /B 0

