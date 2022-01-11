-- Kill all sessions for a given DB

USE [master];

DECLARE @kill varchar(8000) = '';  
--SELECT @kill = @kill + 'kill ' + CONVERT(varchar(5), session_id) + ';'  
SELECT @kill = @kill + 'Select ' + CONVERT(varchar(5), session_id) + ';'  
FROM sys.dm_exec_sessions
WHERE database_id  = db_id('DATABASENAME')

EXEC(@kill);
