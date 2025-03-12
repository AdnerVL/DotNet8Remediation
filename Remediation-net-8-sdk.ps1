<#
.SYNOPSIS
    Installs .NET 8.0 SDK using Winget from C:\Tools\winget.
#>

Write-Output "Starting .NET 8.0 SDK remediation..."

# Check if SDK is installed
try {
    $sdks = dotnet --list-sdks
    if ($sdks -match "8.0") {
        Write-Output "SDK 8.0 already installed"
        exit 0
    }
} catch {
    Write-Output "Error checking SDK: $_"
}

# Define Winget path
$wingetPath = "C:\Tools\winget\winget.exe"
if (-not (Test-Path $wingetPath)) {
    Write-Error "Winget not found at $wingetPath. Ensure Winget is deployed."
    exit 1
}
Write-Output "Winget located at $wingetPath"

# Install .NET 8.0 SDK
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