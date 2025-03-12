SELECT
    DB_NAME(database_id) AS [Database Name],
    (CAST(SUM(size) AS FLOAT)*8)/1024 AS [Total Size (MB)],
    (CAST(SUM(CASE WHEN type_desc = 'ROWS' THEN size ELSE 0 END) AS FLOAT)*8)/1024 AS [Used Space (MB)],
    (CAST(SUM(CASE WHEN type_desc <> 'ROWS' THEN size ELSE 0 END) AS FLOAT)*8)/1024 AS [Free Space (MB)]
FROM sys.master_files
GROUP BY database_id
ORDER BY [Database Name];