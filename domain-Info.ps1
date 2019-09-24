$Days = 90
$Time = (Get-Date).Adddays(-($Days))

$Computers = (Get-ADComputer -Filter *).count
$ComputersInactive = (Search-ADAccount -AccountInactive -TimeSpan $Days -ComputersOnly | Where-Object { $_.Enabled -eq $true } | Format-Table Name, SamAccountName, lastlogondate).count
$Workstations = (Get-ADComputer -LDAPFilter "(&(objectClass=Computer)(!operatingSystem=*server*))" -Searchbase (Get-ADDomain).distinguishedName).count
$Servers = (Get-ADComputer -LDAPFilter "(&(objectClass=Computer)(operatingSystem=*server*))" -Searchbase (Get-ADDomain).distinguishedName).count
$EnabledUsers = (Get-ADUser -Filter {Enabled -eq $true}).count
$ActiveLast90 = (Get-ADUser -Properties lastlogondate -Filter {Enabled -eq $true} | Where-Object { ($_.lastlogondate -ge $Time ) } ).count
$InactiveLast90 = (Get-ADUser -Properties lastlogondate -Filter {Enabled -eq $true} | Where-Object { ($_.lastlogondate -lt $Time ) } ).count
$DisabledUsers = (Get-ADUser -Filter {Enabled -eq $false}).count

Write-Output " "
Write-Output "==========================================================================================="
Write-Host "Computers.........."$Computers
Write-Host "    Inactive (90).."$ComputersInactive
Write-Host "    Workstions....."$Workstations
Write-Host "    Servers........"$Servers 
Write-Host "Users Enabled......"$EnabledUsers 
Write-Host "    Active (90)...."$ActiveLast90  
Write-Host "    Inactive (90).."$InactiveLast90
Write-Host "Disabled Users....."$DisabledUsers
Write-Output " "
Write-Output "======= Inactive Users (Last 90 Days) ======="
Get-ADUser -Properties lastlogondate -Filter {Enabled -eq $true} | Where-Object { ($_.lastlogondate -lt $Time ) } | Format-Table Name, UserPrincipalName, LastLogonDate
Write-Output "======= Inactive Computers (Last 90 Days) ======="
Get-ADComputer -Filter {LastLogonTimeStamp -lt $Time} -ResultPageSize 2000 -resultSetSize $null -Properties Name, OperatingSystem, LastLogonDate | Format-Table Name, LastLogonDate, OperatingSystem
Write-Output "==========================================================================================="
Write-Output " "
Read-Host -Prompt "Press enter to continue"