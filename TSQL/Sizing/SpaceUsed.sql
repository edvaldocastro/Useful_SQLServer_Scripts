--space used in the instance
SELECT  SERVERPROPERTY('MachineName') as HostName,
        volume_mount_point, 
        cast(max(total_bytes / 1048576.0) / 1024  as numeric(10,2)) as 'TotalSize_Gb', 
        cast(max(available_bytes / 1048576.0) / 1024 as numeric(10,2)) as 'Avalable_Size_Gb' 
FROM sys.master_files AS f  
    CROSS APPLY sys.dm_os_volume_stats(f.database_id, f.file_id)
Group by volume_mount_point
go


--space used per database
select DB_NAME(database_id) as DBName, 
        cast(SUM (CASE WHEN type_desc = 'ROWS' THEN ((size * 8) / 1024.0)/1024 end) as numeric(10,2)) as Data_Size_GB,
        cast(SUM (CASE WHEN type_desc = 'LOG' THEN ((size * 8) / 1024.0)/1024 end) as numeric(10,2))  as Log_Size_GB,
        cast(SUM (CASE WHEN type_desc = 'ROWS' THEN ((size * 8) / 1024.0)/1024 end) +
        SUM (CASE WHEN type_desc = 'LOG' THEN ((size * 8) / 1024.0)/1024 end) as numeric(10,2)) as Total_Size_GB
from sys.master_files
group by database_id
go
