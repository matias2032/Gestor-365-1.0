@echo off
title Gestor 365 - Gerar Versao de Producao
cd /d "E:\Gestor 365 2.0\gestao_bar_pos"

echo ===================================================
echo [1/5] Compilando em Modo Release...
echo ===================================================
call flutter build windows --release

echo.
echo ===================================================
echo [2/5] Copiando DLLs e dependencias para Release...
echo ===================================================
if not exist "build\windows\x64\runner\Release" mkdir "build\windows\x64\runner\Release"
xcopy "build\windows\x64\install\*.dll" "build\windows\x64\runner\Release\" /Y /Q
xcopy "build\windows\x64\install\data" "build\windows\x64\runner\Release\data\" /E /Y /I /Q >nul

echo.
echo ===================================================
echo [3/5] Copiando SumatraPDF para Release...
echo ===================================================
if exist "C:\SumatraPDF\SumatraPDF-3.5.2-64.exe" (
    copy "C:\SumatraPDF\SumatraPDF-3.5.2-64.exe" "build\windows\x64\runner\Release\SumatraPDF.exe" /Y >nul
)

echo.
echo ===================================================
echo [4/5] Gerando instalador executavel (Inno Setup)...
echo ===================================================
if exist "C:\Program Files (x86)\Inno Setup 6\ISCC.exe" (
    "C:\Program Files (x86)\Inno Setup 6\ISCC.exe" instalador.iss
) else (
    echo [ERRO] Inno Setup nao encontrado no caminho padrao.
)

echo.
echo ===================================================
echo [5/5] Concluido!
echo ===================================================
echo Se o script do Inno Setup estiver correto, o instalador esta em:
echo installer_output\Gestor365_Setup.exe
echo.
pause