/*
Purpose: Report size and growth settings for current database files, plus data-file utilization.
Compatibility: SQL Server 2016+; Azure SQL Database; Azure SQL Managed Instance.
Permissions: VIEW DATABASE STATE and access to sys.database_files.
Safety: Read-only. Run in the database being investigated.
*/
SET NOCOUNT ON;

SELECT
    DB_NAME() AS database_name,
    df.file_id,
    df.name AS logical_file_name,
    df.type_desc,
    df.physical_name,
    CAST(df.size / 128.0 AS decimal(18,2)) AS size_mb,
    CASE WHEN df.type = 0 THEN CAST(FILEPROPERTY(df.name, 'SpaceUsed') / 128.0 AS decimal(18,2)) END AS used_mb,
    CASE WHEN df.type = 0 THEN CAST((df.size - FILEPROPERTY(df.name, 'SpaceUsed')) / 128.0 AS decimal(18,2)) END AS free_mb,
    CASE WHEN df.type = 0 THEN CAST(FILEPROPERTY(df.name, 'SpaceUsed') * 100.0 / NULLIF(df.size, 0) AS decimal(6,2)) END AS used_percent,
    CASE df.max_size
        WHEN -1 THEN N'Unlimited'
        WHEN 0 THEN N'No growth'
        ELSE CONCAT(CAST(df.max_size / 128.0 AS decimal(18,2)), N' MB')
    END AS max_size,
    CASE df.is_percent_growth
        WHEN 1 THEN CONCAT(df.growth, N'%')
        ELSE CONCAT(CAST(df.growth / 128.0 AS decimal(18,2)), N' MB')
    END AS growth_setting
FROM sys.database_files AS df
ORDER BY df.type, df.file_id;
