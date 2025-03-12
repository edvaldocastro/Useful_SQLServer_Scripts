SELECT NAME AS [Principal], 'EXEC sp_change_users_login ''auto_fix'','''+Name+''''
FROM sys.database_principals
WHERE sid NOT IN (
        SELECT sid
        FROM sys.server_principals
        )
    AND authentication_type_desc = 'INSTANCE'
    AND type = 'S'
    AND principal_id != 2
    AND DATALENGTH(sid) <= 28
