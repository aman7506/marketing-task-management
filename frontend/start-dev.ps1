# PowerShell script to start Angular development server without warnings
Write-Host "Starting Marketing Form Development Server..." -ForegroundColor Green
Write-Host ""

# Set environment variables to suppress warnings
$env:NODE_NO_WARNINGS = "1"
$env:NODE_OPTIONS = "--no-deprecation --no-warnings"

# Start the Angular development server
Write-Host "Launching Angular CLI..." -ForegroundColor Yellow
node --no-deprecation --no-warnings node_modules/@angular/cli/bin/ng serve

Write-Host "Development server stopped." -ForegroundColor Red
