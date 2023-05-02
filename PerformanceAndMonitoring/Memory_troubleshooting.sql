-- Memory information about machine
SELECT s.physical_memory_kb / 1024 / 1024. as 'physical_memory_gb',
       s.virtual_memory_kb / 1024 / 1024. as 'virtual_memory_gb',
       s.committed_kb / 1024 / 1024. as 'committed_gb',
       s.committed_target_kb / 1024 / 1024. as 'committed_target_gb'
FROM sys.dm_os_sys_info s;


Current system memory information
/*
 
“Available physical memory is high” indicates that Windows HAS ENOUGH memory to process.
VERY IMPORTANT: DON’T PROCEED if you see for the column “system_memory_state_desc, any value different than “Available physical memory is high”
 
*/
 
SELECT m.total_physical_memory_kb/ 1024 / 1024. as 'total_physical_memory_gb',
       m.available_physical_memory_kb/ 1024 / 1024. as 'available_physical_memory_gb',
       m.system_memory_state_desc
FROM sys.dm_os_sys_memory m;


Current SQL Server process memory information

SELECT p.physical_memory_in_use_kb/ 1024 / 1024. as 'physical_memory_in_use_gb',
       p.process_physical_memory_low,
       p.process_virtual_memory_low
FROM sys.dm_os_process_memory p;