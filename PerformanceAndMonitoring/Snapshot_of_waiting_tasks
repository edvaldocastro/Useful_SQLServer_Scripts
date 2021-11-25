

/*============================================================================
  File:     WaitingTasks.sql
 
  Summary:  Snapshot of waiting tasks
 
  SQL Server Versions: 2005 onwards
------------------------------------------------------------------------------
  Written by Paul S. Randal, SQLskills.com
 
  (c) 2016, SQLskills.com. All rights reserved.
 
  For more scripts and sample code, check out 
    http://www.SQLskills.com
 
  You may alter this code for your own *non-commercial* purposes. You may
  republish altered code as long as you include this copyright and give due
  credit, but you must obtain prior permission before blogging this code.
   
  THIS CODE AND INFORMATION ARE PROVIDED "AS IS" WITHOUT WARRANTY OF 
  ANY KIND, EITHER EXPRESSED OR IMPLIED, INCLUDING BUT NOT LIMITED 
  TO THE IMPLIED WARRANTIES OF MERCHANTABILITY AND/OR FITNESS FOR A
  PARTICULAR PURPOSE.
============================================================================*/


SELECT
    [owt].[blocking_session_id] AS [Blocking SPID],
    [owt].[session_id] AS [SPID],
    [owt].[exec_context_id] AS [Thread],
    [ot].[scheduler_id] AS [Scheduler],
    [owt].[wait_duration_ms] AS [wait_ms],
    [owt].[wait_type],
    [est].text,
    [owt].[resource_description],
    CASE [owt].[wait_type]
        WHEN N'CXPACKET' THEN
            RIGHT ([owt].[resource_description],
                CHARINDEX (N'=', REVERSE ([owt].[resource_description])) - 1)
        ELSE NULL
    END AS [Node ID],
    [eqmg].[dop] AS [DOP],
    [er].[database_id] AS [DBID],
	DB_NAME([er].[database_id])AS [DBNAME],
    CAST ('https://www.sqlskills.com/help/waits/' + [owt].[wait_type] as XML) AS [Help/Info URL],
    [eqp].[query_plan]
FROM sys.dm_os_waiting_tasks [owt]
INNER JOIN sys.dm_os_tasks [ot] ON
    [owt].[waiting_task_address] = [ot].[task_address]
INNER JOIN sys.dm_exec_sessions [es] ON
    [owt].[session_id] = [es].[session_id]
INNER JOIN sys.dm_exec_requests [er] ON
    [es].[session_id] = [er].[session_id]
FULL JOIN sys.dm_exec_query_memory_grants [eqmg] ON
    [owt].[session_id] = [eqmg].[session_id]
OUTER APPLY sys.dm_exec_sql_text ([er].[sql_handle]) [est]
OUTER APPLY sys.dm_exec_query_plan ([er].[plan_handle]) [eqp]
WHERE
    [es].[is_user_process] = 1
ORDER BY
    [owt].[session_id],
    [owt].[exec_context_id];
GO
