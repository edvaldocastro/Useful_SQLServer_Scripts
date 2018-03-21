 --STATISTICS DATE AND UPDATE SCRIPT
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

/*
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
 order by STATS_DATE(i.object_id,index_id)
*/
