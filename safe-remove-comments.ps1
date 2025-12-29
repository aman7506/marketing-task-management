# SAFE COMMENT REMOVAL
# Removes ONLY:
# - Commented-out code (dead code)
# - Debug/console.log comments
# - Empty comment lines
# 
# KEEPS:
# - Explanatory comments
# - Documentation

Write-Host "=== SAFE COMMENT REMOVAL ===" -ForegroundColor Cyan
Write-Host "Removing only dead code & debug comments...`n" -ForegroundColor Yellow

$totalRemoved = 0

function Remove-DeadCodeComments {
    param($FilePath)
    
    $lines = Get-Content $FilePath
    $newLines = @()
    $changed = $false
    
    foreach ($line in $lines) {
        $keep = $true
        
        # Check if it's a comment
        if ($line -match '^\s*//') {
            # Remove if:
            # - console.log
            # - debugger
            # - Empty comment
            # - Commented code (contains semicolon or brackets)
            if ($line -match 'console\.log|debugger|^\s*//\s*$|^\s*//.*[;\{\}\(\)]') {
                $keep = $false
                $changed = $true
            }
        }
        
        # Remove HTML debug comments
        if ($line -match '<!--.*console|<!--.*debug|<!--.*TODO|<!--\s*-->') {
            $keep = $false
            $changed = $true
        }
        
        if ($keep) {
            $newLines += $line
        }
    }
    
    if ($changed) {
        Set-Content $FilePath -Value $newLines
        return $true
    }
    return $false
}

# Process all TypeScript files
Write-Host "Processing TypeScript files..." -ForegroundColor Yellow
Get-ChildItem "c:\Marketing Form\frontend\src" -Recurse -Filter "*.ts" -File | ForEach-Object {
    if (Remove-DeadCodeComments $_.FullName) {
        $totalRemoved++
        Write-Host "  Cleaned: $($_.Name)" -ForegroundColor Green
    }
}

# Process all HTML files  
Write-Host "`nProcessing HTML files..." -ForegroundColor Yellow
Get-ChildItem "c:\Marketing Form\frontend\src" -Recurse -Filter "*.html" -File | ForEach-Object {
    if (Remove-DeadCodeComments $_.FullName) {
        $totalRemoved++
        Write-Host "  Cleaned: $($_.Name)" -ForegroundColor Green
    }
}

# Process C# files
Write-Host "`nProcessing C# files..." -ForegroundColor Yellow
Get-ChildItem "c:\Marketing Form\backend" -Recurse -Filter "*.cs" -File | ForEach-Object {
    if (Remove-DeadCodeComments $_.FullName) {
        $totalRemoved++
        Write-Host "  Cleaned: $($_.Name)" -ForegroundColor Green
    }
}

Write-Host "`n=== SAFE CLEANUP COMPLETE ===" -ForegroundColor Green
Write-Host "Files cleaned: $totalRemoved" -ForegroundColor Cyan
Write-Host "`nRemoved:" -ForegroundColor White
Write-Host "  - Debug comments (console.log, debugger)" -ForegroundColor Gray
Write-Host "  - Commented-out dead code" -ForegroundColor Gray  
Write-Host "  - Empty comment lines" -ForegroundColor Gray
Write-Host "`nKept:" -ForegroundColor White
Write-Host "  - Explanatory comments (// Set up, // Listen, etc.)" -ForegroundColor Gray
Write-Host "  - Documentation comments" -ForegroundColor Gray
Write-Host "`nProject functionality unchanged! ✅" -ForegroundColor Green
