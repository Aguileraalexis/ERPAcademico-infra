@echo off
setlocal enabledelayedexpansion

REM Ir a la carpeta donde está este .bat y luego a /lambdas
cd ..\lambdas

echo === Generando ZIPs de lambdas para Terraform ===

for /D %%F in (*) do (
  REM Omitimos la carpeta common (solo helpers compartidos)
  if /I not "%%F"=="common" (
    echo Creando %%F.zip ...
    powershell -NoLogo -NoProfile -Command ^
      "Compress-Archive -Path '%%F\*' -DestinationPath '%%F.zip' -Force" >nul
  )
)

echo.
echo Listo. ZIPs generados en %CD%.
endlocal
