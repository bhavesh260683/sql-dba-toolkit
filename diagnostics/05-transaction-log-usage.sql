/*
Purpose: Show transaction log utilization and the reason log space cannot be reused.
Compatibility: SQL Server 2016 SP2+; Azure SQL Managed Instance.
Permissions: VIEW SERVER STATE or VIEW SERVER PERFORMANCE STATE on SQL Server 2022+.
Safety: Read-only. Run from master.
*/
SET NOCOUNT ON;

SELECT
    d.name AS database_name,
    d.recovery_model_desc,
    d.log_reuse_wait_desc,
    CAST(ls.total_vlf_size_mb AS decimal(18,2)) AS total_log_mb,
    CAST(ls.active_log_size_mb AS decimal(18,2)) AS active_log_mb,
    CAST(ls.active_log_size_mb * 100.0 / NULLIF(ls.total_vlf_size_mb, 0) AS decimal(6,2)) AS active_percent,
    ls.total_vlf_count,
    ls.active_vlf_count,
    ls.log_backup_time AS last_log_backup_time,
    ls.log_truncation_holdup_reason
FROM sys.databases AS d
CROSS APPLY sys.dm_db_log_stats(d.database_id) AS ls
WHERE d.state_desc = N'ONLINE'
  AND d.source_database_id IS NULL
ORDER BY active_percent DESC;
