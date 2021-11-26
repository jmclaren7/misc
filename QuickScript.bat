@echo off


REM ================================================================
REM ================================================================
:shortcuts7
:misc7
:scripts7
cls  
echo 1. Computer Managment 
echo 2. Group Policy Editor  
echo 3. Printer Managment
echo 4. TPM Management
echo 5. Firewall
echo 6. System Properties (Computer Name,Domain,Profiles,RDP)
echo.
echo 7. [Shortcuts]
echo 8. [Misc]
echo 9. [Scripts]

echo.  
choice /C 123456789 /N /M "Select an option: "
goto shortcuts%errorlevel%

:shortcuts1
compmgmt.msc
exit

:shortcuts2
gpedit.msc
exit

:shortcuts3
printmanagement.msc
exit

:shortcuts4
tpm.msc
exit

:shortcuts5
wf.msc
exit

:shortcuts6
SystemPropertiesComputerName.exe
exit

REM ================================================================
REM ================================================================
:shortcuts9
:misc9
:scripts9
cls  
echo 1. Domain Information (PS Download)
echo 2. Set Last Logged On User
echo 3. 
echo 4. 
echo 5. 
echo 6. 
echo.
echo 7. [Shortcuts]
echo 8. [Misc]
echo 9. [Scripts]

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
exit

:scripts4
exit

:scripts5
exit

:scripts6
exit


REM ================================================================
REM ================================================================
:shortcuts8
:misc8
:scripts8
cls  
echo 1. VMHosts Preset
echo 2. RSupport Preset
echo 3. 
echo 4. 
echo 5. 
echo 6. 
echo.
echo 7. [Shortcuts]
echo 8. [Misc]
echo 9. [Scripts]

echo.  
choice /C 123456789 /N /M "Select an option: "
goto misc%errorlevel%

:misc1
Call :BackgroundRed
Call :HideSearch
exit

:misc2
Call :BackgroundGray
Call :HideSearch
exit

:misc3
exit

:misc4
exit

:misc5
exit

:misc6
exit






REM ================================================================
REM ================================================================

:HideSearch
reg add "HKEY_CURRENT_USER\SOFTWARE\Microsoft\Windows\CurrentVersion\Search" /v SearchboxTaskbarMode /t REG_DWORD /d "0" /f
taskkill /F /IM explorer.exe & start explorer
exit /B 0

