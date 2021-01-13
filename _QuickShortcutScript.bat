@echo off

cls  
echo 1. Computer Managment 
echo 2. Group Policy Editor  
echo 3. Printer Managment
echo 4. TPM Management
echo 5. Firewall
echo 6. System Properties (Computer Name,Domain,Profiles,RDP)

echo.  
choice /C 1234567890 /N /M "Select an option: "
goto menu%errorlevel%


:menu1
compmgmt.msc
exit

:menu2
gpedit.msc
exit

:menu3
printmanagement.msc
exit

:menu4
tpm.msc
exit

:menu5
wf.msc
exit

:menu6
SystemPropertiesComputerName.exe
exit

:menu7

exit

:menu8

exit

:menu9

exit




:menu0

