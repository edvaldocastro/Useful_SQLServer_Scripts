EXEC sys.sp_MSforeachdb @command1 = N'use [?]; SELECT db_name(), NAME AS [Principal]
FROM sys.database_principals
WHERE sid NOT IN (
        SELECT sid
        FROM sys.server_principals
        )
    AND authentication_type_desc = ''INSTANCE''
    AND type = ''S''
    AND principal_id != 2
    AND DATALENGTH(sid) <= 28'
