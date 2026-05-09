param()

# Script de branding del proyecto.
# Genera el icono maestro, versiones nativas y recursos del splash.

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

Add-Type -AssemblyName System.Drawing

$projectRoot = Split-Path -Parent $PSScriptRoot

function Ensure-Directory {
  param([string]$Path)
  if (-not (Test-Path -LiteralPath $Path)) {
    New-Item -ItemType Directory -Path $Path | Out-Null
  }
}

function New-Color {
  param(
    [int]$R,
    [int]$G,
    [int]$B,
    [int]$A = 255
  )

  return [System.Drawing.Color]::FromArgb($A, $R, $G, $B)
}

function Set-GraphicsQuality {
  param([System.Drawing.Graphics]$Graphics)

  $Graphics.SmoothingMode = [System.Drawing.Drawing2D.SmoothingMode]::AntiAlias
  $Graphics.InterpolationMode = [System.Drawing.Drawing2D.InterpolationMode]::HighQualityBicubic
  $Graphics.PixelOffsetMode = [System.Drawing.Drawing2D.PixelOffsetMode]::HighQuality
  $Graphics.CompositingQuality = [System.Drawing.Drawing2D.CompositingQuality]::HighQuality
}

function Draw-AppMark {
  param(
    [System.Drawing.Graphics]$Graphics,
    [float]$CanvasSize,
    [float]$MarkSize,
    [float]$OffsetX,
    [float]$OffsetY
  )

  $white = New-Color -R 255 -G 255 -B 255
  $accent = New-Color -R 255 -G 120 -B 88
  $shadow = New-Color -R 0 -G 0 -B 0 -A 34

  $leftLeg = @(
    [System.Drawing.PointF]::new($OffsetX + ($MarkSize * 0.22), $OffsetY + ($MarkSize * 0.80)),
    [System.Drawing.PointF]::new($OffsetX + ($MarkSize * 0.50), $OffsetY + ($MarkSize * 0.18)),
    [System.Drawing.PointF]::new($OffsetX + ($MarkSize * 0.78), $OffsetY + ($MarkSize * 0.80))
  )

  $pulse = @(
    [System.Drawing.PointF]::new($OffsetX + ($MarkSize * 0.26), $OffsetY + ($MarkSize * 0.58)),
    [System.Drawing.PointF]::new($OffsetX + ($MarkSize * 0.40), $OffsetY + ($MarkSize * 0.58)),
    [System.Drawing.PointF]::new($OffsetX + ($MarkSize * 0.48), $OffsetY + ($MarkSize * 0.44)),
    [System.Drawing.PointF]::new($OffsetX + ($MarkSize * 0.56), $OffsetY + ($MarkSize * 0.66)),
    [System.Drawing.PointF]::new($OffsetX + ($MarkSize * 0.64), $OffsetY + ($MarkSize * 0.50)),
    [System.Drawing.PointF]::new($OffsetX + ($MarkSize * 0.76), $OffsetY + ($MarkSize * 0.58))
  )

  $legShadowPen = New-Object System.Drawing.Pen($shadow, ($MarkSize * 0.125))
  $legShadowPen.StartCap = [System.Drawing.Drawing2D.LineCap]::Round
  $legShadowPen.EndCap = [System.Drawing.Drawing2D.LineCap]::Round
  $legShadowPen.LineJoin = [System.Drawing.Drawing2D.LineJoin]::Round
  $pulseShadowPen = New-Object System.Drawing.Pen($shadow, ($MarkSize * 0.055))
  $pulseShadowPen.StartCap = [System.Drawing.Drawing2D.LineCap]::Round
  $pulseShadowPen.EndCap = [System.Drawing.Drawing2D.LineCap]::Round
  $pulseShadowPen.LineJoin = [System.Drawing.Drawing2D.LineJoin]::Round

  $shadowShiftX = $MarkSize * 0.016
  $shadowShiftY = $MarkSize * 0.02
  $shadowLeg = foreach ($point in $leftLeg) {
    [System.Drawing.PointF]::new($point.X + $shadowShiftX, $point.Y + $shadowShiftY)
  }
  $shadowPulse = foreach ($point in $pulse) {
    [System.Drawing.PointF]::new($point.X + $shadowShiftX, $point.Y + $shadowShiftY)
  }

  $Graphics.DrawLines($legShadowPen, $shadowLeg)
  $Graphics.DrawLines($pulseShadowPen, $shadowPulse)

  $legPen = New-Object System.Drawing.Pen($white, ($MarkSize * 0.125))
  $legPen.StartCap = [System.Drawing.Drawing2D.LineCap]::Round
  $legPen.EndCap = [System.Drawing.Drawing2D.LineCap]::Round
  $legPen.LineJoin = [System.Drawing.Drawing2D.LineJoin]::Round

  $pulsePen = New-Object System.Drawing.Pen($accent, ($MarkSize * 0.055))
  $pulsePen.StartCap = [System.Drawing.Drawing2D.LineCap]::Round
  $pulsePen.EndCap = [System.Drawing.Drawing2D.LineCap]::Round
  $pulsePen.LineJoin = [System.Drawing.Drawing2D.LineJoin]::Round

  $Graphics.DrawLines($legPen, $leftLeg)
  $Graphics.DrawLines($pulsePen, $pulse)

  $legShadowPen.Dispose()
  $pulseShadowPen.Dispose()
  $legPen.Dispose()
  $pulsePen.Dispose()
}

