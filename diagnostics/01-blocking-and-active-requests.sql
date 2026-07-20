/*
Purpose: Find active requests, blockers, current waits, and open-transaction age.
Compatibility: SQL Server 2016+; Azure SQL Managed Instance.
Permissions: VIEW SERVER STATE (SQL Server 2019 and earlier) or
             VIEW SERVER PERFORMANCE STATE (SQL Server 2022+).
Safety: Read-only. Run from any database.
*/
SET NOCOUNT ON;

SELECT
    r.session_id,
    r.blocking_session_id,
    DB_NAME(r.database_id) AS database_name,
    s.login_name,
    s.host_name,
    s.program_name,
    r.status,
    r.command,
    r.start_time,
    DATEDIFF(SECOND, r.start_time, SYSDATETIME()) AS elapsed_seconds,
    r.wait_type,
    r.wait_time AS wait_time_ms,
    r.wait_resource,
    r.cpu_time AS cpu_time_ms,
    r.logical_reads,
    r.reads,
    r.writes,
    r.open_transaction_count,
    SUBSTRING
    (
        st.text,
        (r.statement_start_offset / 2) + 1,
        ((CASE r.statement_end_offset
            WHEN -1 THEN DATALENGTH(st.text)
            ELSE r.statement_end_offset
          END - r.statement_start_offset) / 2) + 1
    ) AS current_statement,
    st.text AS batch_text
FROM sys.dm_exec_requests AS r
INNER JOIN sys.dm_exec_sessions AS s
    ON s.session_id = r.session_id
OUTER APPLY sys.dm_exec_sql_text(r.sql_handle) AS st
WHERE r.session_id <> @@SPID
  AND s.is_user_process = 1
ORDER BY
    CASE WHEN r.blocking_session_id > 0 THEN 0 ELSE 1 END,
    r.start_time;
