@echo off
echo Administrative permissions required. Detecting permissions...
net session >nul 2>&1
if %errorLevel% == 0 (
	echo Success: Administrative permissions confirmed.
	set /p cname="Enter Computer Name (blank for local pc): "

	bitsadmin.exe /transfer RDPWrapDownload /dynamic https://jcs-static.s3.amazonaws.com/rdpwrap/rdpwrap.ini "%~dp0RDPWrap-v1.6.2.zip"
	cd /d %~dp0
	Call :UnZipFile "C:\Temp\" "c:\FolderName\batch.zip"
	REM psexec \\%cname% cmd /c C:\IT\RDPWrap\reinstall.bat
	pause
	exit

) else (
        echo Failure: Current permissions inadequate.
	pause
	exit
)



:UnZipFile <ExtractTo> <newzipfile>
set vbs="%temp%\_.vbs"
if exist %vbs% del /f /q %vbs%
>%vbs%  echo Set fso = CreateObject("Scripting.FileSystemObject")
>>%vbs% echo If NOT fso.FolderExists(%1) Then
>>%vbs% echo fso.CreateFolder(%1)
>>%vbs% echo End If
>>%vbs% echo set objShell = CreateObject("Shell.Application")
>>%vbs% echo set FilesInZip=objShell.NameSpace(%2).items
>>%vbs% echo objShell.NameSpace(%1).CopyHere(FilesInZip)
>>%vbs% echo Set fso = Nothing
>>%vbs% echo Set objShell = Nothing
cscript //nologo %vbs%
if exist %vbs% del /f /q %vbs%