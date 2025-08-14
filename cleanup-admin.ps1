# Requires PowerShell 5.1 or later for Get-Local* cmdlets
# This script must be run with elevated administrator privileges.

# --- Section 1: Remove non-standard members from the local 'Administrators' group ---

Write-Host "--- Starting Administrators Group Cleanup ---" -ForegroundColor Cyan

try {
    # Get the local Administrators group
    $adminGroup = Get-LocalGroup -Name "Administrators" -ErrorAction Stop

    # Define patterns for members that should be kept in the Administrators group
    # These patterns will be used for partial string matching (e.g., COMPUTERNAME\Administrator, DOMAIN\Domain Admins)
    $allowedPatterns = @(
        "*\Administrator",
        "*\Domain Admins"
    )

    Write-Host "Checking members of the 'Administrators' group..." -ForegroundColor Green

    # Get current members of the Administrators group
    $currentMembers = Get-LocalGroupMember -Group $adminGroup.Name -ErrorAction SilentlyContinue

    if ($null -ne $currentMembers) {
        foreach ($member in $currentMembers) {
            $isAllowed = $false
            # Check if the member's name matches any of the allowed patterns
            foreach ($pattern in $allowedPatterns) {
                if ($member.Name -like $pattern) {
                    $isAllowed = $true
                    break # Exit inner loop once a match is found
                }
            }

            if (-not $isAllowed) {
                Write-Host "Attempting to remove $($member.Name) from 'Administrators' group..." -ForegroundColor Yellow
                try {
                    Remove-LocalGroupMember -Group $adminGroup.Name -Member $member.Name -ErrorAction Stop
                    Write-Host "Successfully removed $($member.Name) from 'Administrators' group." -ForegroundColor Green
                }
                catch {
                    Write-Warning "Failed to remove $($member.Name) from 'Administrators' group. Error: $($_.Exception.Message)"
                }
            } else {
                Write-Host "$($member.Name) is an allowed member and will be kept in 'Administrators' group." -ForegroundColor DarkGreen
            }
        }
    } else {
        Write-Host "No members found in the 'Administrators' group." -ForegroundColor Yellow
    }
}
catch {
    Write-Error "An error occurred while processing the 'Administrators' group: $($_.Exception.Message)"
}

Write-Host "--- Administrators Group Cleanup Complete ---`n" -ForegroundColor Cyan


# --- Section 2: Delete specific local users if they exist ---

Write-Host "--- Starting Specific User Deletion ---" -ForegroundColor Cyan

$usersToDelete = @("temp", "rtadmin", "tempadmin")

foreach ($user in $usersToDelete) {
    Write-Host "Checking for user '$user'..." -ForegroundColor Green
    try {
        # Check if the user exists
        $localUser = Get-LocalUser -Name $user -ErrorAction SilentlyContinue

        if ($null -ne $localUser) {
            Write-Host "User '$user' found. Attempting to delete..." -ForegroundColor Yellow
            try {
                Remove-LocalUser -Name $user -ErrorAction Stop
                Write-Host "Successfully deleted user '$user'." -ForegroundColor Green
            }
            catch {
                Write-Warning "Failed to delete user '$user'. Error: $($_.Exception.Message)"
            }
        } else {
            Write-Host "User '$user' does not exist. Skipping deletion." -ForegroundColor DarkGreen
        }
    }
    catch {
        Write-Error "An error occurred while checking or deleting user '$user': $($_.Exception.Message)"
    }
}

Write-Host "--- Specific User Deletion Complete ---`n" -ForegroundColor Cyan


# --- Section 3: Disable the "Administrator" local user if it's not already disabled ---

Write-Host "--- Starting Administrator Account Status Check ---" -ForegroundColor Cyan

try {
    # Get the local Administrator user
    $adminAccount = Get-LocalUser -Name "Administrator" -ErrorAction Stop

    if ($adminAccount.Enabled) {
        Write-Host "The 'Administrator' account is currently enabled. Attempting to disable..." -ForegroundColor Yellow
        try {
            Disable-LocalUser -Name "Administrator" -ErrorAction Stop
            Write-Host "Successfully disabled the 'Administrator' account." -ForegroundColor Green
        }
        catch {
            Write-Warning "Failed to disable the 'Administrator' account. Error: $($_.Exception.Message)"
        }
    } else {
        Write-Host "The 'Administrator' account is already disabled. No action needed." -ForegroundColor DarkGreen
    }
}
catch {
    Write-Error "An error occurred while processing the 'Administrator' account: $($_.Exception.Message)"
}

Write-Host "--- Administrator Account Status Check Complete ---" -ForegroundColor Cyan

Write-Host "`nScript execution finished." -ForegroundColor Green
