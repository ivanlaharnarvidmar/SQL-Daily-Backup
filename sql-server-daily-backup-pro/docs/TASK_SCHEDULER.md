# Windows Task Scheduler

## Create the task

Open:

```text
Task Scheduler
```

Choose:

```text
Create Task
```

## General

- Name: `SQL Server Daily Backup`
- Select: `Run whether user is logged on or not`
- Select: `Run with highest privileges`

Use a Windows account that can:

- execute the BAT file
- connect to SQL Server
- read the scripts folder

## Trigger

Example:

```text
Daily at 02:00
```

## Action

Program/script:

```text
C:\SQLBackups\scripts\backup_all.bat
```

Start in:

```text
C:\SQLBackups\scripts
```

## Conditions

On servers, consider disabling:

```text
Start the task only if the computer is on AC power
```

## Settings

Enable:

- Allow task to be run on demand
- Run task as soon as possible after a scheduled start is missed
- Stop the task if it runs longer than an appropriate maximum time

## Test

Right-click the task and select:

```text
Run
```

Then check:

```text
C:\SQLBackups\backup_YYYYMMDD.log
```
