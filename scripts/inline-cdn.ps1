# Inline CDN libraries into a single self-contained HTML file
# Usage: powershell -File inline-cdn.ps1 -TargetHtml "path/to/file.html" -LibDir "path/to/assets/lib"
# Replaces all CDN <link> and <script> tags with inlined content from LibDir

param(
  [Parameter(Mandatory=$true)][string]$TargetHtml,
  [Parameter(Mandatory=$true)][string]$LibDir
)

$files = @{
  'leaflet.css'          = '<link rel="stylesheet" href="https://cdn\.jsdelivr\.net/npm/leaflet@1\.9\.4/dist/leaflet\.css">'
  'leaflet.js'           = '<script src="https://cdn\.jsdelivr\.net/npm/leaflet@1\.9\.4/dist/leaflet\.js"></script>'
  'maplibre-gl.css'      = '<link href="https://cdn\.jsdelivr\.net/npm/maplibre-gl@4\.7\.1/dist/maplibre-gl\.css" rel="stylesheet">'
  'maplibre-gl.js'       = '<script src="https://cdn\.jsdelivr\.net/npm/maplibre-gl@4\.7\.1/dist/maplibre-gl\.js"></script>'
  'leaflet-maplibre-gl.js' = '<script src="https://cdn\.jsdelivr\.net/npm/@maplibre/maplibre-gl-leaflet@0\.0\.22/leaflet-maplibre-gl\.js"></script>'
}

$html = [System.IO.File]::ReadAllText($TargetHtml)

foreach ($entry in $files.GetEnumerator()) {
  $filePath = Join-Path $LibDir $entry.Key
  if (-not (Test-Path $filePath)) {
    Write-Warning "Skipping $($entry.Key) — file not found at $filePath"
    continue
  }
  $content = [System.IO.File]::ReadAllText($filePath)
  $extension = [System.IO.Path]::GetExtension($entry.Key)
  $tag = if ($extension -eq '.css') { "<style>`n/* === $($entry.Key) (内联) === */`n$content`n</style>" }
         else { "<script>`n/* === $($entry.Key) (内联) === */`n$content`n</script>" }
  $html = $html -replace $entry.Value, $tag
}

[System.IO.File]::WriteAllText($TargetHtml, $html)
$size = [math]::Round((Get-Item $TargetHtml).Length / 1024)
Write-Host "Done. $TargetHtml → $size KB (all CDN inlined)"