@echo off
title Gestor 365 - Modo Desenvolvimento
cd /d "E:\Gestor 365 2.0\gestao_bar_pos"

echo ===================================================
echo [1/4] Compilando aplicativo (Modo Debug)...
echo ===================================================
call flutter build windows --debug --no-pub

echo.
echo ===================================================
echo [2/4] Integrando e copiando dependencias (DLLs)...
echo ===================================================
:: Garante que a pasta existe antes de copiar
if not exist "build\windows\x64\runner\Debug" mkdir "build\windows\x64\runner\Debug"

:: Copia todas as DLLs e a pasta de dados geradas pelo processo de install
xcopy "build\windows\x64\install\*.dll" "build\windows\x64\runner\Debug\" /Y /Q
xcopy "build\windows\x64\install\data" "build\windows\x64\runner\Debug\data\" /E /Y /I /Q >nul

echo.
echo ===================================================
echo [3/4] Copiando SumatraPDF...
echo ===================================================
if exist "C:\SumatraPDF\SumatraPDF-3.5.2-64.exe" (
    copy "C:\SumatraPDF\SumatraPDF-3.5.2-64.exe" "build\windows\x64\runner\Debug\SumatraPDF.exe" /Y >nul
    echo [OK] SumatraPDF copiado com sucesso.
) else (
    echo [AVISO] SumatraPDF nao encontrado em C:\SumatraPDF\
)

echo.
echo ===================================================
echo [4/4] Executando o aplicativo...
echo ===================================================
cd "build\windows\x64\runner\Debug"
start gestao_bar_pos.exe
echo [SUCESSO] Aplicativo iniciado fora do terminal do Flutter.
exit