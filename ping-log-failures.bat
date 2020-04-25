@echo off

set /p host=Host: 
set logfile=ping_log_%host%.log

echo %date% %time%: Continuous ping running, only showing timeouts to %host%
echo %date% %time%: Continuous ping running, only showing timeouts to %host%>>%logfile%

:Ping

for /f "tokens=* skip=2" %%A in ('ping %host% -n 1 ') do (
echo.%%A | findstr "timed" 1>nul
if NOT errorlevel 1 (
echo %date% %time:~0,2%:%time:~3,2%:%time:~6,2% %%A>>%logfile%
echo %date% %time:~0,2%:%time:~3,2%:%time:~6,2% %%A
)
timeout 1 >NUL 
GOTO Ping)