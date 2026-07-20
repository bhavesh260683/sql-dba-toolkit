/*
Purpose: Identify sessions consuming TempDB user-object and internal-object space.
Compatibility: SQL Server 2016+; Azure SQL Managed Instance.
Permissions: VIEW SERVER STATE or VIEW SERVER PERFORMANCE STATE on SQL Server 2022+.
Safety: Read-only. Run in TempDB.
*/
USE tempdb;
SET NOCOUNT ON;

SELECT TOP (50)
    ssu.session_id,
    es.login_name,
    es.host_name,
    es.program_name,
    CAST((ssu.user_objects_alloc_page_count - ssu.user_objects_dealloc_page_count) * 8.0 / 1024 AS decimal(18,2)) AS user_objects_mb,
    CAST((ssu.internal_objects_alloc_page_count - ssu.internal_objects_dealloc_page_count) * 8.0 / 1024 AS decimal(18,2)) AS internal_objects_mb,
    er.status,
    er.command,
    er.wait_type,
    txt.text AS current_batch
FROM sys.dm_db_session_space_usage AS ssu
INNER JOIN sys.dm_exec_sessions AS es
    ON es.session_id = ssu.session_id
LEFT JOIN sys.dm_exec_requests AS er
    ON er.session_id = ssu.session_id
OUTER APPLY sys.dm_exec_sql_text(er.sql_handle) AS txt
WHERE es.is_user_process = 1
  AND
  (
      ssu.user_objects_alloc_page_count > ssu.user_objects_dealloc_page_count
      OR ssu.internal_objects_alloc_page_count > ssu.internal_objects_dealloc_page_count
  )
ORDER BY
    (ssu.user_objects_alloc_page_count - ssu.user_objects_dealloc_page_count)
  + (ssu.internal_objects_alloc_page_count - ssu.internal_objects_dealloc_page_count) DESC;
