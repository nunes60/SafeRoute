@echo off
setlocal

cd /d "%~dp0"

where flutter >nul 2>nul
if %errorlevel% neq 0 (
  echo Flutter nao foi encontrado. Adicione o Flutter ao PATH e tente novamente.
  pause
  exit /b 1
)

echo Gerando a versao web atualizada...
call flutter build web
if %errorlevel% neq 0 (
  echo Falha ao gerar build/web.
  pause
  exit /b %errorlevel%
)

cd /d "%~dp0build\web"

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
