/*show the fragmentation level of all the tables in a given database and creates scripts for maintenance on it*/

use <SEUBANCO>
go

-- Set the variables according to avg_fragmentation_in_percent
declare @lesserOrEqual30 varchar(15) = 'reorganize'
declare @greater30 varchar(15) = 'Rebuild'

select	 db_name(database_id) as 'database name'
		,s.name as 'schema name'
		,object_name(ips.object_id) as 'tables name' 
		,index_type_desc
		,avg_fragmentation_in_percent
		,page_count
		,(page_count*8/1024) as 'size MB'
		,case 
			when (ips.avg_fragmentation_in_percent <= 30) 
				then @lesserOrEqual30
			when (ips.avg_fragmentation_in_percent > 30) 
				then @greater30
		 end as 'Action'
		,case 
			when (ips.avg_fragmentation_in_percent <= 30) 
				then 'alter index '+i.name+' on ['+db_name(database_id)+'].['+s.name+'].['+t.name+'] '+@lesserOrEqual30+''
			when (ips.avg_fragmentation_in_percent > 30) 
				then 'alter index '+i.name+' on ['+db_name(database_id)+'].['+s.name+'].['+t.name+'] '+@greater30+''
		end as 'command'
 from	sys.dm_db_index_physical_stats (db_id(),null,null,null,'limited') ips
 join	sys.indexes i 
   on	ips.index_id = i.index_id
  and	ips.object_id = i.object_id
 join	sys.tables t
   on	t.object_id = ips.object_id 
  and	t.object_id = i.object_id
 join	sys.schemas s
   on	s.schema_id = t.schema_id
where	avg_fragmentation_in_percent > 0
  and	page_count > 1000
order	by  ips.avg_fragmentation_in_percent, page_count





