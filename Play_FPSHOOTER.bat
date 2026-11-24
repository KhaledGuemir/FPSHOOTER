@echo off
setlocal
cd /d "%~dp0"
echo ========================================================
echo   Launching FPSHOOTER (Godot 4.7) - Sunset City Range
echo ========================================================
if exist "engine\Godot_v4.7.2-stable_win64.exe" (
    start "" "engine\Godot_v4.7.2-stable_win64.exe" --path "%~dp0."
) else (
    echo [ERROR] Godot executable not found in engine directory!
    pause
)
