
@REM @REM Para debug(desenvolvimento)
@REM @REM @echo off
@REM @REM cd /d "%~dp0"

@REM @REM echo [1/4] Building...
@REM @REM flutter build windows --debug

@REM @REM echo [2/4] Copiando DLLs...
@REM @REM copy "build\windows\x64\install\*.dll" "build\windows\x64\runner\Debug\" /Y >nul
@REM @REM xcopy "build\windows\x64\install\data" "build\windows\x64\runner\Debug\data\" /E /Y /I /Q >nul

@REM @REM echo [3/4] Copiando SumatraPDF...
@REM @REM copy "C:\SumatraPDF\SumatraPDF-3.5.2-64.exe" "build\windows\x64\runner\Debug\SumatraPDF.exe" /Y >nul

@REM @REM echo [4/4] Iniciando app...
@REM @REM cd build\windows\x64\runner\Debug
@REM @REM gestao_bar_pos.exe


@REM @REM Para release(produção)
@REM @echo off
@REM cd /d "%~dp0"

@REM echo [1/5] Building Release...
@REM flutter build windows --release

@REM echo [2/5] Copiando DLLs para Release...
@REM copy "build\windows\x64\install\*.dll" "build\windows\x64\runner\Release\" /Y >nul
@REM xcopy "build\windows\x64\install\data" "build\windows\x64\runner\Release\data\" /E /Y /I /Q >nul

@REM echo [3/5] Copiando SumatraPDF para Release...
@REM copy "C:\SumatraPDF\SumatraPDF-3.5.2-64.exe" "build\windows\x64\runner\Release\SumatraPDF.exe" /Y >nul

@REM echo [4/5] Gerando instalador...
@REM "C:\Program Files (x86)\Inno Setup 6\ISCC.exe" instalador.iss

@REM echo [5/5] Concluido!
@REM echo Instalador gerado em: installer_output\Gestor365_Setup.exe
@REM pause


cd "E:\Gestor 365 2.0\gestao_bar_pos"
echo [INFO] Iniciando aplicativo no Windows...
start "FLUTTER WINDOWS" cmd /k "flutter run -d windows -v "