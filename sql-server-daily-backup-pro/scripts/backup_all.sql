/*
SQL Server Daily Backup
Public GitHub edition

SQLCMD variables:
$(BackupRoot)
$(IncludeDatabases)
$(ExcludeDatabases)
$(ExcludePrefixes)
$(ExcludeSuffixes)
*/

SET NOCOUNT ON;
SET XACT_ABORT ON;

DECLARE @BackupRoot NVARCHAR(500) = N'$(BackupRoot)';
DECLARE @BackupFolder NVARCHAR(500);
DECLARE @IncludeDatabases NVARCHAR(MAX) = N'$(IncludeDatabases)';
DECLARE @ExcludeDatabases NVARCHAR(MAX) = N'$(ExcludeDatabases)';
DECLARE @ExcludePrefixes NVARCHAR(MAX) = N'$(ExcludePrefixes)';
DECLARE @ExcludeSuffixes NVARCHAR(MAX) = N'$(ExcludeSuffixes)';
DECLARE @DBName SYSNAME;
DECLARE @FileName NVARCHAR(1000);
DECLARE @SQL NVARCHAR(MAX);
DECLARE @ErrorMessage NVARCHAR(2048);

SET @BackupFolder =
    @BackupRoot + N'\' + CONVERT(VARCHAR(10), GETDATE(), 120);

DECLARE @Included TABLE (Name SYSNAME PRIMARY KEY);
DECLARE @Excluded TABLE (Name SYSNAME PRIMARY KEY);
DECLARE @ExcludedPrefixes TABLE (Value NVARCHAR(255));
DECLARE @ExcludedSuffixes TABLE (Value NVARCHAR(255));

IF NULLIF(LTRIM(RTRIM(@IncludeDatabases)), N'') IS NOT NULL
BEGIN
    INSERT INTO @Included(Name)
    SELECT DISTINCT LTRIM(RTRIM(value))
    FROM STRING_SPLIT(@IncludeDatabases, N',')
    WHERE LTRIM(RTRIM(value)) <> N'';
END;

IF NULLIF(LTRIM(RTRIM(@ExcludeDatabases)), N'') IS NOT NULL
BEGIN
    INSERT INTO @Excluded(Name)
    SELECT DISTINCT LTRIM(RTRIM(value))
    FROM STRING_SPLIT(@ExcludeDatabases, N',')
    WHERE LTRIM(RTRIM(value)) <> N'';
END;

IF NULLIF(LTRIM(RTRIM(@ExcludePrefixes)), N'') IS NOT NULL
BEGIN
    INSERT INTO @ExcludedPrefixes(Value)
    SELECT DISTINCT LTRIM(RTRIM(value))
    FROM STRING_SPLIT(@ExcludePrefixes, N',')
    WHERE LTRIM(RTRIM(value)) <> N'';
END;

IF NULLIF(LTRIM(RTRIM(@ExcludeSuffixes)), N'') IS NOT NULL
BEGIN
    INSERT INTO @ExcludedSuffixes(Value)
    SELECT DISTINCT LTRIM(RTRIM(value))
    FROM STRING_SPLIT(@ExcludeSuffixes, N',')
    WHERE LTRIM(RTRIM(value)) <> N'';
END;

DECLARE db_cursor CURSOR LOCAL FAST_FORWARD FOR
SELECT d.name
FROM sys.databases AS d
WHERE d.database_id > 4
  AND d.state_desc = N'ONLINE'
  AND d.source_database_id IS NULL
  AND (
        NOT EXISTS (SELECT 1 FROM @Included)
        OR EXISTS (SELECT 1 FROM @Included i WHERE i.Name = d.name)
      )
  AND NOT EXISTS (SELECT 1 FROM @Excluded e WHERE e.Name = d.name)
  AND NOT EXISTS (
        SELECT 1
        FROM @ExcludedPrefixes p
        WHERE d.name LIKE p.Value + N'%'
      )
  AND NOT EXISTS (
        SELECT 1
        FROM @ExcludedSuffixes s
        WHERE d.name LIKE N'%' + s.Value
      )
ORDER BY d.name;

OPEN db_cursor;
FETCH NEXT FROM db_cursor INTO @DBName;

WHILE @@FETCH_STATUS = 0
BEGIN
    SET @FileName = @BackupFolder + N'\' + @DBName + N'.bak';

    PRINT N'----------------------------------------';
    PRINT N'BACKUP DATABASE: ' + @DBName;
    PRINT N'FILE: ' + @FileName;

    BEGIN TRY
        SET @SQL =
            N'BACKUP DATABASE [' +
            REPLACE(@DBName, N']', N']]') +
            N']
              TO DISK = N''' +
            REPLACE(@FileName, N'''', N'''''') +
            N'''
              WITH INIT, CHECKSUM, STATS = 10;';

        EXEC sys.sp_executesql @SQL;

        PRINT N'VERIFY BACKUP: ' + @DBName;

        SET @SQL =
            N'RESTORE VERIFYONLY
              FROM DISK = N''' +
            REPLACE(@FileName, N'''', N'''''') +
            N'''
              WITH CHECKSUM;';

        EXEC sys.sp_executesql @SQL;

        PRINT N'SUCCESS: ' + @DBName;

    END TRY
    BEGIN CATCH
        SET @ErrorMessage = ERROR_MESSAGE();

        PRINT N'FAILED: ' + @DBName;
        PRINT @ErrorMessage;

        CLOSE db_cursor;
        DEALLOCATE db_cursor;

        THROW;
    END CATCH;

    FETCH NEXT FROM db_cursor INTO @DBName;
END;

CLOSE db_cursor;
DEALLOCATE db_cursor;

PRINT N'';
PRINT N'========================================';
PRINT N'Backup vseh baz je uspesno zakljucen.';
PRINT N'========================================';
