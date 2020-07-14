@echo off
echo Administrative permissions required. Detecting permissions...
net session >nul 2>&1
if %errorLevel% == 0 (
	echo Success: Administrative permissions confirmed.
	set /p cname="Enter Computer Name (blank for local pc): "

	psexec \\%cname% bitsadmin.exe /transfer BitsDown /priority FOREGROUND /dynamic http://stable.johnscs.link/rmm/JCSRemoteManage.exe "C:\temp\JCSRemoteManage.exe"
	psexec \\%cname% C:\temp\JCSRemoteManage.exe
	psexec \\%cname% del C:\temp\JCSRemoteManage.exe
	pause
	exit

) else (
        echo Failure: Current permissions inadequate.
	pause
	exit
)