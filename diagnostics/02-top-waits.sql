/*
Purpose: Show significant cumulative waits since the last restart or wait reset.
Compatibility: SQL Server 2016+; Azure SQL Managed Instance.
Permissions: VIEW SERVER STATE or VIEW SERVER PERFORMANCE STATE on SQL Server 2022+.
Safety: Read-only. Percentages describe the filtered result set.
*/
SET NOCOUNT ON;

WITH filtered_waits AS
(
    SELECT
        wait_type,
        wait_time_ms,
        signal_wait_time_ms,
        waiting_tasks_count
    FROM sys.dm_os_wait_stats
    WHERE wait_time_ms > 0
      AND wait_type NOT IN
      (
          N'BROKER_EVENTHANDLER', N'BROKER_RECEIVE_WAITFOR', N'BROKER_TASK_STOP',
          N'BROKER_TO_FLUSH', N'CHECKPOINT_QUEUE', N'CLR_AUTO_EVENT',
          N'CLR_MANUAL_EVENT', N'DBMIRROR_DBM_EVENT', N'DBMIRROR_EVENTS_QUEUE',
          N'DBMIRROR_WORKER_QUEUE', N'DIRTY_PAGE_POLL', N'DISPATCHER_QUEUE_SEMAPHORE',
          N'FT_IFTS_SCHEDULER_IDLE_WAIT', N'HADR_CLUSAPI_CALL', N'HADR_FILESTREAM_IOMGR_IOCOMPLETION',
          N'HADR_LOGCAPTURE_WAIT', N'HADR_NOTIFICATION_DEQUEUE', N'HADR_TIMER_TASK',
          N'HADR_WORK_QUEUE', N'LAZYWRITER_SLEEP', N'LOGMGR_QUEUE', N'ONDEMAND_TASK_QUEUE',
          N'QDS_ASYNC_QUEUE', N'QDS_CLEANUP_STALE_QUERIES_TASK_MAIN_LOOP_SLEEP',
          N'REQUEST_FOR_DEADLOCK_SEARCH', N'RESOURCE_QUEUE', N'SERVER_IDLE_CHECK',
          N'SLEEP_BPOOL_FLUSH', N'SLEEP_DBSTARTUP', N'SLEEP_DCOMSTARTUP',
          N'SLEEP_MASTERDBREADY', N'SLEEP_MASTERMDREADY', N'SLEEP_SYSTEMTASK',
          N'SLEEP_TASK', N'SLEEP_TEMPDBSTARTUP', N'SNI_HTTP_ACCEPT', N'SP_SERVER_DIAGNOSTICS_SLEEP',
          N'SQLTRACE_BUFFER_FLUSH', N'WAITFOR', N'XE_DISPATCHER_JOIN', N'XE_DISPATCHER_WAIT',
          N'XE_TIMER_EVENT'
      )
), totals AS
(
    SELECT SUM(wait_time_ms) AS total_wait_time_ms
    FROM filtered_waits
)
SELECT TOP (25)
    w.wait_type,
    CAST(w.wait_time_ms / 1000.0 AS decimal(18,2)) AS wait_seconds,
    CAST(w.signal_wait_time_ms / 1000.0 AS decimal(18,2)) AS signal_wait_seconds,
    w.waiting_tasks_count,
    CAST(w.wait_time_ms * 100.0 / NULLIF(t.total_wait_time_ms, 0) AS decimal(6,2)) AS percent_of_filtered_waits,
    CAST(w.wait_time_ms * 1.0 / NULLIF(w.waiting_tasks_count, 0) AS decimal(18,2)) AS avg_wait_ms
FROM filtered_waits AS w
CROSS JOIN totals AS t
ORDER BY w.wait_time_ms DESC;
