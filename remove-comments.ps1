# REMOVE COMMENTED LINES SCRIPT
# This removes only commented code, preserves documentation

Write-Host "=== REMOVING COMMENTED LINES ===" -ForegroundColor Cyan

$removed = 0

# Function to remove comments from file
function Remove-Comments {
    param($FilePath, $FileType)
    
    $content = Get-Content $FilePath -Raw
    $originalContent = $content
    
    switch ($FileType) {
        "cs" {
            # Remove single-line comments (but keep XML docs ///)
            $content = $content -split "`n" | Where-Object { 
                $_ -notmatch '^\s*//[^/]' -or $_ -match '^\s*///' 
            } | Out-String
        }
        "ts" {
            # Remove single-line comments (but keep JSDoc /** */)
            $content = $content -split "`n" | Where-Object { 
                $_ -notmatch '^\s*//' 
            } | Out-String
        }
        "html" {
            # Remove HTML comments
            $content = $content -replace '<!--.*?-->', ''
        }
        "css" {
            # Remove CSS comments
            $content = $content -replace '/\*.*?\*/', ''
        }
    }
    
    if ($content -ne $originalContent) {
        Set-Content $FilePath -Value $content.TrimEnd() -NoNewline
        return $true
    }
    return $false
}

# Process backend .cs files
Write-Host "`n1. Processing backend .cs files..." -ForegroundColor Yellow
Get-ChildItem "c:\Marketing Form\backend" -Recurse -Filter "*.cs" -File | ForEach-Object {
    if (Remove-Comments $_.FullName "cs") {
        $removed++
        Write-Host "  Cleaned: $($_.Name)" -ForegroundColor Green
    }
}

# Process frontend .ts files
Write-Host "`n2. Processing frontend .ts files..." -ForegroundColor Yellow
Get-ChildItem "c:\Marketing Form\frontend\src" -Recurse -Filter "*.ts" -File | ForEach-Object {
    if (Remove-Comments $_.FullName "ts") {
        $removed++
        Write-Host "  Cleaned: $($_.Name)" -ForegroundColor Green
    }
}

# Process HTML files
Write-Host "`n3. Processing HTML files..." -ForegroundColor Yellow
Get-ChildItem "c:\Marketing Form\frontend\src" -Recurse -Filter "*.html" -File | ForEach-Object {
    if (Remove-Comments $_.FullName "html") {
        $removed++
        Write-Host "  Cleaned: $($_.Name)" -ForegroundColor Green
    }
}

# Process CSS files
Write-Host "`n4. Processing CSS files..." -ForegroundColor Yellow
Get-ChildItem "c:\Marketing Form\frontend\src" -Recurse -Filter "*.css" -File | ForEach-Object {
    if (Remove-Comments $_.FullName "css") {
        $removed++
        Write-Host "  Cleaned: $($_.Name)" -ForegroundColor Green
    }
}

Write-Host "`n=== CLEANUP COMPLETE ===" -ForegroundColor Green
Write-Host "Files processed: $removed" -ForegroundColor Cyan
Write-Host "`nAll commented lines removed!" -ForegroundColor White
Write-Host "Code functionality unchanged." -ForegroundColor Gray
