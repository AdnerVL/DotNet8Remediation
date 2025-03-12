<#
.SYNOPSIS
    Detects if .NET 8.0 SDK is installed.
#>

Write-Output "Checking for .NET 8.0 SDK..."
try {
    $sdks = dotnet --list-sdks
    Write-Output "SDKs found: $sdks"
    if ($sdks -match "8.0") {
        Write-Output "SDK 8.0 found"
        exit 0  # Success
    } else {
        Write-Output "SDK 8.0 not found"
        exit 1  # Failure, triggers remediation
    }
} catch {
    Write-Output "Error checking SDK: $_"
    exit 1  # Failure
}