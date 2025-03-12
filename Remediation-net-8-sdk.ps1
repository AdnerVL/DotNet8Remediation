<#
.SYNOPSIS
    Installs .NET 8.0 SDK with Winget if missing.
#>

# Check if SDK is already installed to avoid unnecessary Winget run
$sdks = dotnet --list-sdks
if ($sdks -match "8.0") {
    Write-Output "SDK 8.0 already installed"
    exit 0
}

# Install if not found
try {
    winget install --id Microsoft.DotNet.SDK.8 --silent --accept-source-agreements --accept-package-agreements
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