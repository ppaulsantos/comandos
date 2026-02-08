@echo off
echo Atualizando todos os aplicativos via winget...
winget upgrade --all --include-unknown --accept-source-agreements --accept-package-agreements
echo.

echo Atualizando todos os aplicativos via Chocolatey...
choco upgrade all -y
@REM echo Atualizacao concluida. Pressione qualquer tecla para sair.
@REM pause > nul