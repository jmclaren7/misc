<#
 ------------------------------------------------
 PowerShell script to query BitLocker status on
 a list of computers from Active Directory
#>

cls

# -----------------------
# Define global variables
# -----------------------

$ScanCount = 0
$UnprotectedCount = 0
$ProtectedCount = 0
$UnknownCount = 0
$Date = Get-Date -Format yyyyMMdd
$StartDate = Get-Date -Format HH:mm:ss
$ReportFile = Join-Path (Split-Path $MyInvocation.MyCommand.Path) -ChildPath "BitLockerReport.csv"
$OutputArray = @()
$SearchBase = "CN=Computers,DC=caronbletzer,DC=local"


# ----------------------------------------
# Build array from list of computers in AD
# ----------------------------------------

Write-Host -NoNewline "- Gathering a list of Computers from Active Directory..."
Try
{
   $Computers = Get-ADComputer -SearchBase $SearchBase -Filter * -Properties Name,Description | Sort-Object 
   Write-Host -ForegroundColor Green "Success"
}
Catch
{
   Write-Host -ForegroundColor Red "Failed ($_)"
}


# -------------------------------------------------
# Use the Manage-BDE command to query each computer
# -------------------------------------------------

Write-Host "- Querying BitLocker status..."
ForEach ($Computer in $Computers)
{
   $Name = $Computer.Name
   $Description = $Computer.Description
   Write-Host -nonewline "  - $Name ($Description)..."

   $BDE = Manage-BDE -ComputerName $Computer.Name -Status C:

   If ($BDE -Like "*An error occurred while connecting*") {
    Write-Host -ForegroundColor Yellow "Unable to connect"; $Status = "Unable to connect"
    $UnknownCount++
   }ElseIf ($BDE -Like "*Protection On*" -Or $BDE -Like "*Percentage Encrypted: 100.0%*") {
    Write-Host -ForegroundColor Green "Protected"; $Status = "Protected"
    $ProtectedCount++
   }ElseIf ($BDE -Like "*Protection Off*") {
    Write-Host -ForegroundColor Red "Not potected!"; $Status = "Not protected"
    $UnprotectedCount++
   }ElseIf ($BDE -Like "*Invalid namespace*") {
    Write-Host -ForegroundColor Yellow "Invalid namespace"; $Status = "Invalid namespace"
    $UnknownCount++
   }Else{
    Write-Host -ForegroundColor Red $BDE; $Status = "Unknown";
    $UnknownCount++
   }

   $ScanCount = $ScanCount +1
   $OutputArray += New-Object PsObject -Property @{
   'Computer name' = $Computer.Name
   'Description' = $Computer.Description
   'BitLocker status' = $Status
   }
}


# -----------------
# Generate a report
# -----------------

Write-Host -NoNewline "- Saving report..."
Try
{
   $OutputArray | Export-CSV -NoTypeInformation $ReportFile
   Write-Host -ForegroundColor Green "Success"
}
Catch
{
   Write-Host -ForegroundColor Red "Failed ($_)"
}


# -----------------------------------------
# Display completion message and statistics
# -----------------------------------------

$EndDate = Get-Date -Format HH:mm:ss
$Duration = New-TimeSpan $StartDate $EndDate

Write-Host ""
Write-Host "-------------------------------------------------------------"
Write-Host "Script complete.  Start time: $StartDate, End time: $EndDate"
Write-Host "Scanned $ScanCount computers in AD. "
Write-Host "$ProtectedCount are protected"
Write-Host "$UnprotectedCount are unprotected!"
Write-Host "$UnknownCount have an unknown status!"
Write-Host "-------------------------------------------------------------"
Write-Host ""