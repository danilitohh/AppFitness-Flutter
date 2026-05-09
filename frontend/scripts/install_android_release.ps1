param(
    [string]$ApkPath = "",
    [string]$DeviceId = ""
)

Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

function Resolve-ToolPath {
    param(
        [Parameter(Mandatory = $true)]
        [string]$CommandName,
        [Parameter(Mandatory = $true)]
        [string[]]$Fallbacks
    )

    $command = Get-Command $CommandName -ErrorAction SilentlyContinue
    if ($command) {
        return $command.Source
    }

    foreach ($candidate in $Fallbacks) {
        if ([string]::IsNullOrWhiteSpace($candidate)) {
            continue
        }

        if (Test-Path $candidate) {
            return $candidate
        }
    }

    throw "No se encontro '$CommandName'."
}

$projectRoot = Split-Path -Parent $PSScriptRoot
$adbPath = Resolve-ToolPath -CommandName "adb" -Fallbacks @(
    (Join-Path $env:LOCALAPPDATA "Android\Sdk\platform-tools\adb.exe"),
    (Join-Path $env:LOCALAPPDATA "Android\sdk\platform-tools\adb.exe")
)

if ([string]::IsNullOrWhiteSpace($ApkPath)) {
    $distApk = Join-Path $projectRoot "dist\appfitness-android-release.apk"
    $buildApk = Join-Path $projectRoot "build\app\outputs\flutter-apk\app-release.apk"

    if (Test-Path $distApk) {
        $ApkPath = $distApk
    }
    elseif (Test-Path $buildApk) {
        $ApkPath = $buildApk
    }
    else {
        throw "No encontre un APK para instalar. Ejecuta primero scripts\build_android_installer.ps1 y completa la configuracion del instalador si hace falta."
    }
}

if (-not (Test-Path $ApkPath)) {
    throw "El APK indicado no existe: $ApkPath"
}

$deviceLines = & $adbPath devices | Select-Object -Skip 1 | Where-Object { $_ -match "\sdevice$" }

if ([string]::IsNullOrWhiteSpace($DeviceId)) {
    if ($deviceLines.Count -eq 0) {
        throw "No hay celulares conectados por adb. Activa Depuracion USB y acepta la huella en el telefono."
    }

    if ($deviceLines.Count -gt 1) {
        throw "Hay varios dispositivos conectados. Ejecuta de nuevo con -DeviceId <id>."
    }

    $DeviceId = ($deviceLines[0] -split "\s+")[0]
}

Write-Host "Instalando APK en $DeviceId..." -ForegroundColor Cyan
& $adbPath -s $DeviceId install -r $ApkPath

Write-Host ""
Write-Host "Instalacion completada en el celular." -ForegroundColor Green

$buildInfoPath = Join-Path $projectRoot "dist\appfitness-android-release.build-info.txt"
if (Test-Path $buildInfoPath) {
    Write-Host "Resumen del build:" -ForegroundColor Green
    Write-Host $buildInfoPath
}
