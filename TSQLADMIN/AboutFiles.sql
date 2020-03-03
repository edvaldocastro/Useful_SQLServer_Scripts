/* Single database view */
--Information about Files (mdf and ldf)
select db_name() as 'DatabaseName'
       ,df.name as 'FileName'
          ,df.type_desc
          ,ds.name as 'FileGroupName'
          ,cast(df.size/128. as numeric(12,2)) as 'FileSize(MB)'
          ,cast(FILEPROPERTY(df.name,'SpaceUsed')/128. as numeric(12,2))as 'FileSpaceused(MB)'
          ,cast((FILEPROPERTY(df.name,'SpaceUsed')/128.) /  (df.size/128.) * 100 as numeric(12,2)) as 'FilePercentUsed'
          ,cast(df.size/128. - (FILEPROPERTY(df.name,'SpaceUsed')/128.) as numeric(12,2)) as 'FileFreeSpace(MB)'
          ,cast((df.size/128 - FILEPROPERTY(df.name,'SpaceUsed')/128)/(df.size/128.)*100 as numeric(12,2)) as 'FilePercentFree'
		  ,cast(df.growth/128. as numeric(12,2)) as 'FileGrowth'
          ,df.physical_name
  from sys.database_files df
  left join sys.data_spaces ds
    on  ds.data_space_id = df.data_space_id
                                                                                                    

						  
						  
/* All databases in a given instance */ 
drop table if exists #tbAboutFile
create table #tbAboutFile
(
	[DatabaseName] varchar(50)
	,[FileName]	varchar(300)
	,[type_desc]	varchar (10)
	,[FileGroupName]	varchar(200)
	,[FileSize(MB)]	numeric(9,2)
	,[FileSpaceused(MB)]	numeric(9,2)
	,[FilePercentUsed]	numeric(9,2)
	,[FileFreeSpace(MB)]	numeric(9,2)
	,[FilePercentFree] numeric(9,2)
	,[FileGrowth(MB)] numeric(9,2)
	,[physical_name] varchar(300)
)
go
exec sp_MSforeachdb 'use [?];
insert into #tbAboutFile
select db_name() as "DatabaseName"
       ,df.name as "FileName"
          ,df.type_desc
          ,ds.name as "FileGroupName"
          ,cast(df.size/128. as numeric(12,2)) as "FileSize(MB)"
          ,cast(FILEPROPERTY(df.name,"SpaceUsed")/128. as numeric(12,2))as "FileSpaceused(MB)"
          ,cast((FILEPROPERTY(df.name,"SpaceUsed")/128.) /  (df.size/128.) * 100 as numeric(12,2)) as "FilePercentUsed"
          ,cast(df.size/128. - (FILEPROPERTY(df.name,"SpaceUsed")/128.) as numeric(12,2)) as "FileFreeSpace(MB)"
          ,cast((df.size/128 - FILEPROPERTY(df.name,"SpaceUsed")/128)/(df.size/128.)*100 as numeric(12,2)) as "FilePercentFree"
		  ,cast(df.growth/128. as numeric(12,2)) as "FileGrowth(MB)"
          ,df.physical_name
  from sys.database_files df
  left join sys.data_spaces ds
    on  ds.data_space_id = df.data_space_id'
select * from #tbAboutFile
drop table #tbAboutFile
