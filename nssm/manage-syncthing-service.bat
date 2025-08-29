@echo off
setlocal

IF /I "%~1" == "install" GOTO install
IF /I "%~1" == "remove" GOTO remove
IF /I "%~1" == "edit" GOTO edit
IF /I "%~1" == "reconfigure" GOTO set_parameters
IF /I "%~1" == "start" GOTO start_manual

:menu
cls
echo.
echo Syncthing Service Management
echo ============================
echo.
echo 1. Install Service
echo 2. Remove Service
echo 3. Edit Service (GUI)
echo 4. Reconfigure Service Parameters
echo 5. Start Syncthing In Console
echo 6. Exit
echo.
CHOICE /C 123456 /M "Enter your choice: "
IF ERRORLEVEL 6 GOTO :eof
IF ERRORLEVEL 5 GOTO start_manual
IF ERRORLEVEL 4 GOTO set_parameters
IF ERRORLEVEL 3 GOTO edit
IF ERRORLEVEL 2 GOTO remove
IF ERRORLEVEL 1 GOTO install
GOTO :eof

:install
echo Installing Syncthing service...
%~sdp0nssm install Syncthing "%~dp0syncthing.exe"
call :set_parameters
echo Starting service...
%~sdp0nssm start syncthing
echo Installation complete.
pause
goto :eof

:remove
echo Removing Syncthing service...
%~sdp0nssm stop syncthing
%~sdp0nssm remove syncthing confirm
echo Removal complete.
pause
goto :eof

:edit
echo Opening NSSM GUI for Syncthing service...
%~sdp0nssm edit syncthing
goto :eof

:start_manual
echo Starting Syncthing manually...
start "Syncthing" "%~dp0syncthing.exe" --no-restart --no-browser --home="""%~dp0."""
goto :eof

:set_parameters
echo Setting parameters...
%~sdp0nssm set syncthing AppParameters --no-restart --no-browser --home="""%~dp0."""
%~sdp0nssm set syncthing Start SERVICE_AUTO_START
%~sdp0nssm set syncthing AppPriority BELOW_NORMAL_PRIORITY_CLASS
%~sdp0nssm set syncthing AppStopMethodThreads 10000
%~sdp0nssm set syncthing AppStopMethodConsole 10000
%~sdp0nssm set syncthing AppStopMethodWindow 10000
%~sdp0nssm set syncthing AppExit Default Exit
%~sdp0nssm set syncthing AppExit 0 Exit
%~sdp0nssm set syncthing AppExit 3 Restart
%~sdp0nssm set syncthing AppExit 4 Restart
echo Parameters set.
pause
goto :eof

endlocal
