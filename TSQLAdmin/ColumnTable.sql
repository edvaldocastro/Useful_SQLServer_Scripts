--find which objects have a specific column based on the column name
select s.name as 'schema'
          ,o.name as 'Table or View)'
          ,c.name as 'column'
          ,o.object_id
          ,'select top 5 * from ['+s.name+'].['+o.name+']'
  from sys.all_columns c
  join sys.all_objects o
    on o.object_id = c.object_id
  join sys.schemas s
    on s.schema_id = o.schema_id
where c.name like '%reg%'
order by s.name



/*
	Example: you want to know every object that contains a column with %code% as part of the column name.
	or
	you need to STATS for some tables, and you don't know the table name, you can search for column names that contains %stats% and see to wich
	table it belongs

*/

SELECT 
	s.name AS 'schema name',
	o.name AS 'object name',
	c.name AS 'column name',
	o.type_desc AS 'object type desc',
          'select top 5 * from ['+s.name+'].['+o.name+']' as 'select top 5'
FROM sys.columns c 
JOIN sys.objects o
ON c.object_id = o.object_id
JOIN sys.schemas s
ON s.schema_id = o.schema_id
WHERE c.name LIKE '%stats%'
