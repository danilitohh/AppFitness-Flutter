param(
    [string]$AvdName = "appfitness_api35_clean",
    [string]$ApiBaseUrl
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

function Get-RunningEmulatorId {
    param(
        [Parameter(Mandatory = $true)]
        [string]$AdbPath
    )

    $devices = & $AdbPath devices
    foreach ($line in $devices) {
        if ($line -match "^(emulator-\d+)\s+device$") {
            return $matches[1]
        }
    }

    return $null
}

function Wait-ForBootComplete {
    param(
        [Parameter(Mandatory = $true)]
        [string]$AdbPath,
        [Parameter(Mandatory = $true)]
        [string]$DeviceId,
        [int]$TimeoutSeconds = 240
    )

    $deadline = (Get-Date).AddSeconds($TimeoutSeconds)

    do {
        $bootCompleted = (& $AdbPath -s $DeviceId shell getprop sys.boot_completed 2>$null).Trim()
        if ($bootCompleted -eq "1") {
            return
        }

        Start-Sleep -Seconds 5
    } while ((Get-Date) -lt $deadline)

    throw "El emulador '$DeviceId' no termino de arrancar dentro del tiempo esperado."
}

$flutterPath = Resolve-ToolPath -CommandName "flutter" -Fallbacks @(
    "C:\Users\danil\Downloads\flutter\bin\flutter.bat",
    "C:\src\flutter\bin\flutter.bat",
    "C:\flutter\bin\flutter.bat",
    (Join-Path $env:USERPROFILE "flutter\bin\flutter.bat"),
    (Join-Path $env:USERPROFILE "Downloads\flutter\bin\flutter.bat")
)

$adbPath = Resolve-ToolPath -CommandName "adb" -Fallbacks @(
    (Join-Path $env:LOCALAPPDATA "Android\Sdk\platform-tools\adb.exe"),
    (Join-Path $env:LOCALAPPDATA "Android\sdk\platform-tools\adb.exe")
)

$emulatorPath = Resolve-ToolPath -CommandName "emulator" -Fallbacks @(
    (Join-Path $env:LOCALAPPDATA "Android\Sdk\emulator\emulator.exe"),
    (Join-Path $env:LOCALAPPDATA "Android\sdk\emulator\emulator.exe")
)

$deviceId = Get-RunningEmulatorId -AdbPath $adbPath

if (-not $deviceId) {
    Write-Host "Iniciando emulador '$AvdName' en modo estable..." -ForegroundColor Cyan
    Start-Process -FilePath $emulatorPath -ArgumentList @(
        "-avd", $AvdName,
        "-gpu", "software",
        "-no-snapshot-load",
        "-no-metrics"
    ) | Out-Null

    $deadline = (Get-Date).AddMinutes(4)
    do {
        Start-Sleep -Seconds 5
        $deviceId = Get-RunningEmulatorId -AdbPath $adbPath
    } while (-not $deviceId -and (Get-Date) -lt $deadline)

    if (-not $deviceId) {
        throw "No aparecio ningun emulador en adb despues de iniciar '$AvdName'."
    }
}
else {
    Write-Host "Usando emulador ya activo: $deviceId" -ForegroundColor Yellow
}

Write-Host "Esperando a que Android termine de arrancar..." -ForegroundColor Cyan
& $adbPath -s $deviceId wait-for-device | Out-Null
Wait-ForBootComplete -AdbPath $adbPath -DeviceId $deviceId

$flutterArgs = @("run", "-d", $deviceId)
if ($ApiBaseUrl) {
    $flutterArgs += "--dart-define=API_BASE_URL=$ApiBaseUrl"
}

Write-Host "Abriendo appfitness en $deviceId..." -ForegroundColor Green
& $flutterPath @flutterArgs
