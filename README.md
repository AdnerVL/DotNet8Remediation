# .NET 8.0 SDK Remediation via Intune with Winget

This project provides scripts to detect and remediate the absence of the .NET 8.0 SDK on Windows devices using Intune and Winget. It includes a Win32 app deployment for Winget to ensure it’s available in SYSTEM context.

## Prerequisites

- **Intune Access**: Administrative rights to create Win32 apps and remediation policies.

- **Winget Source**: Extracted `winget.exe` and its dependencies from an installed instance.

- **Test Machine**: Windows 10 1809+ or Windows 11, 64-bit.

- **Tools**:
  - `IntuneWinAppUtil.exe` (download from [Microsoft](https://github.com/microsoft/Microsoft-Win32-Content-Prep-Tool)).
  - `PsExec` (optional, for local testing) from [Sysinternals](https://docs.microsoft.com/en-us/sysinternals/downloads/psexec).

## Step 1: Extract Winget and Dependencies

1. **Install Winget on a Test Machine**:
   - Download `Microsoft.DesktopAppInstaller_8wekyb3d8bbwe.msixbundle` from [GitHub](https://github.com/microsoft/winget-cli/releases/latest).
   - Install manually (e.g., double-click or use `Add-AppxPackage` in user context).

2. **Copy Files**:
   - Navigate to `C:\Program Files\WindowsApps\Microsoft.DesktopAppInstaller_*_*` (e.g., `Microsoft.DesktopAppInstaller_2025.228.315.0_neutral_~_8wekyb3d8bbwe`).
   - Copy all contents (e.g., `winget.exe`, `msvcp140.dll`, `vcruntime140.dll`) to a local folder, e.g., `C:\Tools\WingetSource`.

## Step 2: Deploy Winget as a Win32 App

1. **Package Winget**:
   - Place all files from `C:\Tools\WingetSource` into `C:\Tools\Intune`.
   - Run from `C:\Tools\Microsoft-Win32-Content-Prep-Tool\Microsoft-Win32-Content-Prep-Tool-1.8.6`:

     ```cmd
     .\IntuneWinAppUtil.exe -c C:\Tools\Intune -s winget.exe -o C:\Tools\Intune\Out
     ```

   - Output: C:\Tools\Intune\Out\winget.intunewin.

2. **Create Win32 App in Intune**:
   - Intune: Apps > All apps > Add > Windows app (Win32).
   - Upload: winget.intunewin.
   - Program:
     - Install:

     ```powershell
      powershell.exe -ExecutionPolicy Bypass -Command "New-Item -Path 'C:\Tools\winget' -ItemType Directory -Force; Copy-Item -Path '.\*' -Destination 'C:\Tools\winget' -Recurse -Force"
      ```

     - Uninstall:

      ```powershell
       powershell.exe -ExecutionPolicy Bypass -Command "Remove-Item -Path 'C:\Tools\winget' -Recurse -Force"
      ```

   - Requirements: Windows 10 1809+, 64-bit.
   - Detection Rule:
     - Type: File
     - Path: C:\Tools\winget
     - File: winget.exe
     - Detection method: File or folder exists
   - Assignments: Assign as Required to your device group (SYSTEM context).
3. **Deploy**:
 Sync devices via Company Portal to install Winget to `C:\Tools\winget`.

## Step 3: Prepare Remediation Scripts

1. **Detection Script (Detection-net-8-sdk.ps1)**:

```powershell
try {
    $sdks = dotnet --list-sdks
    if ($sdks -match "8.0") {
        exit 0  # SDK found
    } else {
        exit 1  # SDK not found
    }
} catch {
    exit 1  # Error occurred
}
```

2. **Remediation Script (Remediation-net-8-sdk.ps1)**:

```powershell
Write-Output "Starting .NET 8.0 SDK remediation..."
try {
    $sdks = dotnet --list-sdks
    if ($sdks -match "8.0") {
        Write-Output "SDK 8.0 already installed"
        exit 0
    }
} catch {
    Write-Output "Error checking SDK: $_"
}
$wingetPath = "C:\Tools\winget\winget.exe"
if (-not (Test-Path $wingetPath)) {
    Write-Error "Winget not found at $wingetPath. Ensure Winget is deployed."
    exit 1
}
Write-Output "Winget located at $wingetPath"
Write-Output "Installing .NET 8.0 SDK with Winget..."
try {
    & $wingetPath install --id Microsoft.DotNet.SDK.8 --silent --accept-source-agreements --accept-package-agreements
    if ($LASTEXITCODE -eq 0) {
        Write-Output "SDK 8.0 installed"
        exit 0
    } else {
        Write-Error "Winget failed: $LASTEXITCODE"
        exit 1
    }
} catch {
    Write-Error "Install error: $_"
    exit 1
}
```

## Step 4: Deploy Remediation in Intune

1. **Create Remediation**:

   - Intune: Devices > Scripts and remediations > Remediation > Create.
   - Name: "Install .NET 8.0 SDK".
   - Detection Script: Upload `Detection-net-8-sdk.ps1`.
   - Remediation Script: Upload `Remediation-net-8-sdk.ps1`.
   - Settings:
      - Run as logged-on credentials: No (SYSTEM context).
      - Enforce signature check: No.
      - Run in 64-bit PowerShell: Yes.
   - Assignments: Assign to your device group.

2. **Sync Devices**: 

  Use Company Portal to sync and apply the remediation.

## Step 5: Test and Verify

1. Local Test:

   - Run `psexec -s powershell` on a test machine.
   - Execute: `C:\Tools\Git\DotNet8Remediation\Remediation-net-8-sdk.ps1`.
   - Verify: `dotnet --list-sdks lists` a version like `8.0.407`.

2. Intune Logs:

   - Check `C:\ProgramData\Microsoft\IntuneManagementExtension\Logs\IntuneManagementExtension.log` for execution details.

## Troubleshooting

   - Winget Fails (-1073741515): Ensure all dependencies (e.g., `msvcp140.dll`) are included in `C:\Tools\WingetSource`.

   - Detection Errors: Confirm script names are correct in Intune (`Detection-net-8-sdk.ps1, Remediation-net-8-sdk.ps1`).

   - No Install: Verify Winget Win32 app deployed successfully before remediation runs.

## Notes

   - Dependencies: `winget.exe` requires runtime DLLs from its original folder. Include all files from `Microsoft.DesktopAppInstaller_*_*`.

   - Version: This installs the latest .NET 8.0 SDK (e.g., 8.0.407 as of testing).