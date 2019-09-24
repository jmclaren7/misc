$Days = 90
$Date = (Get-Date).Adddays(-($Days))

$Computers = (Get-ADComputer -Filter *).count
$ComputersInactive = (Get-ADComputer -Filter {LastLogonDate -lt $Date} -Properties LastLogonDate | Measure-Object).count
$ComputersWorkstations = (Get-ADComputer -Filter {OperatingSystem -notlike '*server*'} -Properties OperatingSystem).count
$ComputersServers = (Get-ADComputer -Filter {OperatingSystem -like '*server*'} -Properties OperatingSystem).count
$UsersEnabled = (Get-ADUser -Filter {Enabled -eq $true}).count
$UsersActive = (Get-ADUser -Properties lastlogondate -Filter { (Enabled -eq $true) -and (LastLogonTimeStamp -ge $Date) }).count
$UsersInactive = (Get-ADUser -Properties LastLogonDate -Filter { (Enabled -eq $true) -and (LastLogonTimeStamp -lt $Date) -or (Enabled -eq $true) -and (LastLogonDate -notlike '*')}).count
$UsersDisabled = (Get-ADUser -Filter {Enabled -eq $false}).count

Write-Host " "
Write-Host "==============================================================================="
Write-Host "Computers.........."$Computers
Write-Host "    Inactive (90).."$ComputersInactive
Write-Host "    Workstations..."$ComputersWorkstations
Write-Host "    Servers........"$ComputersServers 
Write-Host "Users Enabled......"$UsersEnabled 
Write-Host "    Active (90)...."$UsersActive  
Write-Host "    Inactive (90).."$UsersInactive
Write-Host "Users Disabled....."$UsersDisabled
Write-Host " "
Write-Host "======= Inactive Users (Last 90 Days) ======="
Get-ADUser -Properties LastLogonDate -Filter { (Enabled -eq $true) -and (LastLogonTimeStamp -lt $Date) -or (Enabled -eq $true) -and (LastLogonDate -notlike '*')} | Format-Table Name, UserPrincipalName, LastLogonDate
Write-Host "======= Inactive Computers (Last 90 Days) ======="
Get-ADComputer -Filter {LastLogonDate -lt $Date} -Properties OperatingSystem, LastLogonDate | Format-Table Name, OperatingSystem, LastLogonDate
Write-Host "==============================================================================="
Write-Host " "
Read-Host -Prompt "Press enter to continue"