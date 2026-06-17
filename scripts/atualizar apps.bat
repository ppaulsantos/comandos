@echo off
REM Nao exibir cada comando antes de executar (saida mais limpa)
setlocal enabledelayedexpansion
REM Isola variaveis (set/exit) e ativa "!var!" para ler valores definidos dentro de blocos if/else

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

set "modo=%~1"
REM Le o primeiro parametro recebido (ex.: /winget, /choco, /all)
if "%modo%"=="" set "modo=/all"
REM Se nenhum parametro foi passado, assume /all (winget + choco)

if /I "%modo%"=="/winget" goto :winget
REM /I = comparacao sem diferenciar maiusculas/minusculas
if /I "%modo%"=="/choco" goto :choco
if /I "%modo%"=="/all" goto :all

echo Parametro invalido: %modo%
REM Nenhum dos modos validos bateu; avisa o usuario e mostra o uso correto
echo Uso: "atualizar apps.bat" [/winget ^| /choco ^| /all]
exit /b 1
REM Encerra com codigo de erro 1 (parametro invalido)

:winget
call :atualizar_winget
REM "call" executa a sub-rotina e volta para ca depois do "exit /b" dela
goto :fim

:choco
call :atualizar_choco
goto :fim

:all
call :atualizar_winget
call :atualizar_choco
goto :fim

:atualizar_winget
echo Atualizando todos os aplicativos via winget...
winget upgrade --all --include-unknown --accept-source-agreements --accept-package-agreements
echo.
exit /b
REM "exit /b" aqui sai so da sub-rotina, nao do script inteiro (por estar apos um "call")

:atualizar_choco
echo Atualizando todos os aplicativos via Chocolatey...
choco upgrade all -y
exit /b

:fim
REM Rotulo final apenas para os "goto :fim" convergirem aqui e o script terminar
