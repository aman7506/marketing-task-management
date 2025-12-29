Write-Host "Starting Angular with ULTIMATE warning suppression..." -ForegroundColor Green

# Set environment variables at system level
$env:NODE_NO_WARNINGS = "1"
$env:NODE_OPTIONS = "--no-deprecation --no-warnings --trace-deprecation=false --max-old-space-size=4096"
$env:NODE_ENV = "production"

# Additional Node.js flags
$env:NODE_DISABLE_COLORS = "1"
$env:SUPPRESS_NO_CONFIG_WARNING = "true"

Write-Host "Environment variables set. Starting Angular..." -ForegroundColor Yellow

# Start the application
node start-ultimate.js serve
