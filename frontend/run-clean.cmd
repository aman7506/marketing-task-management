@echo off
set NODE_NO_WARNINGS=1
set NODE_OPTIONS=--no-deprecation --no-warnings --trace-deprecation=false --max-old-space-size=4096
set NODE_ENV=production
echo Starting Angular with COMPLETE warning suppression...
node start-ultimate.js serve
