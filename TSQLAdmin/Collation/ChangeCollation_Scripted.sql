--author: Edvaldo Castro
SET NOCOUNT ON
GO
SELECT --s.name,t.name,c.name,ty.name,c.max_length,c.collation_name
		'ALTER TABLE '+s.name+'.'+t.name+' ALTER COLUMN '+c.name+' '+ty.name+'('+CAST(c.max_length AS VARCHAR(30))+') COLLATE SQL_Latin1_General_CP1_CI_AS'+CHAR(13)+'GO'+CHAR(13)
FROM sys.columns c
JOIN sys.tables t
ON c.object_id = t.object_id
JOIN sys.types ty
ON c.system_type_id = ty.system_type_id
JOIN sys.schemas s
ON t.schema_id = s.schema_id
AND c.user_type_id = ty.user_type_id
WHERE t.is_ms_shipped = 0
AND ty.collation_name IS NOT NULL
AND c.collation_name <> 'SQL_Latin1_General_CP1_CI_AS'
ORDER BY s.name
--AND t.name in ('table1','table2')
