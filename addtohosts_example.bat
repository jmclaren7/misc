SET NEWLINE=^& echo.

FIND /C /I "hostname1" %WINDIR%\system32\drivers\etc\hosts
IF %ERRORLEVEL% NEQ 0 ECHO %NEWLINE%^10.6.0.10 hostname1>>%WINDIR%\System32\drivers\etc\hosts

FIND /C /I "hostname2" %WINDIR%\system32\drivers\etc\hosts
IF %ERRORLEVEL% NEQ 0 ECHO %NEWLINE%^10.6.0.10 hostname2 >>%WINDIR%\System32\drivers\etc\hosts

FIND /C /I "hostname3" %WINDIR%\system32\drivers\etc\hosts
IF %ERRORLEVEL% NEQ 0 ECHO %NEWLINE%^10.6.0.10 hostname3>>%WINDIR%\System32\drivers\etc\hosts