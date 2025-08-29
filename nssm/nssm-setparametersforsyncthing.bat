%~dp0nssm set syncthing AppParameters --no-restart --no-browser --home=%~dp0
%~dp0nssm set syncthing Start SERVICE_AUTO_START
%~dp0nssm set syncthing AppPriority BELOW_NORMAL_PRIORITY_CLASS
%~dp0nssm set syncthing AppStopMethodThreads 10000
%~dp0nssm set syncthing AppStopMethodConsole 10000
%~dp0nssm set syncthing AppStopMethodWindow 10000
%~dp0nssm set syncthing AppExit Default Exit
%~dp0nssm set syncthing AppExit 0 Exit
%~dp0nssm set syncthing AppExit 3 Restart
%~dp0nssm set syncthing AppExit 4 Restart

pause