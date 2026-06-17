@echo off
REM Nao exibir cada comando antes de executar (saida mais limpa)
chcp 65001
REM Forca a code page UTF-8 para os acentos aparecerem corretos no console
setlocal enabledelayedexpansion
REM Isola variaveis (set/exit) e ativa "!var!" para ler valores definidos dentro de blocos if/else

set "modo=%~1"
REM Le o primeiro parametro recebido (ex.: /dev, /all, /help)
if "%modo%"=="" set "modo=/upgrade"
REM Sem parametro, mantem o comportamento antigo do script: so atualiza os apps

if /I "%modo%"=="/h" goto :ajuda
if /I "%modo%"=="/help" goto :ajuda
REM Ajuda e tratada antes da elevacao para nao pedir senha de admin so para ler o uso

net session >nul 2>&1
REM "net session" so funciona se o processo estiver elevado; redireciona saida/erro para nao poluir o console
if %errorLevel% NEQ 0 (
    REM errorLevel != 0 significa que NAO estamos elevados
    echo Solicitando privilegios de administrador...
    set "args=%*"
    REM Guarda os parametros recebidos numa variavel (pode ficar vazia se nenhum foi passado)
    if defined args (
        powershell -Command "Start-Process -FilePath '%~f0' -ArgumentList '!args!' -Verb RunAs"
        REM Reabre este mesmo .bat (%~f0) elevado, repassando os parametros recebidos
    ) else (
        powershell -Command "Start-Process -FilePath '%~f0' -Verb RunAs"
        REM Sem parametros, nao passa -ArgumentList (vazio causa erro no Start-Process)
    )
    exit /b
    REM Encerra a instancia atual (nao elevada); a elevada continua em outra janela
)

pushd "%CD%"
CD /D "%~dp0"
REM Garante que o script roda a partir da sua propria pasta, mesmo aberto de outro lugar

WHERE choco >nul 2>&1
IF %ERRORLEVEL% NEQ 0 (
    echo ===============================================================================
    echo Voce nao tem o Chocolatey instalado. Instalando agora...
    echo ===============================================================================
    @"%SystemRoot%\System32\WindowsPowerShell\v1.0\powershell.exe" -NoProfile -InputFormat None -ExecutionPolicy Bypass -Command "[System.Net.ServicePointManager]::SecurityProtocol = 3072; iex ((New-Object System.Net.WebClient).DownloadString('https://chocolatey.org/install.ps1'))"
    SET "PATH=%PATH%;%ALLUSERSPROFILE%\chocolatey\bin"
    REM Atualiza o PATH desta mesma sessao para o "choco" ja ficar disponivel sem reabrir o cmd
    echo ===============================================================================
    echo Chocolatey instalado. Continuando com o modo "%modo%"...
    echo ===============================================================================
)

if /I "%modo%"=="/dev" goto :dev
if /I "%modo%"=="/info" goto :info
if /I "%modo%"=="/bd" goto :bd
if /I "%modo%"=="/nav" goto :nav
if /I "%modo%"=="/midia" goto :midia
if /I "%modo%"=="/office" goto :office
if /I "%modo%"=="/util" goto :util
if /I "%modo%"=="/jogos" goto :jogos
if /I "%modo%"=="/all" goto :all
if /I "%modo%"=="/upgrade" goto :upgrade
REM "/I" compara sem diferenciar maiusculas/minusculas

echo Parametro invalido: %modo%
call :ajuda
exit /b 1
REM Encerra com codigo de erro 1 (parametro invalido)

:dev
call :instalar_dev
goto :fim
REM "call" executa a sub-rotina e volta para ca depois do "exit /b" dela

:info
call :instalar_info
goto :fim

:bd
call :instalar_bd
goto :fim

:nav
call :instalar_nav
goto :fim

:midia
call :instalar_midia
goto :fim

:office
call :instalar_office
goto :fim

:util
call :instalar_util
goto :fim

:jogos
call :instalar_jogos
goto :fim

:all
call :instalar_dev
call :instalar_info
call :instalar_bd
call :instalar_nav
call :instalar_midia
call :instalar_office
call :instalar_util
call :instalar_jogos
goto :fim

:upgrade
call :instalar_upgrade
goto :fim

:instalar_dev
echo Instalando categoria Dev...
choco install jdk8 oraclejdk maven vscode jmeter -y
choco install intellijidea-ultimate -y
choco install openshift-cli jq minishift -y
choco install nodejs-lts nvm yarn -y
choco install dotnet visualstudio2019community -y
choco install jetbrains-rider -y
choco install microsoft-teams forticlientvpn vmware-horizon-client git git-fork docker-desktop robo3t studio3t postman soapui notepadplusplus drawio virtualbox -y
choco install awscli -y
exit /b
REM "exit /b" aqui sai so da sub-rotina, nao do script inteiro (por estar apos um "call")

:instalar_info
echo Instalando categoria Informatica...
choco install cpu-z hwmonitor crystaldiskinfo crystaldiskmark easybcd rufus yumi h2testw reflect-free speedtest -y
exit /b

:instalar_bd
echo Instalando categoria Banco de Dados...
choco install datagrip -y
choco install dbeaver mysql.workbench -y
exit /b

:instalar_nav
echo Instalando categoria Navegadores...
choco install googlechrome firefox -y
exit /b

:instalar_midia
echo Instalando categoria Midia...
choco install k-litecodecpackfull mkvtoolnix vlc kdenlive gimp obs-studio anyvideoconverter spotify scrcpy -y
exit /b

:instalar_office
echo Instalando categoria Escritorio...
choco install adobereader pdf24 libreoffice MailViewer -y
exit /b

:instalar_util
echo Instalando categoria Utilitarios...
choco install powertoys 7zip revo-uninstaller qbittorrent teracopy bleachbit ccleaner defraggler speccy recuva kvirc keepassxc jdownloader whatsapp discord telegram zoom imgburn veracrypt googledrive protonvpn comicrack renamer utorrent dupeguru treesizefree aegisub screentogif balabolka macrocreator spacedesk-server eartrumpet -y
exit /b

:instalar_jogos
echo Instalando categoria Jogos...
choco install steam msiafterburner lghub -y
exit /b

:instalar_upgrade
echo Atualizando todos os aplicativos via Chocolatey...
choco upgrade all -y
exit /b

:ajuda
echo ===============================================================================
echo Uso: chocoInstall.bat [modo]
echo ===============================================================================
echo   /dev      Instala ferramentas de desenvolvimento (JDK, IDEs, Docker, Git...)
echo   /info     Instala utilitarios de informatica (CPU-Z, CrystalDisk, Rufus...)
echo   /bd       Instala ferramentas de banco de dados (DataGrip, DBeaver...)
echo   /nav      Instala navegadores (Chrome, Firefox)
echo   /midia    Instala apps de midia (VLC, OBS, Spotify...)
echo   /office   Instala apps de escritorio (Adobe Reader, LibreOffice...)
echo   /util     Instala utilitarios gerais (7zip, PowerToys, WhatsApp...)
echo   /jogos    Instala apps de jogos (Steam, MSI Afterburner...)
echo   /all      Instala todas as categorias acima, em sequencia
echo   /upgrade  Atualiza todos os apps ja instalados via Chocolatey (padrao sem parametro)
echo   /help     Mostra esta ajuda (tambem aceita /h)
echo ===============================================================================
exit /b

:fim
REM Rotulo final apenas para os "goto :fim" convergirem aqui e o script terminar
echo ===============================================================================
echo Lista de programas instalados:
choco list
echo ===============================================================================
pause
