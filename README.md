# .NET 8.0 SDK Intune Remediation

## Overview
This project contains PowerShell scripts for Intune to detect and install the .NET 8.0 SDK using Winget.

## Files
- **Detection-net-8-sdk.ps1**: Checks if .NET 8.0 SDK is installed.
- **Remediation-net-8-sdk.ps1**: Installs .NET 8.0 SDK if missing.

## Detection Script
- **Purpose**: Verifies .NET 8.0 SDK presence using `dotnet --list-sdks`.
- **Output**: 
  - "SDK 8.0 found" (exit 0) if installed.
  - "SDK 8.0 not found" (exit 1) if missing.

## Remediation Script
- **Purpose**: Installs .NET 8.0 SDK silently via Winget if not detected.
- **Behavior**: 
  - Checks for SDK first; exits 0 if already installed.
  - Runs `winget install --id Microsoft.DotNet.SDK.8 --silent` if needed.
  - Exits 0 on success, 1 on failure.

## Prerequisites
- Intune enrollment with Company Portal sync.
- Winget installed (pre-installed in Windows 11 or via App Installer).

## Deployment
1. In Intune: **Devices > Scripts and remediations > Remediation > Create**.
2. Title: "Ensure .NET 8.0 SDK Installation".
3. Description: "Checks for .NET 8.0 SDK and installs via Winget if missing."
4. Upload both scripts.
5. Assign to a device group (e.g., test machines).
6. Run as **System** context (No logged-on credentials).

## Logs
- Check `C:\ProgramData\Microsoft\IntuneManagementExtension\Logs\IntuneManagementExtension.log` for execution details.

## Testing
- Run locally: `. .\Detection-net-8-sdk.ps1` and `. .\Remediation-net-8-sdk.ps1`.
- Use a device group with a single test machine for Intune validation.

## Notes
- Silent install requires no user interaction.
- Handles cases where SDK is already installed without triggering errors.