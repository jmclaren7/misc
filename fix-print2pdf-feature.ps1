#Requires -RunAsAdministrator
$ErrorActionPreference = 'Stop'
$feature = 'Printing-PrintToPDFServices-Features'

function Get-FeatureState {
    (Get-WindowsOptionalFeature -Online -FeatureName $feature).State
}

Write-Host "Checking feature: $feature"
$state = Get-FeatureState

if ($state -eq 'Enabled') {
    Write-Host "Feature is installed. Uninstalling..."
    Disable-WindowsOptionalFeature -Online -FeatureName $feature -NoRestart | Out-Null

    # Wait briefly until fully disabled
    for ($i = 0; $i -lt 30; $i++) {
        Start-Sleep -Seconds 1
        $state = Get-FeatureState
        if ($state -eq 'Disabled' -or $state -eq 'DisabledWithPayloadRemoved') { break }
    }
}

Write-Host "Installing feature..."
Enable-WindowsOptionalFeature -Online -FeatureName $feature -NoRestart | Out-Null

$final = Get-FeatureState
if ($final -ne 'Enabled') {
    throw "Failed to enable $feature. Current state: $final"
}

Write-Host "Microsoft Print to PDF feature is enabled. A restart may be required."