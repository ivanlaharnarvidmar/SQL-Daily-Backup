<p align="center">
  <img src="assets/logosql.png" width="180" alt="SQL Server Daily Backup">
</p>

<h1 align="center">
SQL Server Daily Backup
</h1>

<p align="center">
Automatic daily backup solution for Microsoft SQL Server and SQL Server Express.
</p>

<p align="center">

![License](https://img.shields.io/github/license/ivanlaharnarvidmar/SQL-Daily-Backup)
![Release](https://img.shields.io/github/v/release/ivanlaharnarvidmar/SQL-Daily-Backup)
![Stars](https://img.shields.io/github/stars/ivanlaharnarvidmar/SQL-Daily-Backup)
![Forks](https://img.shields.io/github/forks/ivanlaharnarvidmar/SQL-Daily-Backup)
![Issues](https://img.shields.io/github/issues/ivanlaharnarvidmar/SQL-Daily-Backup)
![Last Commit](https://img.shields.io/github/last-commit/ivanlaharnarvidmar/SQL-Daily-Backup)

</p>

# SQL Server Daily Backup

A lightweight, Windows-friendly backup toolkit for Microsoft SQL Server and SQL Server Express.

It uses:

- `sqlcmd`
- T-SQL
- PowerShell
- Windows Task Scheduler

No SQL Server Agent and no `xp_cmdshell` are required.

## Features

- Full backup of all online user databases
- Works with SQL Server Express
- One backup folder per day
- `CHECKSUM` during backup
- `RESTORE VERIFYONLY` after each backup
- Daily log files
- Configurable retention
- Optional include/exclude filters
- Windows or SQL authentication
- Optional console colors
- Ready for Windows Task Scheduler
- GitHub Actions validation
- No hard-coded company, server, or customer data

## Repository structure

```text
sql-server-daily-backup/
├── .github/
│   └── workflows/
│       └── validate.yml
├── docs/
│   ├── TASK_SCHEDULER.md
│   └── TROUBLESHOOTING.md
├── scripts/
│   ├── backup_all.bat
│   ├── backup_all.sql
│   ├── cleanup_sql_backups.ps1
│   ├── config.example.bat
│   └── test_connection.bat
├── .gitignore
├── CHANGELOG.md
├── LICENSE
└── README.md
```

## Quick start

### 1. Create a backup folder

Example:

```text
C:\SQLBackups
```

### 2. Copy the scripts

Copy the `scripts` folder into:

```text
C:\SQLBackups\scripts
```

### 3. Create your local configuration

Copy:

```text
config.example.bat
```

to:

```text
config.bat
```

Then edit `config.bat`.

Example:

```bat
set "SQLSERVER=localhost\SQLEXPRESS"
set "BACKUPROOT=C:\SQLBackups"
set "AUTH_MODE=WINDOWS"
```

`config.bat` is ignored by Git, so local credentials and server details are not committed.

### 4. Test the SQL connection

Run:

```text
test_connection.bat
```

### 5. Run a manual backup

Run:

```text
backup_all.bat
```

After a successful backup you should see:

```text
C:\SQLBackups\YYYY-MM-DD\
```

with `.bak` files inside.

## Configuration

All configuration is stored in:

```text
scripts\config.bat
```

Main options:

```bat
set "SQLSERVER=localhost\SQLEXPRESS"
set "BACKUPROOT=C:\SQLBackups"

set "AUTH_MODE=WINDOWS"
set "SQLUSER="
set "SQLPASSWORD="

set "DAYS_TO_KEEP_BACKUPS=30"
set "DAYS_TO_KEEP_LOGS=90"

set "INCLUDE_DATABASES="
set "EXCLUDE_DATABASES=ReportServer,ReportServerTempDB"

set "EXCLUDE_PREFIXES=XLOG"
set "EXCLUDE_SUFFIXES=_TEST,_CORRUPTED"

set "ENABLE_CONSOLE_COLORS=1"
```

### Include only selected databases

```bat
set "INCLUDE_DATABASES=Database1,Database2,Database3"
```

Leave it empty to include all eligible user databases.

### Exclude selected databases

```bat
set "EXCLUDE_DATABASES=ReportServer,ReportServerTempDB"
```

### Exclude by prefix or suffix

```bat
set "EXCLUDE_PREFIXES=XLOG,TEMP"
set "EXCLUDE_SUFFIXES=_TEST,_CORRUPTED"
```

## Authentication

### Windows authentication

```bat
set "AUTH_MODE=WINDOWS"
```

The Windows account running the BAT file must have permission to connect to SQL Server and perform backups.

### SQL authentication

```bat
set "AUTH_MODE=SQL"
set "SQLUSER=backup_user"
set "SQLPASSWORD=change_me"
```

Avoid committing `config.bat`.

## SQL Server service account permissions

The SQL Server service account must have write permission on the backup folder.

Find the service account:

```sql
SELECT servicename, service_account
FROM sys.dm_server_services;
```

Then grant `Modify` permission to that account.

Example:

```cmd
icacls "C:\SQLBackups" /grant "NT SERVICE\MSSQL$SQLEXPRESS:(OI)(CI)M" /T
```

Run the command as Administrator.

## SQL Server Express

SQL Server Express does not support native backup compression in some versions/editions.

This project does not use `COMPRESSION` by default.

## Scheduling

See:

```text
docs\TASK_SCHEDULER.md
```

## Troubleshooting

See:

```text
docs\TROUBLESHOOTING.md
```

## Backup strategy

A backup on the same physical disk as the database is not enough.

Use the 3-2-1 rule:

- 3 copies of your data
- 2 different storage media
- 1 copy off-site

For example:

- local SQL backup
- NAS copy
- cloud or off-site copy

## Restore testing

`RESTORE VERIFYONLY` is useful, but it is not a substitute for a real restore test.

At least once per month:

1. Restore one backup to a test database.
2. Run:

```sql
DBCC CHECKDB('TEST_DATABASE');
```

3. Confirm that the application can read the restored data.

## License

MIT
