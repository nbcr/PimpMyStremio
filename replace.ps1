# ================================
# PimpMyStremio UI Fix Patcher
# - Replaces dead MDL CDN URLs
# - Fixes theme_switcher.js bug
# - Creates .bak backups
# - Windows PowerShell 5 compatible
# ================================

Write-Host "Starting PMS UI patch..." -ForegroundColor Cyan

# --- Dead MDL CDN URLs ---
$deadJs  = "https://code.getmdl.io/1.3.0/material.min.js"
$deadCss = "https://code.getmdl.io/1.3.0/material.orange-indigo.min.css"

# --- Working CDNJS replacements ---
$newJs   = "https://cdnjs.cloudflare.com/ajax/libs/material-design-lite/1.3.0/material.min.js"
$newCss  = "https://cdnjs.cloudflare.com/ajax/libs/material-design-lite/1.3.0/material.orange-indigo.min.css"

# --- Scan all HTML + JS files in repo ---
$files = Get-ChildItem -Recurse -Include *.html, *.js -File

foreach ($file in $files) {
    $content = Get-Content $file.FullName -Raw

    # Skip files that don't contain anything we patch
    if ($content -notmatch "code.getmdl.io" -and
        $content -notmatch "material.orange-indigo" -and
        $content -notmatch "link\.href\s*=\s*theme\s*;") {
        continue
    }

    # Backup original
    Copy-Item $file.FullName "$($file.FullName).bak" -Force

    # Replace MDL CDN URLs
    $content = $content.Replace($deadJs,  $newJs)
    $content = $content.Replace($deadCss, $newCss)

    # Fix theme_switcher.js bug
    # Replace: link.href = theme;
    # With:    link.href = theme.href;
    $content = $content -replace "link\.href\s*=\s*theme\s*;", "link.href = theme.href;"

    # Write patched file
    Set-Content -Path $file.FullName -Value $content -Encoding UTF8

    Write-Host "Patched: $($file.FullName)" -ForegroundColor Green
}

Write-Host "UI patch complete. Backups created as *.bak" -ForegroundColor Cyan
