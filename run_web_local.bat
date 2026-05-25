@echo off
setlocal

cd /d "%~dp0web"

where python >nul 2>nul
if %errorlevel%==0 (
  start "" "http://localhost:8080"
  python -m http.server 8080
  exit /b %errorlevel%
)

where py >nul 2>nul
if %errorlevel%==0 (
  start "" "http://localhost:8080"
  py -m http.server 8080
  exit /b %errorlevel%
)

echo Python nao foi encontrado. Instale o Python ou rode: flutter run -d chrome
pause