function New-AppIconBitmap {
  param([int]$Size)

  $bitmap = New-Object System.Drawing.Bitmap(
    $Size,
    $Size,
    [System.Drawing.Imaging.PixelFormat]::Format32bppArgb
  )
  $graphics = [System.Drawing.Graphics]::FromImage($bitmap)
  Set-GraphicsQuality -Graphics $graphics

  $startColor = New-Color -R 7 -G 27 -B 46
  $endColor = New-Color -R 19 -G 132 -B 146
  $accentGlow = New-Color -R 255 -G 120 -B 88 -A 26
  $softWhite = New-Color -R 255 -G 255 -B 255 -A 22

  $gradient = New-Object System.Drawing.Drawing2D.LinearGradientBrush(
    [System.Drawing.PointF]::new(0, 0),
    [System.Drawing.PointF]::new($Size, $Size),
    $startColor,
    $endColor
  )
  $graphics.FillRectangle($gradient, 0, 0, $Size, $Size)

  $highlightBrush = New-Object System.Drawing.SolidBrush($softWhite)
  $graphics.FillEllipse(
    $highlightBrush,
    -($Size * 0.10),
    -($Size * 0.16),
    ($Size * 0.72),
    ($Size * 0.72)
  )

  $glowBrush = New-Object System.Drawing.SolidBrush($accentGlow)
  $graphics.FillEllipse(
    $glowBrush,
    ($Size * 0.56),
    ($Size * 0.60),
    ($Size * 0.34),
    ($Size * 0.34)
  )

  Draw-AppMark -Graphics $graphics -CanvasSize $Size -MarkSize ($Size * 0.66) -OffsetX ($Size * 0.17) -OffsetY ($Size * 0.14)

  $borderPen = New-Object System.Drawing.Pen((New-Color -R 255 -G 255 -B 255 -A 26), ($Size * 0.028))
  $graphics.DrawRectangle($borderPen, ($Size * 0.038), ($Size * 0.038), ($Size * 0.924), ($Size * 0.924))

  $borderPen.Dispose()
  $highlightBrush.Dispose()
  $glowBrush.Dispose()
  $gradient.Dispose()
  $graphics.Dispose()

  return $bitmap
}

function New-LaunchLogoBitmap {
  param([int]$Size)

  $bitmap = New-Object System.Drawing.Bitmap(
    $Size,
    $Size,
    [System.Drawing.Imaging.PixelFormat]::Format32bppArgb
  )
  $graphics = [System.Drawing.Graphics]::FromImage($bitmap)
  Set-GraphicsQuality -Graphics $graphics
  $graphics.Clear([System.Drawing.Color]::Transparent)

  Draw-AppMark -Graphics $graphics -CanvasSize $Size -MarkSize ($Size * 0.72) -OffsetX ($Size * 0.14) -OffsetY ($Size * 0.10)

  $graphics.Dispose()
  return $bitmap
}

