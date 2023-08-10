$MountPoint = "C:"

# Get the BitLocker volume details
$BitLockerVolume = Get-BitLockerVolume -MountPoint $MountPoint

# Check if BitLocker is enabled
if ($BitLockerVolume.ProtectionStatus -eq 'On') {

    $KeyProtectors = $BitLockerVolume.KeyProtector

    foreach ($KeyProtector in $KeyProtectors) {
        if ($KeyProtector.KeyProtectorType -eq "RecoveryPassword") {
            try {
                # Suspend BitLocker protection to safely manipulate key protectors
                Suspend-BitLocker -MountPoint $MountPoint -Confirm:$false
                
                # Remove the RecoveryPassword protector
                Remove-BitLockerKeyProtector -MountPoint $MountPoint -KeyProtectorId $KeyProtector.KeyProtectorId -ErrorAction SilentlyContinue
                
                # Add a new RecoveryPassword protector
                Add-BitLockerKeyProtector -MountPoint $MountPoint -RecoveryPasswordProtector -WarningAction SilentlyContinue
                
                # Resume BitLocker protection after key protector operations
                Resume-BitLocker -MountPoint $MountPoint

            }
            catch {
                # In case of an error, try resuming BitLocker protection if it was suspended
                if ((Get-BitLockerVolume -MountPoint $MountPoint).ProtectionStatus -eq 'Off') {
                    Resume-BitLocker -MountPoint $MountPoint
                }
                
            }
        }
    }
}
 else {
    # log or notify that BitLocker isn't enabled on the target volume.
    Write-Output "BitLocker is not enabled on $MountPoint."
}
