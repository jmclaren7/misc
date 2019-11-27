@echo off
setLocal enableDelayedExpansion

set c=0
set "choices="
echo Interfaces -
for /f "skip=2 tokens=3*" %%A in ('netsh interface show interface') do (
    set /a c+=1
    set int!c!=%%B
    set choices=!choices!!c!
    echo [!c!] %%B
)
choice /c !choices! /m "Select Interface: " /n
set Adapter_Name=!int%errorlevel%!
echo Selected Adapter=%Adapter_Name%

for /f "tokens=1,2 delims=:" %%a in ('netsh interface ip show config name^="%Adapter_Name%"^|find "IP Address"') do set IP=%%b
for /f "tokens=* delims= " %%a in ("%IP%") do set IP=%%a
for /l %%a in (1,1,100) do if "!IP:~-1!"==" " set IP=!IP:~0,-1!
echo Enter an IP address to fallback to [%IP%]
set /p Gateway= || SET "IP=%IP%"

for /f "tokens=1,2 delims=^(mask^)" %%a in ('netsh interface ip show config name^="%Adapter_Name%"^|find "Subnet Prefix"') do set Subnet=%%b
for /f "tokens=* delims= " %%a in ("%Subnet%") do set Subnet=%%a
for /l %%a in (1,1,100) do if "!Subnet:~-1!"==" " set Subnet=!Subnet:~0,-1!
echo Enter a subnet mask to fallback to [%Subnet%]
set /p Subnet= || SET "Subnet=%Subnet%"

for /f "tokens=1,2 delims=:" %%a in ('netsh interface ip show config name^="%Adapter_Name%"^|find "Default Gateway"') do set Gateway=%%b
for /f "tokens=* delims= " %%a in ("%Gateway%") do set Gateway=%%a
for /l %%a in (1,1,100) do if "!Gateway:~-1!"==" " set Gateway=!Gateway:~0,-1!
echo Enter a gateway address to fallback to [%Gateway%]
set /p Gateway= || SET "Gateway=%Gateway%"

echo ------------
echo CONTINUING WILL CHANGE IP SETTINGS TO DHCP (YOU MAY LOOSE CONNECTION)
pause

netsh interface ip set address name = "%Adapter_Name%" source = dhcp
ipconfig /renew

echo Close this window to cancel falling back to a static IP if DHCP works as desired
TIMEOUT /T 30

netsh interface ip set address "%Adapter_Name%" static %IP% %Subnet% %Gateway% 1
pause