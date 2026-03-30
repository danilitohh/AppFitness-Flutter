param(
    [string]$OutputName = "appfitness-android-release.apk",
    [string]$ApiBaseUrl = "",
    [string]$ConfigPath = "",
    [switch]$AllowLocalApiBaseUrl
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

function Load-InstallerConfig {
    param(
        [Parameter(Mandatory = $true)]
        [string]$Path
    )

    if (-not (Test-Path $Path)) {
        throw "No existe el archivo de configuracion '$Path'."
    }

    $raw = Get-Content -LiteralPath $Path -Raw
    if ([string]::IsNullOrWhiteSpace($raw)) {
        return $null
    }

    return $raw | ConvertFrom-Json
}

function Get-ConfigValue {
    param(
        $Config,
        [Parameter(Mandatory = $true)]
        [string]$PropertyName
    )

    if ($null -eq $Config) {
        return ""
    }

    $property = $Config.PSObject.Properties[$PropertyName]
    if ($null -eq $property) {
        return ""
    }

    return [string]$property.Value
}

function Resolve-StringValue {
    param(
        [AllowEmptyCollection()]
        [AllowEmptyString()]
        [Parameter(Mandatory = $true)]
        [string[]]$Candidates
    )

    foreach ($candidate in $Candidates) {
        if (-not [string]::IsNullOrWhiteSpace($candidate)) {
            return $candidate.Trim()
        }
    }

    return ""
}

function Assert-RequiredValue {
    param(
        [Parameter(Mandatory = $true)]
        [string]$Value,
        [Parameter(Mandatory = $true)]
        [string]$Label,
        [Parameter(Mandatory = $true)]
        [string]$Hint
    )

    if ([string]::IsNullOrWhiteSpace($Value)) {
        throw "$Label no esta configurado. $Hint"
    }
}

function Test-LocalApiBaseUrl {
    param(
        [Parameter(Mandatory = $true)]
        [string]$Value
    )

    try {
        $uri = [Uri]$Value
    }
    catch {
        throw "API_BASE_URL no es una URL valida: $Value"
    }

    if (-not $uri.IsAbsoluteUri) {
        throw "API_BASE_URL debe ser absoluta, por ejemplo http://192.168.1.50/appfitness_api"
    }

    $localHosts = @("localhost", "127.0.0.1", "0.0.0.0", "10.0.2.2")
    return $localHosts -contains $uri.Host.ToLowerInvariant()
}

$projectRoot = Split-Path -Parent $PSScriptRoot
$defaultConfigPath = Join-Path $PSScriptRoot "android_installer.config.json"
if ([string]::IsNullOrWhiteSpace($ConfigPath) -and (Test-Path $defaultConfigPath)) {
    $ConfigPath = $defaultConfigPath
}

$config = $null
if (-not [string]::IsNullOrWhiteSpace($ConfigPath)) {
    $config = Load-InstallerConfig -Path $ConfigPath
}

$resolvedApiBaseUrl = Resolve-StringValue -Candidates @(
    $ApiBaseUrl,
    (Get-ConfigValue -Config $config -PropertyName "apiBaseUrl"),
    $env:APPFITNESS_ANDROID_API_BASE_URL
)

$flutterPath = Resolve-ToolPath -CommandName "flutter" -Fallbacks @(
    "C:\Users\danil\Downloads\flutter\bin\flutter.bat",
    "C:\src\flutter\bin\flutter.bat",
    "C:\flutter\bin\flutter.bat",
    (Join-Path $env:USERPROFILE "flutter\bin\flutter.bat"),
    (Join-Path $env:USERPROFILE "Downloads\flutter\bin\flutter.bat")
)

Assert-RequiredValue `
    -Value $resolvedApiBaseUrl `
    -Label "API_BASE_URL" `
    -Hint "Usa -ApiBaseUrl, APPFITNESS_ANDROID_API_BASE_URL o scripts\android_installer.config.json."

if ((Test-LocalApiBaseUrl -Value $resolvedApiBaseUrl) -and -not $AllowLocalApiBaseUrl) {
    throw "API_BASE_URL apunta a localhost/10.0.2.2 y un celular real no podra llegar ahi. Usa la IP LAN o dominio real, o confirma con -AllowLocalApiBaseUrl."
}

$distDir = Join-Path $projectRoot "dist"
$releaseApk = Join-Path $projectRoot "build\app\outputs\flutter-apk\app-release.apk"
$outputApk = Join-Path $distDir $OutputName
$buildInfoPath = Join-Path $distDir ("{0}.build-info.txt" -f [IO.Path]::GetFileNameWithoutExtension($OutputName))

if (-not (Test-Path $distDir)) {
    New-Item -ItemType Directory -Path $distDir | Out-Null
}

$flutterArgs = @(
    "build",
    "apk",
    "--release",
    "--dart-define=API_BASE_URL=$resolvedApiBaseUrl"
)

$configPathLabel = "(no usado)"
if (-not [string]::IsNullOrWhiteSpace($ConfigPath)) {
    $configPathLabel = $ConfigPath
}

Write-Host "Compilando APK release para Android..." -ForegroundColor Cyan
Write-Host "API_BASE_URL: $resolvedApiBaseUrl" -ForegroundColor DarkCyan
Write-Host "Archivo de configuracion: $configPathLabel" -ForegroundColor DarkCyan

& $flutterPath @flutterArgs
if ($LASTEXITCODE -ne 0) {
    throw "flutter build apk fallo con codigo $LASTEXITCODE."
}

if (-not (Test-Path $releaseApk)) {
    throw "No se genero el APK esperado en '$releaseApk'."
}

Copy-Item -LiteralPath $releaseApk -Destination $outputApk -Force

$buildInfo = @(
    "Generado: $(Get-Date -Format 'yyyy-MM-dd HH:mm:ss')",
    "APK: $outputApk",
    "API_BASE_URL: $resolvedApiBaseUrl",
    "Config usado: $configPathLabel"
)
$buildInfo | Set-Content -LiteralPath $buildInfoPath -Encoding UTF8

Write-Host ""
Write-Host "APK listo para instalar en Android:" -ForegroundColor Green
Write-Host $outputApk
Write-Host ""
Write-Host "Resumen guardado en:" -ForegroundColor Green
Write-Host $buildInfoPath
