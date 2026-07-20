# SQL Server DBA Toolkit

A practical collection of **read-only T-SQL scripts** for diagnosing common SQL Server production issues. The toolkit is designed for DBAs who need fast, understandable evidence during incidents without changing server state.

## What is included

| Area | Script | Purpose |
|---|---|---|
| Blocking | `diagnostics/01-blocking-and-active-requests.sql` | Find blockers, waiters, running statements, and transaction age |
| Waits | `diagnostics/02-top-waits.sql` | Review cumulative instance waits and filter common benign waits |
| Queries | `diagnostics/03-expensive-cached-queries.sql` | Find expensive cached statements by CPU, reads, and duration |
| Storage | `diagnostics/04-database-file-space.sql` | Review database file sizes, free space, growth, and utilization |
| Log | `diagnostics/05-transaction-log-usage.sql` | Review log usage and log reuse waits across databases |
| TempDB | `diagnostics/06-tempdb-usage.sql` | Identify sessions and tasks consuming TempDB space |
| Backups | `diagnostics/07-backup-status.sql` | Check backup recency and recent backup performance |
| SQL Agent | `diagnostics/08-failed-agent-jobs.sql` | Find recent job failures and error messages |
| Availability Groups | `diagnostics/09-availability-group-health.sql` | Review replica, database, queue, and synchronization health |

## Safety principles

- Scripts are read-only and do not intentionally change SQL Server state.
- No script runs `KILL`, clears caches, shrinks files, changes configuration, or performs failover.
- Review the header before execution; permissions and supported versions vary.
- Test in a non-production environment before relying on any script operationally.
- DMV values can reset after restart, failover, cache eviction, or a manual reset.

## Quick start

1. Clone the repository.
2. Connect through SQL Server Management Studio or Azure Data Studio.
3. Read the script header and choose the correct database context.
4. Run only the script needed for the current symptom.
5. Save the output with the incident record before taking corrective action.

Example:

```bash
git clone https://github.com/<your-github-username>/sql-server-dba-toolkit.git
cd sql-server-dba-toolkit
```

## Compatibility

The core scripts target SQL Server 2016 and later. Most also work on newer versions of Azure SQL Managed Instance. Instance-level DMVs and SQL Agent or Availability Group objects may not apply to Azure SQL Database.

## Repository roadmap

- Query Store regression analysis
- Index and statistics health checks
- Backup and restore validation helpers
- Database configuration baseline comparison
- PowerShell automation and export helpers
- Troubleshooting runbooks with sample output

## Responsible use

These scripts provide diagnostic evidence, not automatic conclusions. Validate findings against workload behavior, maintenance windows, recovery objectives, and vendor guidance before making production changes.

## License

MIT — see [LICENSE](LICENSE).
