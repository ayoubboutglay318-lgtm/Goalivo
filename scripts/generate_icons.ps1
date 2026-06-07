# Generate launcher icon PNGs from SVG and run flutter_launcher_icons
# Requires ImageMagick (`magick`) or Inkscape in PATH, and flutter in PATH.

$svg = "assets/goalivo_logo.svg"
$dst = "assets/goalivo_icon.png"
$size = 1024

Write-Host "Generating $dst from $svg (size ${size}x${size})..."

# Try ImageMagick first
if (Get-Command magick -ErrorAction SilentlyContinue) {
  magick convert -background none -resize ${size}x${size} "$svg" "$dst"
  if ($LASTEXITCODE -ne 0) { Write-Error "magick failed with exit code $LASTEXITCODE"; exit 1 }
  Write-Host "Created $dst using ImageMagick."
}
elseif (Get-Command inkscape -ErrorAction SilentlyContinue) {
  inkscape "$svg" --export-type=png --export-filename="$dst" --export-width=$size --export-height=$size
  if ($LASTEXITCODE -ne 0) { Write-Error "inkscape failed with exit code $LASTEXITCODE"; exit 1 }
  Write-Host "Created $dst using Inkscape."
}
else {
  Write-Error "Neither ImageMagick nor Inkscape found. Install one and re-run this script."; exit 1
}

# Ensure flutter is available
if (-not (Get-Command flutter -ErrorAction SilentlyContinue)) {
  Write-Error "Flutter not found in PATH. Please run this script in an environment with flutter available."; exit 1
}

Write-Host "Running flutter pub get..."
flutter pub get

Write-Host "Running flutter_launcher_icons to generate platform icons..."
flutter pub run flutter_launcher_icons:main

Write-Host "Done. You can now run: flutter clean && flutter run -d <deviceId> to reinstall the app with new icons."
