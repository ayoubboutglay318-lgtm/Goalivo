Add-Type -AssemblyName System.Drawing

$ErrorActionPreference = "Stop"
$root = Split-Path -Parent (Split-Path -Parent $MyInvocation.MyCommand.Path)
$outDir = Join-Path $root "assets\store"
New-Item -ItemType Directory -Force -Path $outDir | Out-Null

function New-Color([string]$hex) {
  return [System.Drawing.ColorTranslator]::FromHtml($hex)
}

function New-Font([string]$name, [float]$size, [System.Drawing.FontStyle]$style) {
  try {
    return [System.Drawing.Font]::new($name, $size, $style, [System.Drawing.GraphicsUnit]::Pixel)
  } catch {
    return [System.Drawing.Font]::new("Arial", $size, $style, [System.Drawing.GraphicsUnit]::Pixel)
  }
}

function Enable-Quality($g) {
  $g.SmoothingMode = [System.Drawing.Drawing2D.SmoothingMode]::AntiAlias
  $g.TextRenderingHint = [System.Drawing.Text.TextRenderingHint]::AntiAliasGridFit
  $g.InterpolationMode = [System.Drawing.Drawing2D.InterpolationMode]::HighQualityBicubic
}

function Draw-GoalivoIcon($g, [float]$cx, [float]$cy, [float]$r) {
  $shadowBrush = [System.Drawing.SolidBrush]::new([System.Drawing.Color]::FromArgb(60, 22, 163, 74))
  $g.FillEllipse($shadowBrush, $cx - $r - 18, $cy - $r + 18, ($r + 18) * 2, ($r + 18) * 2)
  $shadowBrush.Dispose()

  $rect = [System.Drawing.RectangleF]::new($cx - $r, $cy - $r, $r * 2, $r * 2)
  $green = [System.Drawing.Drawing2D.LinearGradientBrush]::new($rect, (New-Color "#22c55e"), (New-Color "#16a34a"), 45)
  $g.FillEllipse($green, $rect)
  $green.Dispose()

  $white = [System.Drawing.SolidBrush]::new([System.Drawing.Color]::White)
  $g.FillEllipse($white, $cx - ($r * .74), $cy - ($r * .74), $r * 1.48, $r * 1.48)
  $inner = [System.Drawing.Drawing2D.LinearGradientBrush]::new(
    [System.Drawing.RectangleF]::new($cx - ($r * .48), $cy - ($r * .48), $r * .96, $r * .96),
    (New-Color "#4ade80"),
    (New-Color "#22c55e"),
    45
  )
  $g.FillEllipse($inner, $cx - ($r * .48), $cy - ($r * .48), $r * .96, $r * .96)
  $inner.Dispose()
  $g.FillEllipse($white, $cx - ($r * .22), $cy - ($r * .22), $r * .44, $r * .44)

  $pen = [System.Drawing.Pen]::new([System.Drawing.Color]::White, [Math]::Max(8, $r * .14))
  $pen.StartCap = [System.Drawing.Drawing2D.LineCap]::Round
  $pen.EndCap = [System.Drawing.Drawing2D.LineCap]::Round
  $g.DrawLine($pen, $cx - ($r * .39), $cy + ($r * .39), $cx + ($r * .20), $cy - ($r * .20))
  $pen.Dispose()

  $arrow = [System.Drawing.Drawing2D.GraphicsPath]::new()
  $arrow.AddPolygon(@(
    [System.Drawing.PointF]::new($cx + ($r * .20), $cy - ($r * .39)),
    [System.Drawing.PointF]::new($cx + ($r * .39), $cy - ($r * .20)),
    [System.Drawing.PointF]::new($cx + ($r * .02), $cy - ($r * .02))
  ))
  $g.FillPath($white, $arrow)
  $arrow.Dispose()
  $white.Dispose()
}

function Save-AppIcon([int]$size, [string]$path) {
  $bmp = [System.Drawing.Bitmap]::new($size, $size, [System.Drawing.Imaging.PixelFormat]::Format24bppRgb)
  $g = [System.Drawing.Graphics]::FromImage($bmp)
  Enable-Quality $g

  $bg = [System.Drawing.Drawing2D.LinearGradientBrush]::new(
    [System.Drawing.Rectangle]::new(0, 0, $size, $size),
    (New-Color "#06130f"),
    (New-Color "#0b2535"),
    45
  )
  $g.FillRectangle($bg, 0, 0, $size, $size)
  $bg.Dispose()

  for ($i = 0; $i -lt 9; $i++) {
    $alpha = 18 - $i
    $pen = [System.Drawing.Pen]::new([System.Drawing.Color]::FromArgb($alpha, 74, 222, 128), 2)
    $offset = 90 + ($i * 70)
    $g.DrawLine($pen, 0, $offset, $size, $offset - 220)
    $pen.Dispose()
  }

  Draw-GoalivoIcon $g ($size / 2) ($size / 2) ($size * .31)
  $g.Dispose()
  $bmp.Save($path, [System.Drawing.Imaging.ImageFormat]::Png)
  $bmp.Dispose()
}

