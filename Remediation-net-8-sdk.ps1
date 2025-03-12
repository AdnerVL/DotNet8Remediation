<#
.SYNOPSIS
    Installs .NET 8.0 SDK with Winget if missing.
#>

Write-Output "Starting .NET 8.0 SDK remediation..."

# Check if SDK is already installed
try {
    $sdks = dotnet --list-sdks
    Write-Output "SDKs found: $sdks"
    if ($sdks -match "8.0") {
        Write-Output "SDK 8.0 already installed"
        exit 0  # Success, no action needed
    }
} catch {
    Write-Output "Error checking SDK: $_"
}

# Install if not found
Write-Output "Installing .NET 8.0 SDK via Winget..."
try {
    winget install --id Microsoft.DotNet.SDK.8 --silent --accept-source-agreements --accept-package-agreements
    Write-Output "Winget exit code: $LASTEXITCODE"
    if ($LASTEXITCODE -eq 0) {
        Write-Output "SDK 8.0 installed successfully"
        exit 0  # Success
    } else {
        Write-Output "Winget failed with exit code: $LASTEXITCODE"
        exit 1  # Failure
    }
} catch {
    Write-Output "Error during install: $_"
    exit 1  # Failure
}