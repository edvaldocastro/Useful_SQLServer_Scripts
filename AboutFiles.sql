--Information about Files (mdf and ldf)
select db_name() as 'DatabaseName'
       ,df.name as 'FileName'
          ,df.type_desc
          ,ds.name as 'FileGroupName'
          ,cast(df.size/128. as numeric(12,3)) as 'FileSize(MB)'
          ,cast(FILEPROPERTY(df.name,'SpaceUsed')/128. as numeric(12,3))as 'FileSpaceused(MB)'
          ,cast((FILEPROPERTY(df.name,'SpaceUsed')/128.) /  (df.size/128.) * 100 as numeric(12,3)) as 'FilePercentUsed'
          ,cast(df.size/128. - (FILEPROPERTY(df.name,'SpaceUsed')/128.) as numeric(12,3)) as 'FileFreeSpace(MB)'
          ,cast((df.size/128 - FILEPROPERTY(df.name,'SpaceUsed')/128)/(df.size/128.)*100 as numeric(12,3)) as 'FilePercentFree'
          ,df.physical_name
  from sys.database_files df
  left join sys.data_spaces ds
    on  ds.data_space_id = df.data_space_id