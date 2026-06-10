<#
Read-only recovery image check for RM11 Pro / NX809J.
This script inspects size/hash and, when WSL tools are available, boot header
and AVB metadata. It does not flash or modify the device.
#>

[CmdletBinding()]
param(
    [string]$ImagePath = "C:\temp\orangefox-nx809j-stockfstab-mininit-20260609.img",
    [int64]$ExpectedBytes = 104857600,
    [string]$ExpectedSha256 = "9a3d822bbe8201321934a3e746b6c2efc6ef4c037939a858e94487fd866e2d4d",
    [string]$UnpackBootimgPy = "/home/richtofen/android/repositories/MainAssets/fox_14.1/system/tools/mkbootimg/unpack_bootimg.py",
    [string]$AvbtoolPy = "/home/richtofen/android/repositories/MainAssets/fox_14.1/external/avb/avbtool.py"
)

Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

function Convert-ToWslPath {
    param([string]$Path)

    if ($Path.StartsWith("/")) {
        return $Path
    }

    if ($Path -match "^([A-Za-z]):\\(.*)$") {
        $drive = $Matches[1].ToLowerInvariant()
        $rest = $Matches[2] -replace "\\", "/"
        return "/mnt/$drive/$rest"
    }

    $converted = & wsl.exe -- wslpath -a $Path
    if ($LASTEXITCODE -ne 0) {
        throw "wslpath failed for: $Path"
    }
    return $converted.Trim()
}

function Test-WslFile {
    param([string]$Path)

    & wsl.exe -- test -f $Path | Out-Null
    return ($LASTEXITCODE -eq 0)
}

if (-not (Test-Path -LiteralPath $ImagePath)) {
    throw "Image not found: $ImagePath"
}

$item = Get-Item -LiteralPath $ImagePath
$hash = (Get-FileHash -LiteralPath $ImagePath -Algorithm SHA256).Hash.ToLowerInvariant()
$expected = $ExpectedSha256.ToLowerInvariant()
$wslImage = Convert-ToWslPath -Path $item.FullName

$report = [ordered]@{
    image = $item.FullName
    wsl_image = $wslImage
    bytes = $item.Length
    expected_bytes = $ExpectedBytes
    size_match = ($item.Length -eq $ExpectedBytes)
    sha256 = $hash
    expected_sha256 = $expected
    hash_match = ($hash -eq $expected)
}

$tmpOut = "/tmp/rm11-verify-recovery-image"

$unpackExists = Test-WslFile -Path $UnpackBootimgPy
if ($unpackExists) {
    & wsl.exe -- rm -rf $tmpOut | Out-Null
    & wsl.exe -- mkdir -p $tmpOut | Out-Null
    $unpackOutput = & wsl.exe -- python3 $UnpackBootimgPy --boot_img $wslImage --out $tmpOut 2>&1
    $report.unpack_bootimg = @($unpackOutput)
}
else {
    $report.unpack_bootimg = "Skipped; not found: $UnpackBootimgPy"
}

$avbExists = Test-WslFile -Path $AvbtoolPy
if ($avbExists) {
    $avbOutput = & wsl.exe -- python3 $AvbtoolPy info_image --image $wslImage 2>&1
    $report.avbtool = @($avbOutput)
}
else {
    $report.avbtool = "Skipped; not found: $AvbtoolPy"
}

$report | ConvertTo-Json -Depth 5

if ($item.Length -ne $ExpectedBytes) {
    throw "Image size mismatch. Expected $ExpectedBytes bytes."
}

if ($hash -ne $expected) {
    throw "SHA256 mismatch. This is not the documented stockfstab/mininit test candidate."
}