:BackgroundRed
>backgroundpixel.tmp echo(42 4D 3A 00 00 00 00 00 00 00 36 00 00 00 28 00 00 00 01 00 00 00 01 00 00 00 01 00 18 00 00 00 00 00 00 00 00 00 12 0B 00 00 12 0B 00 00 00 00 00 00 00 00 00 00 41 41 E6 00
goto SetBackground

:BackgroundGray
>backgroundpixel.tmp echo(42 4D 3A 00 00 00 00 00 00 00 36 00 00 00 28 00 00 00 01 00 00 00 01 00 00 00 01 00 18 00 00 00 00 00 00 00 00 00 12 0B 00 00 12 0B 00 00 00 00 00 00 00 00 00 00 7F 7F 7F 00
goto SetBackground

:SetBackground
certutil -f -decodehex backgroundpixel.tmp %UserProfile%\Pictures\backgroundpixel.bmp >nul
del backgroundpixel.tmp
Powershell -NoLogo -NonInteractive -NoProfile -ExecutionPolicy Bypass -Encoded WwBTAHkAcwB0AGUAbQAuAFQAZQB4AHQALgBFAG4AYwBvAGQAaQBuAGcAXQA6ADoAVQBUAEYAOAAuAEcAZQB0AFMAdAByAGkAbgBnACgAWwBTAHkAcwB0AGUAbQAuAEMAbwBuAHYAZQByAHQAXQA6ADoARgByAG8AbQBCAGEAcwBlADYANABTAHQAcgBpAG4AZwAoACgAJwB7ACIAUwBjAHIAaQBwAHQAIgA6ACIASgBHAE4AdgBaAEcAVQBnAFAAUwBCAEEASgB3ADAASwBkAFgATgBwAGIAbQBjAGcAVQAzAGwAegBkAEcAVgB0AEwAbABKADEAYgBuAFIAcABiAFcAVQB1AFMAVwA1ADAAWgBYAEoAdgBjAEYATgBsAGMAbgBaAHAAWQAyAFYAegBPAHcAMABLAGIAbQBGAHQAWgBYAE4AdwBZAFcATgBsAEkARgBkAHAAYgBqAE0AeQBlAHcAMABLAEkAQwBBAGcASQBIAEIAMQBZAG0AeABwAFkAeQBCAGoAYgBHAEYAegBjAHkAQgBYAFkAVwB4AHMAYwBHAEYAdwBaAFgASgA3AEQAUQBvAGcASQBDAEEAZwBJAEMAQgBiAFIARwB4AHMAUwBXADEAdwBiADMASgAwAEsAQwBKADEAYwAyAFYAeQBNAHoASQB1AFoARwB4AHMASQBpAHcAZwBRADIAaABoAGMAbABOAGwAZABEADEARABhAEcARgB5AFUAMgBWADAATABrAEYAMQBkAEcAOABwAFgAUQAwAEsASQBDAEEAZwBJAEMAQQBnAGMAMwBSAGgAZABHAGwAagBJAEMAQgBsAGUASABSAGwAYwBtADQAZwBhAFcANQAwAEkARgBOADUAYwAzAFIAbABiAFYAQgBoAGMAbQBGAHQAWgBYAFIAbABjAG4ATgBKAGIAbQBaAHYASQBDAGgAcABiAG4AUQBnAGQAVQBGAGoAZABHAGwAdgBiAGkAQQBzAEkARwBsAHUAZABDAEIAMQBVAEcARgB5AFkAVwAwAGcATABDAEIAegBkAEgASgBwAGIAbQBjAGcAYgBIAEIAMgBVAEcARgB5AFkAVwAwAGcATABDAEIAcABiAG4AUQBnAFoAbgBWAFgAYQBXADUASgBiAG0AawBwAEkARABzAE4AQwBpAEEAZwBJAEMAQQBnAEkASABCADEAWQBtAHgAcABZAHkAQgB6AGQARwBGADAAYQBXAE0AZwBkAG0AOQBwAFoAQwBCAFQAWgBYAFIAWABZAFcAeABzAGMARwBGAHcAWgBYAEkAbwBjADMAUgB5AGEAVwA1AG4ASQBIAFIAbwBaAFYAQgBoAGQARwBnAHAAZQAxAE4ANQBjADMAUgBsAGIAVgBCAGgAYwBtAEYAdABaAFgAUgBsAGMAbgBOAEoAYgBtAFoAdgBLAEQASQB3AEwARABBAHMAZABHAGgAbABVAEcARgAwAGEAQwB3AHoASwBUAHQAOQBEAFEAbwBnAEkAQwBBAGcAZgBRADAASwBmAFEAMABLAEoAMABBAE4AQwBtAEYAawBaAEMAMQAwAGUAWABCAGwASQBDAFIAagBiADIAUgBsAEQAUQBwAGIAVgAyAGwAdQBNAHoASQB1AFYAMgBGAHMAYgBIAEIAaABjAEcAVgB5AFgAVABvADYAVQAyAFYAMABWADIARgBzAGIASABCAGgAYwBHAFYAeQBLAEMASQBrAEsAQwBSAGwAYgBuAFkANgBWAFYATgBGAFUAbABCAFMAVAAwAFoASgBUAEUAVQBwAFgARgBCAHAAWQAzAFIAMQBjAG0AVgB6AFgARwBKAGgAWQAyAHQAbgBjAG0AOQAxAGIAbQBSAHcAYQBYAGgAbABiAEMANQBpAGIAWABBAGkASwBRADAASwAiAH0AJwAgAHwAIABDAG8AbgB2AGUAcgB0AEYAcgBvAG0ALQBKAHMAbwBuACkALgBTAGMAcgBpAHAAdAApACkAIAB8ACAAaQBlAHgA
exit /B 0

