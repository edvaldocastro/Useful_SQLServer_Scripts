 /********************* STATISTICS DATE AND UPDATE SCRIPT *********************/
 /* Adapted from an original Script from Pinal Dave - https://blog.sqlauthority.com/ */ 
 
select o.object_id as 'Object_id',
       s.name as 'Schema',
          o.name as 'Object_name',
          o.type_desc as 'Object_type',
          i.index_id as 'Index_id',
          i.name as 'Index_name',
          STATS_DATE(i.object_id,index_id) as 'Last updated',
          datediff(day,STATS_DATE(i.object_id,index_id),GETDATE()) as 'Day since updated',
          'UPDATE STATISTICS ['+s.name+'].['+o.name+'] ['+i.name+'] WITH FULLSCAN;' as 'Update Idx Stats',
          'UPDATE STATISTICS ['+s.name+'].['+o.name+'] WITH FULLSCAN;' as 'Update Obj Stats'
  from sys.indexes i
  join sys.objects o
    on i.object_id = o.object_id
  join sys.schemas s
    on o.schema_id = s.schema_id
where o.object_id > 255
   and s.name <> 'sys'
   and o.type in('S','U','V,IT')
 order by STATS_DATE(i.object_id,index_id)

                   
                   
 *********************************************************************************************
  
/* THIS VERSION SHOWS STATISTICS DATE, SCRIPT TO UPDATE AND TABLE SIZE AND NUMBER OF ROWS */
  SELECT distinct o.object_id as 'Object_id',
       s.name as 'Schema',
          o.name as 'Object_name',
          o.type_desc as 'Object_type',
          i.index_id as 'Index_id',
          i.name as 'Index_name',
		  p.rows,
		  CAST(SUM(a.total_pages) * 8 as numeric(12,2)) as 'TotalSpaceKB', 
	      CAST(SUM(a.total_pages) * 8 /1024. as numeric(12,2)) as 'TotalSpaceMB', 
		  STATS_DATE(o.object_id, st.stats_id) AS 'Stats date',
          STATS_DATE(i.object_id,i.index_id) as 'Last updated',
          datediff(day,STATS_DATE(i.object_id,i.index_id),GETDATE()) as 'Day since updated',
           'UPDATE STATISTICS ['+s.name+'].['+o.name+'] ('+st.name+') WITH FULLSCAN;' as 'Update Obj Stats'
  from sys.indexes i
  join sys.objects o
    on i.object_id = o.object_id
  join sys.schemas s
    on o.schema_id = s.schema_id
  join sys.partitions p
    on p.object_id = i.object_id
   and i.index_id = p.index_id
  join sys.allocation_units a
    on a.container_id = p.partition_id
  JOIN sys.stats st
    ON st.object_id = o.object_id
	AND st.object_id = i.object_id
	AND st.object_id = p.object_id
group by o.object_id,s.name,o.name,o.type_desc,i.index_id,i.name,p.rows, i.object_id, o.type, st.stats_id, st.name
having o.object_id > 255
   and s.name <> 'sys'
   and o.type in('S','U','V,IT')
 order by STATS_DATE(i.object_id,i.index_id), STATS_DATE(o.object_id, st.stats_id) 

