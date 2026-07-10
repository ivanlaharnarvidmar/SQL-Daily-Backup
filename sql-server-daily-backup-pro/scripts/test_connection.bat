@echo off
setlocal EnableExtensions EnableDelayedExpansion

set "SCRIPTROOT=%~dp0"
set "CONFIGFILE=%SCRIPTROOT%config.bat"

if not exist "%CONFIGFILE%" (
    echo ERROR: Missing config.bat
    exit /b 1
)

call "%CONFIGFILE%"

set "AUTHARGS=-E"
if /I "%AUTH_MODE%"=="SQL" (
    set "AUTHARGS=-U "%SQLUSER%" -P "%SQLPASSWORD%""
)

echo Testing connection to %SQLSERVER%...
sqlcmd -S "%SQLSERVER%" !AUTHARGS! -b -Q "SELECT @@SERVERNAME AS ServerName, SERVERPROPERTY('Edition') AS Edition, SERVERPROPERTY('ProductVersion') AS ProductVersion;"

if %ERRORLEVEL% NEQ 0 (
    echo.
    echo Connection test failed.
    exit /b 1
)

echo.
echo Connection test successful.
exit /b 0
