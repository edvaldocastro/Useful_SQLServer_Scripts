
/*GET THE MOST EXPENSIVE STORED PROCEDURES*/

-- Adapted from 
-- https://gist.github.com/bartread/86d1a50572640aec75185d111fd3afdc


-- SINGLE DATABASE
USE [YOUR_DATABASE_NAME]; -- Substitute for your database name
GO

SELECT TOP 10 -- Change as appropriate
	t.text ,
	s.sql_handle ,
	s.plan_handle ,
	s.total_worker_time / 1000 AS total_cpu_time_millis ,
	s.total_worker_time / s.execution_count / 1000 AS avg_cpu_time_millis ,
	s.total_logical_reads,
	s.total_logical_reads / s.execution_count AS avg_logical_reads ,
	s.total_logical_writes,
	s.total_logical_writes / s.execution_count AS avg_logical_writes ,
	s.total_physical_reads,
	s.total_physical_reads / s.execution_count AS avg_physical_reads,
	s.cached_time,
	s.execution_count ,
	s.last_execution_time,
	s.last_elapsed_time / 1000 AS last_elapsed_time_millis,
	s.last_logical_reads,
	s.last_physical_reads,
	s.last_worker_time / 1000 AS last_worker_time_millis
FROM	sys.dm_exec_procedure_stats AS s
CROSS APPLY sys.dm_exec_sql_text(s.sql_handle) AS t
WHERE	DB_NAME(t.dbid) = 'YOUR_DATABASE_NAME' -- Substitute for your database name
	AND s.last_execution_time > '2017-01-05 00:00:00.000' -- Change date as appropriate (or comment out)
	--AND s.last_physical_reads > 10 -- Sample filter; change column and value as appropriate
ORDER BY -- Comment/uncomment below to order by column of interest
	avg_logical_reads DESC
--	avg_physical_reads DESC
--	avg_cpu_time_millis DESC
--	last_elapsed_time_millis DESC
;


-- ALL DATABASES IN THE INSTANCE

EXEC sp_msforeachdb 'use [?]; 
SELECT TOP 50 -- Change as appropriate
	DB_NAME(),
	t.text ,
	s.sql_handle ,
	s.plan_handle ,
	s.total_worker_time / 1000 AS total_cpu_time_millis ,
	s.total_worker_time / s.execution_count / 1000 AS avg_cpu_time_millis ,
	s.total_logical_reads,
	s.total_logical_reads / s.execution_count AS avg_logical_reads ,
	s.total_logical_writes,
	s.total_logical_writes / s.execution_count AS avg_logical_writes ,
	s.total_physical_reads,
	s.total_physical_reads / s.execution_count AS avg_physical_reads,
	s.cached_time,
	s.execution_count ,
	s.last_execution_time,
	s.last_elapsed_time / 1000 AS last_elapsed_time_millis,
	s.last_logical_reads,
	s.last_physical_reads,
	s.last_worker_time / 1000 AS last_worker_time_millis
FROM	sys.dm_exec_procedure_stats AS s
CROSS APPLY sys.dm_exec_sql_text(s.sql_handle) AS t
WHERE	1=1 
--AND DB_NAME(t.dbid) = ''frbidba'' -- Substitute for your database name
	AND s.last_execution_time > ''2021-06-05 00:00:00.000'' -- Change date as appropriate (or comment out)
	--AND s.last_physical_reads > 10 -- Sample filter; change column and value as appropriate
--ORDER BY -- Comment/uncomment below to order by column of interest
--	avg_logical_reads DESC
--	avg_physical_reads DESC
--	avg_cpu_time_millis DESC
--	last_elapsed_time_millis DESC
;'

