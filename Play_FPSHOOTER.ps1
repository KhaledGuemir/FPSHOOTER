$scriptPath = Split-Path -Parent $MyInvocation.MyCommand.Path
Set-Location $scriptPath
Write-Host "========================================================" -ForegroundColor Cyan
Write-Host "  Starting FPSHOOTER (Godot 4.7 Engine)" -ForegroundColor Yellow
Write-Host "========================================================" -ForegroundColor Cyan

$godotExe = Join-Path $scriptPath "engine\Godot_v4.7.2-stable_win64.exe"
if (Test-Path $godotExe) {
    Start-Process -FilePath $godotExe -ArgumentList "--path `"$scriptPath`""
} else {
    Write-Error "Godot binary not found in engine folder!"
}
