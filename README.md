# BitLocker Recovery Password Management Script

## Overview

This PowerShell script is designed to manage BitLocker Recovery Passwords on Windows systems. It targets a specific drive (default is the C: drive), iterates through the BitLocker key protectors, and for those of type "RecoveryPassword", it removes the existing recovery password protector and adds a new one.

## Requirements

- Windows PowerShell 5.0 or later
- BitLocker enabled on the target drive
- Necessary permissions to manage BitLocker on the system

## Parameters

- `MountPoint`: The drive letter for the target drive (default is "C:").
- `LogSource`: The source name for logging to the Windows Application event log.

## Functionality

1. **Register Event Log Source**: Registers a custom source for logging events to the Application log.
2. **Retrieve Key Protectors**: Retrieves all BitLocker key protectors for the given mount point.
3. **Iterate Key Protectors**: Iterates through each key protector, focusing on those of type "RecoveryPassword".
4. **Remove and Add Recovery Password Protector**: For each recovery password protector, removes the old protector and adds a new one.
5. **Capture and Log Recovery Passwords**: Logs the old and new recovery passwords to the Application event log (Please note the security considerations mentioned below).
6. **Error Handling**: Detailed error handling, including logging to both the event log and the console.


