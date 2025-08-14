Write-Host "Scanning devices..."

$Scan = & pnputil.exe /scan-devices | Out-String

$Devices = Get-pnpdevice -presentonly -status error -ErrorAction SilentlyContinue
$DeviceCount = $Devices | Measure-Object | Select-Object -ExpandProperty Count 

If ($DeviceCount -ne 0) {
	Write-Host "Devices with error status found: $DeviceCount"

	$RegistryPath = "Registry::HKEY_LOCAL_MACHINE\SOFTWARE\Policies\Microsoft\Windows\DeviceInstall\Restrictions"
	$PathExists = $false
	if (Test-Path -Path "$RegistryPath" -PathType Container) {
		$PathExists = $true
		$DenyUnspecified = Get-ItemPropertyValue -Path $RegistryPath -Name "DenyUnspecified"
		Set-ItemProperty -Path $RegistryPath -Name "DenyUnspecified" -Type DWord -Value 0
		Write-Host "Disabled DenyUnspecified policy"
	} Else {
		Write-Host "DenyUnspecified policy doesn't exist"
	}
	Write-Host "Disabling devices..."
	$Devices | disable-pnpdevice -Confirm:$false
	Sleep 3

	Write-Host "Enabling devices..."
	$Devices | enable-pnpdevice -Confirm:$false
	Sleep 7

	If ($PathExists) { 
		Set-ItemProperty -Path $RegistryPath -Name "DenyUnspecified" -Type DWord -Value $DenyUnspecified
		Write-Host "Restored DenyUnspecified policy"
	}
} Else{
	Write-Host "No devices with error status" -ForegroundColor Yellow
}
