$apps = @(
    "Microsoft.BingFinance"
    "Microsoft.BingNews"
    "Microsoft.BingSports"
    "Microsoft.BingTranslator"
    "Microsoft.BingWeather"
    "Microsoft.BingFoodAndDrink"
    "Microsoft.BingHealthAndFitness"
    "Microsoft.BingTravel"
    
    "microsoft.windowscommunicationsapps" #Mail
    "Microsoft.WindowsMaps"
    "Microsoft.WindowsPhone"
    "Microsoft.WindowsFeedbackHub"

    "Microsoft.549981C3F5F10" #Cortana
    "Microsoft.3DBuilder"
    "Microsoft.People"
    "Microsoft.YourPhone"
    "Microsoft.CommsPhone"
    "Microsoft.MixedReality.Portal"
    "Microsoft.ZuneMusic" #Groove Music
    "Microsoft.ZuneVideo" #Movies & TV
    "Microsoft.MicrosoftSolitaireCollection"
    "Microsoft.MicrosoftOfficeHub"

    "Microsoft.Getstarted"
    "Microsoft.GetHelp"

    #"Microsoft.WindowsStore"

    "Microsoft.Xbox.TCUI"
    "Microsoft.XboxApp"
    "Microsoft.XboxGameOverlay"
    "Microsoft.XboxGamingOverlay"
    "Microsoft.XboxSpeechToTextOverlay"
)

foreach ($app in $apps) {
    Write-Output "Remove-AppxPackage $app"
    Get-AppxPackage -Name $app -AllUsers | Remove-AppxPackage -AllUsers

    Write-Output "Remove-AppxProvisionedPackage $app"
    Get-AppXProvisionedPackage -Online | Where-Object DisplayName -Match $app | Remove-AppxProvisionedPackage -Online -AllUsers
}
