/*
Purpose: Show the most recent full, differential, and log backup for each online database.
Compatibility: SQL Server 2016+; Azure SQL Managed Instance.
Permissions: Access to msdb backup history and sys.databases.
Safety: Read-only. Backup history reflects msdb retention.
*/
SET NOCOUNT ON;

WITH latest_backup AS
(
    SELECT
        bs.database_name,
        bs.type,
        bs.backup_start_date,
        bs.backup_finish_date,
        bs.backup_size,
        bs.compressed_backup_size,
        ROW_NUMBER() OVER
        (
            PARTITION BY bs.database_name, bs.type
            ORDER BY bs.backup_finish_date DESC
        ) AS row_num
    FROM msdb.dbo.backupset AS bs
    WHERE bs.is_copy_only = 0
)
SELECT
    d.name AS database_name,
    d.recovery_model_desc,
    MAX(CASE WHEN lb.type = 'D' AND lb.row_num = 1 THEN lb.backup_finish_date END) AS last_full_backup,
    MAX(CASE WHEN lb.type = 'I' AND lb.row_num = 1 THEN lb.backup_finish_date END) AS last_differential_backup,
    MAX(CASE WHEN lb.type = 'L' AND lb.row_num = 1 THEN lb.backup_finish_date END) AS last_log_backup,
    MAX(CASE WHEN lb.type = 'D' AND lb.row_num = 1
             THEN CAST(lb.compressed_backup_size / 1073741824.0 AS decimal(18,2)) END) AS last_full_compressed_gb,
    MAX(CASE WHEN lb.type = 'D' AND lb.row_num = 1
             THEN DATEDIFF(SECOND, lb.backup_start_date, lb.backup_finish_date) END) AS last_full_duration_seconds
FROM sys.databases AS d
LEFT JOIN latest_backup AS lb
    ON lb.database_name = d.name
   AND lb.row_num = 1
WHERE d.state_desc = N'ONLINE'
GROUP BY d.name, d.recovery_model_desc
ORDER BY d.name;
