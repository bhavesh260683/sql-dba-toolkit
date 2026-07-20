/*
Purpose: Find failed SQL Server Agent job executions from the last seven days.
Compatibility: SQL Server 2016+; Azure SQL Managed Instance with SQL Agent.
Permissions: Membership in an appropriate msdb SQLAgent role or sysadmin.
Safety: Read-only.
*/
SET NOCOUNT ON;

DECLARE @Since datetime2(0) = DATEADD(DAY, -7, SYSDATETIME());

SELECT TOP (100)
    j.name AS job_name,
    h.step_id,
    h.step_name,
    msdb.dbo.agent_datetime(h.run_date, h.run_time) AS failure_time,
    h.run_duration,
    h.sql_severity,
    h.sql_message_id,
    h.message
FROM msdb.dbo.sysjobhistory AS h
INNER JOIN msdb.dbo.sysjobs AS j
    ON j.job_id = h.job_id
WHERE h.run_status = 0
  AND msdb.dbo.agent_datetime(h.run_date, h.run_time) >= @Since
ORDER BY failure_time DESC;
