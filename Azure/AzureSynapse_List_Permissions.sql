
/*
Reference: https://copyprogramming.com/howto/troubleshoot-orphaned-users-sql-server

Detect Orphaned Users
Applicable to both SQL Server and PDW.
In order to target Detect Orphaned Users in SQL Server, utilize the subsequent instruction within the user database to identify absent SQL Server authentication logins:

*/

SELECT  dp.name AS user_name,/*dp.type_desc,*/ dp.sid, 'ALTER USER  ['+dp.name+'] WITH Login = ['+dp.name+']'  
FROM sys.database_principals AS dp  
LEFT JOIN sys.server_principals AS sp  
    ON dp.sid = sp.sid  
WHERE sp.sid IS NULL  
    AND dp.authentication_type_desc = 'INSTANCE';  


------------------------------------------------------------------------------------------------------

/*
source: 
https://sqlstudies.com/free-scripts/sp_azsyndbpermissions/
*/


/******************* Database Principals ********************/

SELECT [DBPrincipals].[principal_id] AS "DBPrincipalId",
       [DBPrincipals].[name] AS "DBPrincipal",
       [DBPrincipals].[type],
       [DBPrincipals].[type_desc],
       [DBPrincipals].[default_schema_name],
       [DBPrincipals].[create_date],
       [DBPrincipals].[modify_date],
       [DBPrincipals].[is_fixed_role],
       [Authorizations].[name] AS "RoleAuthorization",
       [DBPrincipals].[sid],
       CASE
           WHEN [DBPrincipals].[is_fixed_role] = 0
                AND [DBPrincipals].[name] NOT IN ( 'dbo', 'guest', 'INFORMATION_SCHEMA', 'public', 'sys' ) THEN
               'IF DATABASE_PRINCIPAL_ID(''' + [DBPrincipals].[name] + ''') IS NOT NULL ' + 'DROP '
               + CASE [DBPrincipals].[type]
                     WHEN 'C' THEN
                         NULL
                     WHEN 'K' THEN
                         NULL
                     WHEN 'R' THEN
                         'ROLE'
                     WHEN 'A' THEN
                         'APPLICATION ROLE'
                     ELSE
                         'USER'
                 END + ' ' + QUOTENAME([DBPrincipals].[name] COLLATE SQL_Latin1_General_CP1_CI_AS) + ';'
           ELSE
               NULL
       END AS "DropScript",
       CASE
           WHEN [DBPrincipals].[is_fixed_role] = 0
                AND [DBPrincipals].[name] NOT IN ( 'dbo', 'guest', 'INFORMATION_SCHEMA', 'public', 'sys' ) THEN
               'IF DATABASE_PRINCIPAL_ID(''' + [DBPrincipals].[name] + ''') IS NULL ' + 'CREATE '
               + CASE [DBPrincipals].[type]
                     WHEN 'C' THEN
                         NULL
                     WHEN 'K' THEN
                         NULL
                     WHEN 'R' THEN
                         'ROLE'
                     WHEN 'A' THEN
                         'APPLICATION ROLE'
                     ELSE
                         'USER'
                 END + ' ' + QUOTENAME([DBPrincipals].[name] COLLATE SQL_Latin1_General_CP1_CI_AS)
       END
       + CASE
             WHEN [DBPrincipals].[type] = 'R' THEN
                 ISNULL(' AUTHORIZATION ' + QUOTENAME([Authorizations].[name] COLLATE SQL_Latin1_General_CP1_CI_AS), '')
             WHEN [DBPrincipals].[type] = 'X' THEN
                 ' FROM EXTERNAL PROVIDER'
             WHEN [DBPrincipals].[type] = 'A' THEN
                 ''
             WHEN [DBPrincipals].[type] NOT IN ( 'C', 'K' ) THEN
                 ISNULL(
                           ' WITH DEFAULT_SCHEMA =  '
                           + QUOTENAME([DBPrincipals].[default_schema_name] COLLATE SQL_Latin1_General_CP1_CI_AS),
                           ''
                       )
             ELSE
                 ''
         END + CASE
                   WHEN [DBPrincipals].[type] = 'S' THEN
                       ', PASSWORD = ''<Insert Strong Password Here>'' '
                   ELSE
                       ''
               END + ';' AS "CreateScript"
FROM [sys].[database_principals] [DBPrincipals]
    LEFT OUTER JOIN [sys].[database_principals] [Authorizations]
        ON [DBPrincipals].[owning_principal_id] = [Authorizations].[principal_id]
WHERE 1 = 1
      AND [DBPrincipals].[sid] NOT IN ( 0x00, 0x01 );

------------------------------------------------------------------------------------------------------

/******************* Database Role Members ********************/

SELECT [Users].[principal_id] AS "UserPrincipalId",
       [Users].[name] AS "UserName",
       [Roles].[name] AS "RoleName",
       CASE
           WHEN [Users].[is_fixed_role] = 0
                AND [Users].[name] <> 'dbo' THEN
               'EXEC sp_droprolemember @rolename = '
               + QUOTENAME([Roles].[name] COLLATE SQL_Latin1_General_CP1_CI_AS, '''') + ', @membername = '
               + QUOTENAME(   CASE
                                  WHEN [Users].[name] = 'dbo' THEN
                                      NULL
                                  ELSE
                                      [Users].[name]
                              END COLLATE SQL_Latin1_General_CP1_CI_AS,
                              ''''
                          ) + ';'
       END AS "DropScript",
       CASE
           WHEN [Users].[is_fixed_role] = 0
                AND [Users].[name] <> 'dbo' THEN
               'EXEC sp_addrolemember @rolename = '
               + QUOTENAME([Roles].[name] COLLATE SQL_Latin1_General_CP1_CI_AS, '''') + ', @membername = '
               + QUOTENAME(   CASE
                                  WHEN [Users].[name] = 'dbo' THEN
                                      NULL
                                  ELSE
                                      [Users].[name]
                              END COLLATE SQL_Latin1_General_CP1_CI_AS,
                              ''''
                          ) + ';'
       END AS "AddScript"
FROM [sys].[database_role_members] [RoleMembers]
    JOIN [sys].[database_principals] [Users]
        ON [RoleMembers].[member_principal_id] = [Users].[principal_id]
    JOIN [sys].[database_principals] [Roles]
        ON [RoleMembers].[role_principal_id] = [Roles].[principal_id]
WHERE 1 = 1

------------------------------------------------------------------------------------------------------


/******************* Database & object Permissions ********************/
;
WITH [ObjectList]
AS (SELECT SCHEMA_NAME([sys].[all_objects].[schema_id])COLLATE SQL_Latin1_General_CP1_CI_AS AS "SchemaName",
           [name] COLLATE SQL_Latin1_General_CP1_CI_AS AS "name",
           [object_id] AS "id",
           'OBJECT_OR_COLUMN' AS "class_desc",
           'OBJECT' AS "class"
    FROM [sys].[all_objects]
    UNION ALL
    SELECT [name] COLLATE SQL_Latin1_General_CP1_CI_AS AS "SchemaName",
           NULL AS "name",
           [schema_id] AS "id",
           'SCHEMA' AS "class_desc",
           'SCHEMA' AS "class"
    FROM [sys].[schemas]
    UNION ALL
    SELECT NULL AS "SchemaName",
           [name] COLLATE SQL_Latin1_General_CP1_CI_AS AS "name",
           [principal_id] AS "id",
           'DATABASE_PRINCIPAL' AS "class_desc",
           CASE [type_desc]
               WHEN 'APPLICATION_ROLE' THEN
                   'APPLICATION ROLE'
               WHEN 'DATABASE_ROLE' THEN
                   'ROLE'
               ELSE
                   'USER'
           END AS "class"
    FROM [sys].[database_principals]
    UNION ALL
    SELECT NULL AS "SchemaName",
           [name] COLLATE SQL_Latin1_General_CP1_CI_AS AS "name",
           [assembly_id] AS "id",
           'ASSEMBLY' AS "class_desc",
           'ASSEMBLY' AS "class"
    FROM [sys].[assemblies]
    UNION ALL
    SELECT SCHEMA_NAME([sys].[types].[schema_id])COLLATE SQL_Latin1_General_CP1_CI_AS AS "SchemaName",
           [name] COLLATE SQL_Latin1_General_CP1_CI_AS AS "name",
           [user_type_id] AS "id",
           'TYPE' AS "class_desc",
           'TYPE' AS "class"
    FROM [sys].[types]
    UNION ALL
    SELECT NULL AS "SchemaName",
           [name] COLLATE SQL_Latin1_General_CP1_CI_AS AS "name",
           [symmetric_key_id] AS "id",
           'SYMMETRIC_KEYS' AS "class_desc",
           'SYMMETRIC KEY' AS "class"
    FROM [sys].[symmetric_keys]
    UNION ALL
    SELECT NULL AS "SchemaName",
           [name] COLLATE SQL_Latin1_General_CP1_CI_AS AS "name",
           [certificate_id] AS "id",
           'CERTIFICATE' AS "class_desc",
           'CERTIFICATE' AS "class"
    FROM [sys].[certificates]
    UNION ALL
    SELECT NULL AS "SchemaName",
           [name] COLLATE SQL_Latin1_General_CP1_CI_AS AS "name",
           [asymmetric_key_id] AS "id",
           'ASYMMETRIC_KEY' AS "class_desc",
           'ASYMMETRIC KEY' AS "class"
    FROM [sys].[asymmetric_keys])
SELECT [Grantee].[principal_id] AS "GranteePrincipalId",
       [Grantee].[name] AS "GranteeName",
       [Grantor].[name] AS "GrantorName",
       [Permission].[class_desc],
       [Permission].[permission_name],
       [ObjectList].[name] AS "ObjectName",
       [ObjectList].[SchemaName],
       [Permission].[state_desc],
       CASE
           WHEN [Grantee].[is_fixed_role] = 0
                AND [Grantee].[name] <> 'dbo' THEN
               'REVOKE ' + CASE
                               WHEN [Permission].[state] = 'W' THEN
                                   'GRANT OPTION FOR '
                               ELSE
                                   ''
                           END + ' ' + [Permission].[permission_name] COLLATE SQL_Latin1_General_CP1_CI_AS
               + CASE
                     WHEN [Permission].[major_id] <> 0 THEN
                         ' ON ' + [ObjectList].[class] + '::' + ISNULL(QUOTENAME([ObjectList].[SchemaName]), '')
                         + CASE
                               WHEN [ObjectList].[SchemaName] + [ObjectList].[name] IS NULL THEN
                                   ''
                               ELSE
                                   '.'
                           END + ISNULL(QUOTENAME([ObjectList].[name]), '')COLLATE SQL_Latin1_General_CP1_CI_AS + ' '
                     ELSE
                         ''
                 END + ' FROM ' + QUOTENAME([Grantee].[name] COLLATE SQL_Latin1_General_CP1_CI_AS) + '; '
       END AS "RevokeScript",
       CASE
           WHEN [Grantee].[is_fixed_role] = 0
                AND [Grantee].[name] <> 'dbo' THEN
               CASE
                   WHEN [Permission].[state] = 'W' THEN
                       'GRANT'
                   ELSE
                       [Permission].[state_desc] COLLATE SQL_Latin1_General_CP1_CI_AS
               END + ' ' + [Permission].[permission_name] COLLATE SQL_Latin1_General_CP1_CI_AS
               + CASE
                     WHEN [Permission].[major_id] <> 0 THEN
                         ' ON ' + [ObjectList].[class] + '::' + ISNULL(QUOTENAME([ObjectList].[SchemaName]), '')
                         + CASE
                               WHEN [ObjectList].[SchemaName] + [ObjectList].[name] IS NULL THEN
                                   ''
                               ELSE
                                   '.'
                           END + ISNULL(QUOTENAME([ObjectList].[name]), '')COLLATE SQL_Latin1_General_CP1_CI_AS + ' '
                     ELSE
                         ''
                 END + ' TO ' + QUOTENAME([Grantee].[name] COLLATE SQL_Latin1_General_CP1_CI_AS) + ' '
               + CASE
                     WHEN [Permission].[state] = 'W' THEN
                         ' WITH GRANT OPTION '
                     ELSE
                         ''
                 END + ' AS ' + QUOTENAME([Grantor].[name] COLLATE SQL_Latin1_General_CP1_CI_AS) + ';'
       END AS "GrantScript"
FROM [sys].[database_permissions] [Permission]
    JOIN [sys].[database_principals] [Grantee]
        ON [Permission].[grantee_principal_id] = [Grantee].[principal_id]
    JOIN [sys].[database_principals] [Grantor]
        ON [Permission].[grantor_principal_id] = [Grantor].[principal_id]
    LEFT OUTER JOIN [ObjectList]
        ON [Permission].[major_id] = [ObjectList].[id]
           AND [Permission].[class_desc] = [ObjectList].[class_desc]
WHERE 1 = 1 AND [Grantee].[name] not in ('public','guest');





