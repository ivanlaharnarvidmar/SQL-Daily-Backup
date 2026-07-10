@echo off

REM ============================================================
REM SQL Server Daily Backup - local configuration
REM Copy this file to config.bat and edit the values.
REM config.bat is ignored by Git.
REM ============================================================

set "SQLSERVER=localhost\SQLEXPRESS"
set "BACKUPROOT=C:\SQLBackups"

REM WINDOWS or SQL
set "AUTH_MODE=WINDOWS"

REM Used only when AUTH_MODE=SQL
set "SQLUSER="
set "SQLPASSWORD="

REM Retention
set "DAYS_TO_KEEP_BACKUPS=30"
set "DAYS_TO_KEEP_LOGS=90"

REM Database filters
REM Comma-separated values. Leave INCLUDE_DATABASES empty for all eligible user databases.
set "INCLUDE_DATABASES="
set "EXCLUDE_DATABASES=ReportServer,ReportServerTempDB"
set "EXCLUDE_PREFIXES=XLOG"
set "EXCLUDE_SUFFIXES=_TEST,_CORRUPTED"

REM Output options: 1 = enabled, 0 = disabled
set "ENABLE_CONSOLE_COLORS=1"
