@echo off
setlocal EnableExtensions EnableDelayedExpansion

set "SCRIPTROOT=%~dp0"
set "CONFIGFILE=%SCRIPTROOT%config.bat"

if not exist "%CONFIGFILE%" (
    echo ERROR: Missing config file:
    echo %CONFIGFILE%
    echo.
    echo Copy config.example.bat to config.bat and edit it.
    exit /b 1
)

call "%CONFIGFILE%"

if not defined SQLSERVER (
    echo ERROR: SQLSERVER is not configured.
    exit /b 1
)

if not defined BACKUPROOT (
    echo ERROR: BACKUPROOT is not configured.
    exit /b 1
)

if not exist "%BACKUPROOT%" mkdir "%BACKUPROOT%"

for /f %%i in ('powershell -NoProfile -Command "Get-Date -Format yyyyMMdd"') do set "LOGDATE=%%i"
for /f %%i in ('powershell -NoProfile -Command "Get-Date -Format yyyy-MM-dd"') do set "TODAY=%%i"

set "TODAYFOLDER=%BACKUPROOT%\%TODAY%"
set "LOGFILE=%BACKUPROOT%\backup_%LOGDATE%.log"

if not exist "%TODAYFOLDER%" mkdir "%TODAYFOLDER%"

if not exist "%TODAYFOLDER%" (
    echo ERROR: Cannot create daily backup folder: %TODAYFOLDER%
    exit /b 1
)

if "%ENABLE_CONSOLE_COLORS%"=="1" (
    call :PrintInfo "Starting SQL Server backup..."
) else (
    echo Starting SQL Server backup...
)

>>"%LOGFILE%" echo ============================================================
>>"%LOGFILE%" echo START: %date% %time%
>>"%LOGFILE%" echo Server: %SQLSERVER%
>>"%LOGFILE%" echo Backup root: %BACKUPROOT%
>>"%LOGFILE%" echo Daily folder: %TODAYFOLDER%
>>"%LOGFILE%" echo.

set "AUTHARGS=-E"
if /I "%AUTH_MODE%"=="SQL" (
    if not defined SQLUSER (
        echo ERROR: SQLUSER is missing.
        exit /b 1
    )
    if not defined SQLPASSWORD (
        echo ERROR: SQLPASSWORD is missing.
        exit /b 1
    )
    set "AUTHARGS=-U "%SQLUSER%" -P "%SQLPASSWORD%""
)

sqlcmd ^
    -S "%SQLSERVER%" ^
    !AUTHARGS! ^
    -b ^
    -v BackupRoot="%BACKUPROOT%" ^
       IncludeDatabases="%INCLUDE_DATABASES%" ^
       ExcludeDatabases="%EXCLUDE_DATABASES%" ^
       ExcludePrefixes="%EXCLUDE_PREFIXES%" ^
       ExcludeSuffixes="%EXCLUDE_SUFFIXES%" ^
    -i "%SCRIPTROOT%backup_all.sql" ^
    >>"%LOGFILE%" 2>&1

set "BACKUP_EXIT=%ERRORLEVEL%"

if not "%BACKUP_EXIT%"=="0" (
    >>"%LOGFILE%" echo.
    >>"%LOGFILE%" echo BACKUP FAILED: %date% %time%
    if "%ENABLE_CONSOLE_COLORS%"=="1" (
        call :PrintError "Backup failed. Check the log: %LOGFILE%"
    ) else (
        echo Backup failed. Check the log: %LOGFILE%
    )
    exit /b %BACKUP_EXIT%
)

>>"%LOGFILE%" echo.
>>"%LOGFILE%" echo BACKUP SUCCESS: %date% %time%

powershell.exe ^
    -NoProfile ^
    -ExecutionPolicy Bypass ^
    -File "%SCRIPTROOT%cleanup_sql_backups.ps1" ^
    -BackupRoot "%BACKUPROOT%" ^
    -DaysToKeepBackups "%DAYS_TO_KEEP_BACKUPS%" ^
    -DaysToKeepLogs "%DAYS_TO_KEEP_LOGS%" ^
    >>"%LOGFILE%" 2>&1

set "CLEANUP_EXIT=%ERRORLEVEL%"

if not "%CLEANUP_EXIT%"=="0" (
    >>"%LOGFILE%" echo CLEANUP FAILED: %date% %time%
    if "%ENABLE_CONSOLE_COLORS%"=="1" (
        call :PrintError "Backup succeeded, but cleanup failed."
    ) else (
        echo Backup succeeded, but cleanup failed.
    )
    exit /b %CLEANUP_EXIT%
)

>>"%LOGFILE%" echo FINISHED: %date% %time%
>>"%LOGFILE%" echo.

if "%ENABLE_CONSOLE_COLORS%"=="1" (
    call :PrintSuccess "Backup completed successfully."
) else (
    echo Backup completed successfully.
)

endlocal
exit /b 0

:PrintInfo
powershell -NoProfile -Command "Write-Host %~1 -ForegroundColor Cyan"
exit /b 0

:PrintSuccess
powershell -NoProfile -Command "Write-Host %~1 -ForegroundColor Green"
exit /b 0

:PrintError
powershell -NoProfile -Command "Write-Host %~1 -ForegroundColor Red"
exit /b 0
