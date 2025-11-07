@echo off
setlocal enabledelayedexpansion

REM ====================================================================
REM           GESTOR DE ARQUIVOS EM BATCH
REM ====================================================================
ECHO Iniciando o Gestor de Arquivos...
ECHO.

REM --- Definir Caminhos Base ---
REM Usamos "%~dp0" para definir o caminho base no mesmo diretorio do script.
SET "BASE_DIR=%~dp0GestorArquivos"
SET "DOC_DIR=%BASE_DIR%\Documentos"
SET "LOG_DIR=%BASE_DIR%\Logs"
SET "BAK_DIR=%BASE_DIR%\Backups"
SET "LOG_FILE=%LOG_DIR%\atividade.log"

REM --- Contadores para o Relatório Final ---
SET "PASTA_CRIADA_COUNT=0"
SET "ARQUIVO_CRIADO_COUNT=0"


REM --- 1. Criação de Diretórios ---
ECHO [TAREFA 1] Verificando e criando estrutura de diretorios...

REM Garante que a pasta de Log exista ANTES de qualquer operacao de log.
IF NOT EXIST "%LOG_DIR%" (
    MKDIR "%LOG_DIR%"
    IF ERRORLEVEL 1 (
        ECHO ERRO CRITICO: Nao foi possivel criar o diretorio de Log: %LOG_DIR%
        GOTO :ErroCritico
    )
    SET /A PASTA_CRIADA_COUNT+=1
    REM Log manual, pois a sub-rotina :LogOperation ainda nao pode ser usada
    ECHO %DATE% %TIME% - Criacao da pasta Logs - Sucesso >> "%LOG_FILE%"
)

REM Agora a sub-rotina de log pode ser usada com seguranca
CALL :LogOperation "Inicio da execucao do script" "Info"

REM Criacao das outras pastas
CALL :CriarPasta "%BASE_DIR%" "Base (GestorArquivos)"
CALL :CriarPasta "%DOC_DIR%" "Documentos"
CALL :CriarPasta "%BAK_DIR%" "Backups"

ECHO Estrutura de diretorios verificada.
ECHO.


REM --- 2. Criação e Manipulação de Arquivos ---
ECHO [TAREFA 2] Criando arquivos de exemplo...

REM Arquivo 1: relatorio.txt
(
    ECHO [RELATORIO CONFIDENCIAL]
    ECHO Data de geracao: %DATE%
    ECHO Responsavel: Sistema Automatico
    ECHO Status: Concluido
) > "%DOC_DIR%\relatorio.txt"
CALL :LogOperation "Criacao do arquivo relatorio.txt" "Sucesso"
SET /A ARQUIVO_CRIADO_COUNT+=1

REM Arquivo 2: dados.csv
(
    ECHO ID,Produto,Quantidade,Preco
    ECHO 1001,Mouse,50,75.50
    ECHO 1002,Teclado,30,120.00
    ECHO 1003,Monitor,15,899.90
) > "%DOC_DIR%\dados.csv"
CALL :LogOperation "Criacao do arquivo dados.csv" "Sucesso"
SET /A ARQUIVO_CRIADO_COUNT+=1

REM Arquivo 3: config.ini
(
    ECHO [Servidor]
    ECHO Host=192.168.1.100
    ECHO Porta=3306
    ECHO [Aplicacao]
    ECHO Versao=1.2.5
    ECHO Modo=Producao
) > "%DOC_DIR%\config.ini"
CALL :LogOperation "Criacao do arquivo config.ini" "Sucesso"
SET /A ARQUIVO_CRIADO_COUNT+=1

ECHO Arquivos de exemplo criados em %DOC_DIR%
ECHO.


REM --- 3. Registro de Atividade (Log) ---
ECHO [TAREFA 3] Operacoes estao sendo registradas em %LOG_FILE%
CALL :LogOperation "Fase de criacao de arquivos concluida" "Info"
ECHO.


REM --- 4. Simulação de Backup ---
ECHO [TAREFA 4] Iniciando simulacao de backup...

COPY "%DOC_DIR%\*.*" "%BAK_DIR%" /Y > NUL
IF ERRORLEVEL 1 (
    CALL :LogOperation "Backup dos arquivos de Documentos" "Falha"
) ELSE (
    CALL :LogOperation "Backup dos arquivos de Documentos" "Sucesso"
)

REM Salva a data e hora do backup para o relatorio e para o .bak
SET "BACKUP_TIMESTAMP=%DATE% %TIME%"
ECHO Backup realizado em: %BACKUP_TIMESTAMP% > "%BAK_DIR%\backup_completo.bak"
CALL :LogOperation "Criacao do arquivo backup_completo.bak" "Sucesso"
SET /A ARQUIVO_CRIADO_COUNT+=1

ECHO Backup concluido.
ECHO.


REM --- 5. Relatório Final ---
ECHO [TAREFA 5] Gerando relatorio final de execucao...
SET "RELATORIO_FILE=%BASE_DIR%\resumo_execucao.txt"

(
    ECHO RELATORIO DE EXECUCAO
    ECHO ----------------------
    ECHO.
    ECHO Total de arquivos criados nesta execucao: %ARQUIVO_CRIADO_COUNT%
    ECHO Total de pastas criadas nesta execucao: %PASTA_CRIADA_COUNT%
    ECHO.
    ECHO Data/Hora do ultimo backup: %BACKUP_TIMESTAMP%
    ECHO.
    ECHO Caminho do Log: %LOG_FILE%
) > "%RELATORIO_FILE%"

CALL :LogOperation "Geracao do relatorio final" "Sucesso"
SET /A ARQUIVO_CRIADO_COUNT+=1

ECHO Relatorio salvo em %RELATORIO_FILE%
ECHO.

ECHO ====================================================================
ECHO      SCRIPT CONCLUIDO COM SUCESSO!
ECHO ====================================================================
ECHO.

goto :Fim

REM ====================================================================
REM                     SUB-ROTINAS (FUNCOES)
REM ====================================================================

:CriarPasta
REM %1 = Caminho completo da pasta
REM %2 = Nome amigavel para o Log
IF NOT EXIST "%~1" (
    MKDIR "%~1"
    CALL :LogOperation "Criacao da pasta %~2" "Sucesso"
    SET /A PASTA_CRIADA_COUNT+=1
) ELSE (
    CALL :LogOperation "Verificacao da pasta %~2" "Ja existia"
)
GOTO :EOF


:LogOperation
REM %1 = Mensagem da Operacao
REM %2 = Resultado (Sucesso/Falha/Info)
REM Adiciona data e hora ao log.
ECHO %DATE% %TIME% - %~1 - %~2 >> "%LOG_FILE%"
GOTO :EOF


:ErroCritico
ECHO.
ECHO Ocorreu um erro critico e o script nao pode continuar.
ECHO Verifique as permissoes do diretorio.
CALL :LogOperation "Erro Critico" "FALHA GERAL"
ECHO.
PAUSE
GOTO :EOF


:Fim
endlocal
ECHO Pressione qualquer tecla para sair...
PAUSE > NUL