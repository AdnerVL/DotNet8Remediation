$sdks = dotnet --list-sdks
if ($sdks -match "8.0") {
    Write-Output "SDK 8.0 found"
    exit 0
} else {
    Write-Output "SDK 8.0 not found"
    exit 1
}