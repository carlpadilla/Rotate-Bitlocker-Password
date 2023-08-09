param(
    [string]$MountPoint = "C:",
    [string]$LogSource = "recoveryPasswordLog"
)

# Logging function to handle both event log and console output
function Write-Log {
    param(
        [string]$Message,
        [System.Diagnostics.EventLogEntryType]$EntryType = [System.Diagnostics.EventLogEntryType]::Information,
        [int]$EventId = 0
    )
    Write-EventLog -LogName Application -Source $LogSource -EntryType $EntryType -EventId $EventId -Message $Message
    Write-Host $Message -ForegroundColor $(if ($EntryType -eq [System.Diagnostics.EventLogEntryType]::Error) { "Red" } else { "Green" })
}

# Register the event log source
New-EventLog -LogName Application -Source $LogSource -ErrorAction SilentlyContinue

# Get the key protectors
$KeyProtectors = (Get-BitLockerVolume -MountPoint $MountPoint).KeyProtector

foreach ($KeyProtector in $KeyProtectors) {
    if ($KeyProtector.KeyProtectorType -eq "RecoveryPassword") {
        # Capture the old recovery password
        $oldRecoveryPassword = $KeyProtector.RecoveryPassword

        try {
            # Remove the existing recovery password protector
            Remove-BitLockerKeyProtector -MountPoint $MountPoint -KeyProtectorId $KeyProtector.KeyProtectorId | Out-Null
            
            # Add a new recovery password protector
            $newKeyProtector = Add-BitLockerKeyProtector -MountPoint $MountPoint -RecoveryPasswordProtector -WarningAction SilentlyContinue
            $newRecoveryPassword = $newKeyProtector.RecoveryPassword

            # Log success along with the old and new recovery passwords
            Write-Log "BitLocker Recovery Password for $MountPoint has been changed. Old Recovery Password: $oldRecoveryPassword, New Recovery Password: $newRecoveryPassword" -EventId 1000
        }
        catch {
            # Log error details
            Write-Log "Failed to change Bitlocker Recovery Password for $MountPoint. Error: $($_.Exception.Message)" -EntryType Warning -EventId 1001
        }
        finally {
            # Additional cleanup or logging can be placed here if needed
        }
    }
}
