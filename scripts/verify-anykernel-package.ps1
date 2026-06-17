<#
Read-only AnyKernel3 package guardrail check for RM11 Pro / NX809J.
This script does not flash, extract to the device, or modify the package.
#>

[CmdletBinding()]
param(
    [string]$PackagePath = ".\AK3-RM11-OPWILD.zip",
    [string]$ExpectedSha256 = "7cac8a90fd065fd2f31f8e1938ece8f5bea061cbd8213a03e44b86ba50ea1b4a"
)

Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

$requiredEntries = @(
    "anykernel.sh",
    "Image",
    "tools/ak3-core.sh",
    "tools/magiskboot"
)

$requiredMarkers = @(
    "do.devicecheck=1",
    "do.check_boot_version=1",
    "device.name1=NX809J",
    "device.name2=NX809J-UN",
    "block=boot",
    "patch_vbmeta_flag=0",
    "Expected 6.12.23",
    "Device mismatch. Expected RM11 Pro / NX809J"
)

if (-not (Test-Path -LiteralPath $PackagePath)) {
    throw "Package not found: $PackagePath"
}

$item = Get-Item -LiteralPath $PackagePath
if ($item.Extension -ne ".zip") {
    throw "Expected a .zip AnyKernel package, got: $($item.Extension)"
}

$hash = (Get-FileHash -LiteralPath $PackagePath -Algorithm SHA256).Hash.ToLowerInvariant()
$expected = $ExpectedSha256.ToLowerInvariant()

Add-Type -AssemblyName System.IO.Compression.FileSystem
$zip = [System.IO.Compression.ZipFile]::OpenRead($item.FullName)
try {
    $entries = @($zip.Entries | ForEach-Object { $_.FullName })
    $missingEntries = @($requiredEntries | Where-Object { $_ -notin $entries })
    if ($missingEntries.Count -gt 0) {
        throw "Missing required ZIP entries: $($missingEntries -join ', ')"
    }

    $scriptEntry = $zip.GetEntry("anykernel.sh")
    $reader = New-Object System.IO.StreamReader($scriptEntry.Open())
    try {
        $scriptText = $reader.ReadToEnd()
    }
    finally {
        $reader.Dispose()
    }

    $missingMarkers = @($requiredMarkers | Where-Object { $scriptText -notlike "*$_*" })
    if ($missingMarkers.Count -gt 0) {
        throw "anykernel.sh is missing RM11 guardrails: $($missingMarkers -join ', ')"
    }

    $report = [ordered]@{
        package = $item.FullName
        bytes = $item.Length
        sha256 = $hash
        expected_sha256 = $expected
        hash_match = ($hash -eq $expected)
        required_entries = $requiredEntries
        guardrails = @(
            "RM11/NX809J device check enabled",
            "kernel minor 6.12.23 check present",
            "boot partition target only",
            "vbmeta patching disabled"
        )
    }

    $report | ConvertTo-Json -Depth 4

    if ($hash -ne $expected) {
        throw "SHA256 mismatch. Refusing to treat this as the documented test package."
    }
}
finally {
    $zip.Dispose()
}
