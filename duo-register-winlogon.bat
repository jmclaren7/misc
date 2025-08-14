@echo off

regsvr32 /s "C:\Program Files\Duo Security\WindowsLogon\DuoCredProv.dll"
regsvr32 /s "C:\Program Files\Duo Security\WindowsLogon\DuoCredFilter.dll"
taskkill /im winlogon.exe

timeout /t 3