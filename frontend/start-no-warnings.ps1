# Set environment variables
$env:NODE_NO_WARNINGS = "1"
$env:NODE_OPTIONS = "--no-deprecation --no-warnings --trace-deprecation=false --max-old-space-size=4096 --disable-warning=DEP0060 --no-warnings --trace-warnings=false"

# Start the application
node start-ultimate.js serve