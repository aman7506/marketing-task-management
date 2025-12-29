# Run as Administrator
param(
	[string]$SiteName = "MarketingForm",
	[string]$AppPoolName = "MarketingFormAppPool",
	[string]$IisPath = "C:\inetpub\wwwroot\Aman_Publish_Files\Marketing_Form\publish"
)

$ErrorActionPreference = 'Stop'

Write-Host "Cleaning previous outputs..."
# Backend clean
Remove-Item -Path "backend\bin", "backend\obj", "backend\publish", "backend\publish_clean" -Recurse -Force -ErrorAction SilentlyContinue
# Frontend clean
Remove-Item -Path "frontend\dist" -Recurse -Force -ErrorAction SilentlyContinue

Write-Host "Restoring packages..."
dotnet restore "backend\MarketingTaskAPI.csproj"

Write-Host "Building Angular (production)..."
# Ensure node modules present
if (-not (Test-Path "frontend\node_modules")) { Push-Location frontend; npm ci --no-audit --no-fund; Pop-Location }
# Build prod
Push-Location frontend
npm run build --silent
Pop-Location

Write-Host "Publishing backend..."
dotnet publish "backend\MarketingTaskAPI.csproj" -c Release -o "backend\publish_clean" --nologo

Write-Host "Copy Angular build to publish root..."
robocopy "frontend\dist\marketing-form" "backend\publish_clean" /E /XO | Out-Null

Write-Host "Ensure web.config present..."
Copy-Item -Path "backend\web.config" -Destination "backend\publish_clean\web.config" -Force

Write-Host "Deploying to IIS path: $IisPath"
Import-Module WebAdministration -ErrorAction SilentlyContinue
if (Get-Website -Name $SiteName -ErrorAction SilentlyContinue) { Stop-Website -Name $SiteName }
if (-not (Test-Path $IisPath)) { New-Item -ItemType Directory -Path $IisPath -Force | Out-Null }
robocopy "backend\publish_clean" $IisPath /E /MIR | Out-Null

Write-Host "Setting permissions..."
icacls $IisPath /grant "IIS_IUSRS:(OI)(CI)M" /T | Out-Null
if (Test-Path "IIS:\AppPools\$AppPoolName") { icacls $IisPath /grant "IIS AppPool\${AppPoolName}:(OI)(CI)M" /T | Out-Null }

Write-Host "Start site..."
if (Get-Website -Name $SiteName -ErrorAction SilentlyContinue) {
	Set-ItemProperty "IIS:\Sites\$SiteName" -Name physicalPath -Value $IisPath
	Start-Website -Name $SiteName
}

iisreset | Out-Null

Write-Host "Verifying..."
try {
	$resp = Invoke-WebRequest -UseBasicParsing -TimeoutSec 15 'http://172.1.3.201:1010'
	Write-Host ("HTTP: {0}" -f $resp.StatusCode)
}
catch {
	Write-Host ("HTTP Error: {0}" -f $_.Exception.Message)
}
