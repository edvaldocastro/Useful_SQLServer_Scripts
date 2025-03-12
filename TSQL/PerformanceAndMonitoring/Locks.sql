
SELECT db_name(database_id),rqt.session_id,status,blocking_session_id,wait_type,last_wait_type,wait_resource,wait_time,TEXT
      FROM sys.dm_exec_requests rqt
      INNER JOIN sys.dm_exec_connections cnt
            ON rqt.session_id = cnt.session_id 
      CROSS APPLY sys.dm_exec_sql_text(cnt.most_recent_sql_handle) 
            WHERE blocking_session_id <> 0
ORDER BY wait_time DESC



SELECT db_name(database_id),rqt.session_id,status,blocking_session_id,wait_type,last_wait_type,wait_resource,wait_time,TEXT
      FROM sys.dm_exec_requests rqt
      INNER JOIN sys.dm_exec_connections cnt
            ON rqt.session_id = cnt.session_id 
      CROSS APPLY sys.dm_exec_sql_text(cnt.most_recent_sql_handle) 
            WHERE blocking_session_id <> 0
ORDER BY wait_time DESC



SELECT * FROM sys.dm_exec_sql_text(sql_handle)  --  sql handle, pode ser obtido na sys.dm_exec_requests



SELECT db_name(database_id),rqt.session_id,rqt.status,blocking_session_id,wait_type,last_wait_type,wait_resource,wait_time,original_login_name,TEXT
      FROM sys.dm_exec_requests rqt
      INNER JOIN sys.dm_exec_connections cnt
            ON rqt.session_id = cnt.session_id 
      INNER JOIN sys.dm_exec_sessions ss
            ON ss.session_id = cnt.session_id
      CROSS APPLY sys.dm_exec_sql_text(cnt.most_recent_sql_handle) 
            WHERE rqt.STATUS like 'run%'
ORDER BY rqt.cpu_time DESC
BLOQUEIOS.txt
Open with
Displaying BLOQUEIOS.txt.
