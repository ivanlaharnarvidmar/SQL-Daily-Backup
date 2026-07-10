param(
    [Parameter(Mandatory = $true)]
    [string]$BackupRoot,

    [int]$DaysToKeepBackups = 30,
    [int]$DaysToKeepLogs = 90
)

$ErrorActionPreference = "Stop"

Write-Output "Cleanup started: $(Get-Date -Format o)"
Write-Output "Backup root: $BackupRoot"
Write-Output "Backup retention: $DaysToKeepBackups days"
Write-Output "Log retention: $DaysToKeepLogs days"

if (!(Test-Path -LiteralPath $BackupRoot)) {
    Write-Output "Backup root does not exist: $BackupRoot"
    exit 0
}

$BackupLimit = (Get-Date).AddDays(-$DaysToKeepBackups)
$LogLimit = (Get-Date).AddDays(-$DaysToKeepLogs)

Get-ChildItem -LiteralPath $BackupRoot -Directory |
    Where-Object {
        $_.Name -match '^\d{4}-\d{2}-\d{2}$' -and
        $_.LastWriteTime -lt $BackupLimit
    } |
    ForEach-Object {
        Write-Output "Deleting old backup folder: $($_.FullName)"
        Remove-Item -LiteralPath $_.FullName -Recurse -Force
    }

Get-ChildItem -LiteralPath $BackupRoot -File |
    Where-Object {
        $_.Name -like 'backup_*.log' -and
        $_.LastWriteTime -lt $LogLimit
    } |
    ForEach-Object {
        Write-Output "Deleting old log file: $($_.FullName)"
        Remove-Item -LiteralPath $_.FullName -Force
    }

Write-Output "Cleanup finished: $(Get-Date -Format o)"
exit 0
