/*
Purpose: Find expensive statements currently represented in the plan cache.
Compatibility: SQL Server 2016+; Azure SQL Managed Instance.
Permissions: VIEW SERVER STATE or VIEW SERVER PERFORMANCE STATE on SQL Server 2022+.
Safety: Read-only. Cache data is cumulative and may be incomplete after eviction/restart.
*/
SET NOCOUNT ON;

DECLARE @TopRows int = 25;

SELECT TOP (@TopRows)
    DB_NAME(st.dbid) AS database_name,
    qs.execution_count,
    qs.last_execution_time,
    CAST(qs.total_worker_time / 1000.0 AS decimal(18,2)) AS total_cpu_ms,
    CAST(qs.total_worker_time / NULLIF(qs.execution_count, 0) / 1000.0 AS decimal(18,2)) AS avg_cpu_ms,
    qs.total_logical_reads,
    CAST(qs.total_logical_reads * 1.0 / NULLIF(qs.execution_count, 0) AS decimal(18,2)) AS avg_logical_reads,
    CAST(qs.total_elapsed_time / NULLIF(qs.execution_count, 0) / 1000.0 AS decimal(18,2)) AS avg_duration_ms,
    SUBSTRING
    (
        st.text,
        (qs.statement_start_offset / 2) + 1,
        ((CASE qs.statement_end_offset
            WHEN -1 THEN DATALENGTH(st.text)
            ELSE qs.statement_end_offset
          END - qs.statement_start_offset) / 2) + 1
    ) AS statement_text,
    qp.query_plan
FROM sys.dm_exec_query_stats AS qs
CROSS APPLY sys.dm_exec_sql_text(qs.sql_handle) AS st
OUTER APPLY sys.dm_exec_query_plan(qs.plan_handle) AS qp
ORDER BY qs.total_worker_time DESC;
