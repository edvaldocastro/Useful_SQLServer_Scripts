SELECT user_name(sr.member_principal_id) as [Principal] 
    ,user_name(sr.role_principal_id) as [Role]
    ,type_desc as [Principal Type]
FROM sys.database_role_members AS sr
INNER JOIN sys.database_principals sp ON sp.principal_id = sr.member_principal_id
WHERE sr.role_principal_id IN (user_id('bulkadmin'),
                             user_id('db_accessadmin'),
                             user_id('db_securityadmin'),
                             user_id('db_ddladmin'),
                             user_id('db_backupoperator'),
                             user_id('db_owner'))
