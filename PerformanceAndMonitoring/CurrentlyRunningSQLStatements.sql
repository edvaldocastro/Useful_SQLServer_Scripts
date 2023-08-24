SELECT blocking_session_id,
	[Spid] = session_id,
       ecid,
       SUBSTRING(CAST(percent_complete AS VARCHAR(10)), 1, 5) + ' %' AS 'percent_complete',
       --	, cast(datediff(MM,start_time,getdate()) as varchar(100))+':'+substring(cast(datediff(SS,start_time,getdate()) as varchar(100)) 
       CAST(DATEDIFF(MINUTE, start_time, GETDATE()) / 60 AS VARCHAR(100)) + 'h'
       + CAST(DATEDIFF(MINUTE, start_time, GETDATE()) % 60 AS VARCHAR(100)) + 'm'AS 'elapsed_time (h:m)',
       DATEDIFF(MINUTE, start_time, GETDATE()) AS 'elapsed_time (m)',
       total_elapsed_time, 
       [Database] = DB_NAME(sp.dbid),
       [User] = nt_username,
	   [Login] = loginame,
       [Status] = er.status,
       [Wait] = wait_type,
       [Individual Query] = SUBSTRING(
                                         qt.text,
                                         er.statement_start_offset / 2,
                                         (CASE
                                              WHEN er.statement_end_offset = -1 THEN
                                                  LEN(CONVERT(NVARCHAR(MAX), qt.text)) * 2
                                              ELSE
                                                  er.statement_end_offset
                                          END - er.statement_start_offset
                                         ) / 2
                                     ),
       [Parent Query] = qt.text,
       Program = program_name,
       hostname,
       nt_domain,
       start_time
FROM sys.dm_exec_requests er
    INNER JOIN sys.sysprocesses sp
        ON er.session_id = sp.spid
    CROSS APPLY sys.dm_exec_sql_text(er.sql_handle) AS qt
WHERE session_id > 50 -- Ignore system spids.
      AND session_id NOT IN ( @@SPID ) -- Ignore this current statement.
ORDER BY 1,
         2;