function Save-FeatureGraphic([string]$path) {
  $w = 1024
  $h = 500
  $bmp = [System.Drawing.Bitmap]::new($w, $h, [System.Drawing.Imaging.PixelFormat]::Format24bppRgb)
  $g = [System.Drawing.Graphics]::FromImage($bmp)
  Enable-Quality $g

  $bg = [System.Drawing.Drawing2D.LinearGradientBrush]::new(
    [System.Drawing.Rectangle]::new(0, 0, $w, $h),
    (New-Color "#060a16"),
    (New-Color "#0b3b26"),
    20
  )
  $g.FillRectangle($bg, 0, 0, $w, $h)
  $bg.Dispose()

  $linePen = [System.Drawing.Pen]::new([System.Drawing.Color]::FromArgb(38, 255, 255, 255), 3)
  $g.DrawRectangle($linePen, 56, 52, $w - 112, $h - 104)
  $g.DrawLine($linePen, $w / 2, 52, $w / 2, $h - 52)
  $g.DrawEllipse($linePen, ($w / 2) - 76, ($h / 2) - 76, 152, 152)
  $g.DrawRectangle($linePen, 56, 156, 128, 188)
  $g.DrawRectangle($linePen, $w - 184, 156, 128, 188)
  $linePen.Dispose()

  Draw-GoalivoIcon $g 170 222 74

  $fontGoal = New-Font "Segoe UI" 72 ([System.Drawing.FontStyle]::Bold)
  $fontTagline = New-Font "Segoe UI" 20 ([System.Drawing.FontStyle]::Bold)
  $fontHeadline = New-Font "Segoe UI" 54 ([System.Drawing.FontStyle]::Bold)
  $fontSub = New-Font "Segoe UI" 24 ([System.Drawing.FontStyle]::Regular)
  $white = [System.Drawing.SolidBrush]::new([System.Drawing.Color]::White)
  $muted = [System.Drawing.SolidBrush]::new((New-Color "#d1d5db"))
  $green = [System.Drawing.SolidBrush]::new((New-Color "#22c55e"))
  $dark = [System.Drawing.SolidBrush]::new((New-Color "#172033"))

  $g.DrawString("goal", $fontGoal, $white, 270, 148)
  $g.DrawString("ivo", $fontGoal, $green, 422, 148)
  $g.DrawString("ACHIEVE MORE", $fontTagline, $muted, 276, 234)

  $g.DrawString("Live football", $fontHeadline, $white, 588, 126)
  $g.DrawString("scores & lineups", $fontHeadline, $green, 588, 188)
  $g.DrawString("Fixtures, stats, alerts,", $fontSub, $muted, 592, 274)
  $g.DrawString("and teams in one app.", $fontSub, $muted, 592, 304)

  $pill = [System.Drawing.RectangleF]::new(592, 356, 262, 50)
  $pathPill = [System.Drawing.Drawing2D.GraphicsPath]::new()
  $radius = 25
  $pathPill.AddArc($pill.X, $pill.Y, $radius * 2, $radius * 2, 180, 90)
  $pathPill.AddArc($pill.Right - $radius * 2, $pill.Y, $radius * 2, $radius * 2, 270, 90)
  $pathPill.AddArc($pill.Right - $radius * 2, $pill.Bottom - $radius * 2, $radius * 2, $radius * 2, 0, 90)
  $pathPill.AddArc($pill.X, $pill.Bottom - $radius * 2, $radius * 2, $radius * 2, 90, 90)
  $pathPill.CloseFigure()
  $g.FillPath($green, $pathPill)
  $pillFont = New-Font "Segoe UI" 21 ([System.Drawing.FontStyle]::Bold)
  $g.DrawString("Built for match day", $pillFont, $dark, 621, 367)

  foreach ($obj in @($fontGoal, $fontTagline, $fontHeadline, $fontSub, $pillFont, $white, $muted, $green, $dark, $pathPill)) {
    $obj.Dispose()
  }
  $g.Dispose()
  $bmp.Save($path, [System.Drawing.Imaging.ImageFormat]::Png)
  $bmp.Dispose()
}

Save-AppIcon 1024 (Join-Path $outDir "app-store-icon-1024.png")
Save-AppIcon 512 (Join-Path $outDir "google-play-icon-512.png")
Save-FeatureGraphic (Join-Path $outDir "google-play-feature-1024x500.png")

Write-Host "Generated store assets in $outDir"
