/* 05 */   
 -- Table information
select s.name as 'SchemaName',
       t.name as 'TableName',
	   p.rows,
	   CAST(SUM(a.total_pages) * 8 as numeric(12,2)) as 'TotalSpaceKB', 
	   CAST(SUM(a.total_pages) * 8 /1024. as numeric(12,2)) as 'TotalSpaceMB', 
	   CAST(SUM(a.used_pages) * 8 as numeric(12,2)) as 'UsedSpaceKB', 
	   CAST(SUM(a.used_pages) * 8 / 1024. as numeric(12,2)) as 'UsedSpaceMB', 
	   (SUM(a.total_pages) - SUM(a.used_pages)) * 8 as 'UnusedSpaceKB',
	   CAST((a.used_pages * 8. / p.rows)as numeric(12,2)) as 'AVGRowSizeKB',
	   case p.partition_number
			when 1 then 'Not Partitioned'
			else 'Partitioned'
	   end as 'IsTablePartitioned', 
	   p.data_compression_desc as 'DataCompressionType',
	   'alter table ['+s.name+'].['+t.name+'] rebuild with (data_compression=page)'	   
	   --'select * from '+s.name+'.'+t.name
  from sys.tables t
  join sys.indexes i 
    on t.OBJECT_ID = i.object_id
  join sys.partitions p 
    on i.object_id = p.OBJECT_ID 
   and i.index_id = p.index_id
  join sys.allocation_units a 
    on p.partition_id = a.container_id
  left join sys.schemas s 
    on t.schema_id = s.schema_id
 where t.name not like 'dt%' 
   and t.is_ms_shipped = 0
   and i.object_id > 255 
   and p.rows > 0
   and i.index_id in (0,1)
 group by t.Name, s.Name, p.Rows, a.used_pages,p.partition_number,p.data_compression_desc
 order by a.used_pages desc