function New-IosLaunchImageBitmap {
  param(
    [int]$Width,
    [int]$Height
  )

  $bitmap = New-Object System.Drawing.Bitmap(
    $Width,
    $Height,
    [System.Drawing.Imaging.PixelFormat]::Format32bppArgb
  )
  $graphics = [System.Drawing.Graphics]::FromImage($bitmap)
  Set-GraphicsQuality -Graphics $graphics
  $graphics.Clear([System.Drawing.Color]::Transparent)

  $markSize = [Math]::Min($Width, $Height) * 0.82
  $offsetX = ($Width - $markSize) / 2
  $offsetY = ($Height - $markSize) / 2

  Draw-AppMark -Graphics $graphics -CanvasSize ([Math]::Min($Width, $Height)) -MarkSize $markSize -OffsetX $offsetX -OffsetY $offsetY

  $graphics.Dispose()
  return $bitmap
}

function Save-Png {
  param(
    [System.Drawing.Bitmap]$Bitmap,
    [string]$Path
  )

  $directory = Split-Path -Parent $Path
  Ensure-Directory -Path $directory
  $Bitmap.Save($Path, [System.Drawing.Imaging.ImageFormat]::Png)
}

$brandingDir = Join-Path $projectRoot 'assets\branding'
$androidResDir = Join-Path $projectRoot 'android\app\src\main\res'
$iosIconDir = Join-Path $projectRoot 'ios\Runner\Assets.xcassets\AppIcon.appiconset'
$iosLaunchDir = Join-Path $projectRoot 'ios\Runner\Assets.xcassets\LaunchImage.imageset'

Ensure-Directory -Path $brandingDir

$masterIcon = New-AppIconBitmap -Size 1024
Save-Png -Bitmap $masterIcon -Path (Join-Path $brandingDir 'app_icon_master.png')
Save-Png -Bitmap $masterIcon -Path (Join-Path $iosIconDir 'Icon-App-1024x1024@1x.png')

$androidIcons = @{
  'mipmap-mdpi\ic_launcher.png' = 48
  'mipmap-hdpi\ic_launcher.png' = 72
  'mipmap-xhdpi\ic_launcher.png' = 96
  'mipmap-xxhdpi\ic_launcher.png' = 144
  'mipmap-xxxhdpi\ic_launcher.png' = 192
}

foreach ($entry in $androidIcons.GetEnumerator()) {
  $bitmap = New-AppIconBitmap -Size $entry.Value
  Save-Png -Bitmap $bitmap -Path (Join-Path $androidResDir $entry.Key)
  $bitmap.Dispose()
}

$iosIconSizes = @{
  'Icon-App-20x20@1x.png' = 20
  'Icon-App-20x20@2x.png' = 40
  'Icon-App-20x20@3x.png' = 60
  'Icon-App-29x29@1x.png' = 29
  'Icon-App-29x29@2x.png' = 58
  'Icon-App-29x29@3x.png' = 87
  'Icon-App-40x40@1x.png' = 40
  'Icon-App-40x40@2x.png' = 80
  'Icon-App-40x40@3x.png' = 120
  'Icon-App-60x60@2x.png' = 120
  'Icon-App-60x60@3x.png' = 180
  'Icon-App-76x76@1x.png' = 76
  'Icon-App-76x76@2x.png' = 152
  'Icon-App-83.5x83.5@2x.png' = 167
}

foreach ($entry in $iosIconSizes.GetEnumerator()) {
  $bitmap = New-AppIconBitmap -Size $entry.Value
  Save-Png -Bitmap $bitmap -Path (Join-Path $iosIconDir $entry.Key)
  $bitmap.Dispose()
}

$launchLogo = New-LaunchLogoBitmap -Size 768
Save-Png -Bitmap $launchLogo -Path (Join-Path $brandingDir 'launch_logo.png')
Save-Png -Bitmap $launchLogo -Path (Join-Path $androidResDir 'drawable\launch_logo.png')

$iosLaunchImages = @(
  @{ Name = 'LaunchImage.png'; Width = 168; Height = 185 },
  @{ Name = 'LaunchImage@2x.png'; Width = 336; Height = 370 },
  @{ Name = 'LaunchImage@3x.png'; Width = 504; Height = 555 }
)

foreach ($image in $iosLaunchImages) {
  $bitmap = New-IosLaunchImageBitmap -Width $image.Width -Height $image.Height
  Save-Png -Bitmap $bitmap -Path (Join-Path $iosLaunchDir $image.Name)
  $bitmap.Dispose()
}

$launchLogo.Dispose()
$masterIcon.Dispose()

Write-Output 'Brand assets generated.'
