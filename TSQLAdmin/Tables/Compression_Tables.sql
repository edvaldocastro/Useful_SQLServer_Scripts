SELECT DB_NAME(), s.name, o.name, p.data_compression_desc,p.rows, N'ALTER TABLE '+s.name+ N'.'+o.name+ N' REBUILD PARTITION = ALL WITH (DATA_COMPRESSION = PAGE);'
FROM sys.partitions p
JOIN sys.objects o
ON p.object_id = o.object_id
JOIN sys.schemas s
ON s.schema_id = o.schema_id
WHERE o.is_ms_shipped = 0
AND o.type = 'U'
AND p.data_compression_desc = 'NONE'
ORDER BY p.rows


SELECT
    DB_NAME(database_id) AS [Database Name],
    (CAST(SUM(size) AS FLOAT)*8)/1024 AS [Total Size (MB)],
    (CAST(SUM(CASE WHEN type_desc = 'ROWS' THEN size ELSE 0 END) AS FLOAT)*8)/1024 AS [Used Space (MB)],
    (CAST(SUM(CASE WHEN type_desc <> 'ROWS' THEN size ELSE 0 END) AS FLOAT)*8)/1024 AS [Free Space (MB)]
FROM sys.master_files
GROUP BY database_id
ORDER BY [Database Name];


