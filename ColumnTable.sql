--find wich objects have a specific column based on the column name
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