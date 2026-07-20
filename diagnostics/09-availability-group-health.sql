/*
Purpose: Review local Availability Group replica and database synchronization health.
Compatibility: SQL Server 2016+ with Always On Availability Groups.
Permissions: VIEW SERVER STATE or VIEW SERVER PERFORMANCE STATE on SQL Server 2022+.
Safety: Read-only. Returns no rows when the instance hosts no AG replicas.
*/
SET NOCOUNT ON;

SELECT
    ag.name AS availability_group_name,
    ar.replica_server_name,
    ars.role_desc,
    ars.connected_state_desc,
    ars.operational_state_desc,
    ar.availability_mode_desc,
    ar.failover_mode_desc,
    DB_NAME(drs.database_id) AS database_name,
    drs.synchronization_state_desc,
    drs.synchronization_health_desc,
    drs.is_suspended,
    drs.suspend_reason_desc,
    drs.log_send_queue_size AS log_send_queue_kb,
    drs.redo_queue_size AS redo_queue_kb,
    drs.log_send_rate AS log_send_rate_kb_per_sec,
    drs.redo_rate AS redo_rate_kb_per_sec,
    drs.last_commit_time
FROM sys.availability_groups AS ag
INNER JOIN sys.availability_replicas AS ar
    ON ar.group_id = ag.group_id
LEFT JOIN sys.dm_hadr_availability_replica_states AS ars
    ON ars.replica_id = ar.replica_id
LEFT JOIN sys.dm_hadr_database_replica_states AS drs
    ON drs.replica_id = ar.replica_id
   AND drs.group_id = ag.group_id
ORDER BY ag.name, ar.replica_server_name, database_name;
