# Troubleshooting

## Access is denied

Error:

```text
Operating system error 5 (Access is denied.)
```

Cause:

The SQL Server service account cannot write to the backup folder.

Find the account:

```sql
SELECT servicename, service_account
FROM sys.dm_server_services;
```

Grant `Modify` permission to the backup folder.

Example:

```cmd
icacls "C:\SQLBackups" /grant "NT SERVICE\MSSQL$SQLEXPRESS:(OI)(CI)M" /T
```

## Path not found

Error:

```text
Operating system error 3
The system cannot find the path specified.
```

Check:

- `BACKUPROOT` in `config.bat`
- whether the daily folder was created
- whether the Windows account running the BAT file can create folders

## SQL Server Express compression error

Error:

```text
BACKUP DATABASE WITH COMPRESSION is not supported on Express Edition
```

This project does not enable compression by default.

If you added `COMPRESSION`, remove it.

## xp_cmdshell is disabled

Error:

```text
SQL Server blocked access to procedure 'xp_cmdshell'
```

This project does not require `xp_cmdshell`.

Folder creation is handled by the BAT file.

## sqlcmd is not recognized

Error:

```text
'sqlcmd' is not recognized as an internal or external command
```

Install Microsoft SQL Server command-line utilities or add `sqlcmd.exe` to `PATH`.

Test:

```cmd
sqlcmd -?
```

## Login failed

Windows authentication:

- verify the scheduled task account
- verify SQL Server login permissions

SQL authentication:

- verify `AUTH_MODE=SQL`
- verify `SQLUSER`
- verify `SQLPASSWORD`

## Backup succeeds, verification fails

Possible causes:

- corrupt backup file
- storage problem
- antivirus interference
- incomplete write
- insufficient disk space

Run manually:

```sql
RESTORE VERIFYONLY
FROM DISK = 'C:\SQLBackups\YYYY-MM-DD\DatabaseName.bak'
WITH CHECKSUM;
```

## Task Scheduler shows success but no backup exists

Check:

- task history
- the log file
- `Start in`
- user permissions
- whether `config.bat` exists
