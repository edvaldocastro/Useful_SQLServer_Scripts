--author: Edvaldo Castro
SET NOCOUNT ON
GO
SELECT DISTINCT s.name, o.name, o.type_desc

		--s.name,o.name,c.name,ty.name,c.max_length,c.collation_name
		--'ALTER TABLE '+s.name+'.'+o.name+' ALTER COLUMN '+c.name+' '+ty.name+'('+CAST(c.max_length AS VARCHAR(30))+') COLLATE SQL_Latin1_General_CP1_CI_AS'+CHAR(13)+'GO'+CHAR(13)
FROM sys.columns c
JOIN sys.objects o
ON c.object_id = o.object_id
JOIN sys.types ty
ON c.system_type_id = ty.system_type_id
JOIN sys.schemas s
ON o.schema_id = s.schema_id
AND c.user_type_id = ty.user_type_id
WHERE o.is_ms_shipped = 0
AND ty.collation_name IS NOT NULL
AND c.collation_name <> 'SQL_Latin1_General_CP1_CI_AS'
ORDER BY s.name
--AND o.name in ('table1','table2')

--SELECT  name, is_encrypted,* FROM sys.databases WHERE is_encrypted = 0 AND database_id > 4



--save it on git hub
SET NOCOUNT ON
SELECT s.name as 'Schema_Name', t.name as Table_Name,
c.name AS Column_Name,
st.name,
c.max_length,
c.collation_name AS Collation,
'ALTER TABLE ['+s.name+'].['+t.name+'] ALTER COLUMN ['+c.name+'] '+st.name+'('+cast(c.max_length as varchar(10))+') COLLATE SQL_Latin1_General_CP1_CI_AS;'+char(13)+'GO'
FROM sys.schemas s
INNER JOIN sys.tables t
ON t.schema_id = s.schema_id
INNER JOIN sys.columns c
ON c.object_id = t.object_id
INNER JOIN sys.types st
ON c.system_type_id = st.system_type_id
WHERE c.collation_name is not null
and c.collation_name <> 'SQL_Latin1_General_CP1_CI_AS'
and st.name in ('nvarchar','varchar','char')
--and c.name = 'APUHR'
--and cast(c.max_length as varchar(10)) not like '%-1%'
ORDER BY c.max_length
