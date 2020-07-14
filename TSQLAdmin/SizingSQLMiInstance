-- taken from 
-- https://dba.stackexchange.com/questions/246995/how-to-find-total-used-and-remaining-space-in-azure-sql-mi
USE master
go
SELECT  SERVERPROPERTY('MachineName') as HostName,
        volume_mount_point, 
        max(total_bytes / 1048576.0) / 1024 as TotalSize_Gb, 
        max(available_bytes / 1048576.0) / 1024 as Avalable_Size_Gb 
FROM sys.master_files AS f  
    CROSS APPLY sys.dm_os_volume_stats(f.database_id, f.file_id)
Group by volume_mount_point
go

select DB_NAME(database_id) as DBName, 
        SUM (CASE WHEN type_desc = 'ROWS' THEN ((size * 8) / 1024.0)/1024 end) as Data_Size_GB,
        SUM (CASE WHEN type_desc = 'LOG' THEN ((size * 8) / 1024.0)/1024 end) as Log_Size_GB,
        SUM (CASE WHEN type_desc = 'ROWS' THEN ((size * 8) / 1024.0)/1024 end) +
        SUM (CASE WHEN type_desc = 'LOG' THEN ((size * 8) / 1024.0)/1024 end) as Total_Size_GB
from sys.master_files
group by database_id
go
