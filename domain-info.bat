@ECHO OFF
PowerShell.exe -Command ". { iwr -useb https://raw.githubusercontent.com/jmclaren7/misc/master/domain-Info.ps1 } | iex; domain-Info"