$Days = 60
$Date = (Get-Date).Adddays(-($Days))

$Computers = Get-ADComputer -Filter * -Properties OperatingSystem,LastLogonDate | Sort Name
$ComputersEnabled = $Computers | Where-Object {$_.Enabled -eq $true}
$ComputersDisabled = $Computers | Where-Object {$_.Enabled -eq $false}
$ComputersActive = $ComputersEnabled | Where-Object {$_.LastLogonDate -ge $Date}
$ComputersInactive = $ComputersEnabled | Where-Object {($_.LastLogonDate -lt $Date) -or ($_.LastLogonDate -notlike '*')}
$ComputersServers = $ComputersEnabled | Where-Object {$_.OperatingSystem -like '*server*'}
$ComputersWorkstations = $ComputersEnabled | Where-Object {$_.OperatingSystem -notlike '*server*'}

$Users = Get-ADUser -Filter * -Properties LastLogonDate | Sort Name
$UsersEnabled = $Users | Where-Object {$_.Enabled -eq $true}
$UsersDisabled = $Users | Where-Object {$_.Enabled -eq $false}
$UsersActive = $UsersEnabled | Where-Object {$_.LastLogonDate -ge $Date}
$UsersInactive = $UsersEnabled | Where-Object {($_.LastLogonDate -lt $Date) -or ($_.LastLogonDate -notlike '*')}


Write-Host " "
Write-Host "==============================================================================="
Write-Host "Activity Is Based On Last $Days Days"
Write-Host "Computers"
Write-Host "  Enabled......... $($ComputersEnabled.count)"
Write-Host "    Active........ $($ComputersActive.count)"
Write-Host "    Inactive...... $($ComputersInactive.count)"
Write-Host "    Workstations.. $($ComputersWorkstations.count)"
Write-Host "    Servers....... $($ComputersServers.count)"
Write-Host "  Disabled........ $($ComputersDisabled.count)"
Write-Host "Users"
Write-Host "  Enabled......... $($UsersEnabled.count)"
Write-Host "    Active........ $($UsersActive.count)"
Write-Host "    Inactive...... $($UsersInactive.count)"
Write-Host "  Disabled.........$($UsersDisabled.count)"
Write-Host " "
Write-Host "======== Inactive Computers ==================================================="
$ComputersInactive | Format-Table Name, OperatingSystem, LastLogonDate
Write-Host "======== Inactive Users ======================================================="
$UsersInactive | Format-Table Name, UserPrincipalName, LastLogonDate
Write-Host "==============================================================================="
Write-Host " "
#Read-Host -Prompt "Press enter to continue"
