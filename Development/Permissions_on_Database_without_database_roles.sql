/*
	Permissions on Database (without database roles)
*/

SELECT  
	  princ.type_desc								  as 'member_description'
	, princ.name									  as 'member_principal_name'
    , LOWER(STRING_AGG(perm.[permission_name], ', ')) COLLATE SQL_Latin1_General_CP1_CI_AS as 'db_permissions'
	--, NULL /* , A.role_principal_name							 */ as 'role_assigned'
	, perm.state_desc								  as 'state_desc'
	, perm.class_desc								  as 'object_type'
	, COALESCE(s.name, SCHEMA_NAME(obj.schema_id))	  as 'schema_name'
    , OBJECT_NAME(perm.major_id)					  as 'object_name'
    , col.[name]									  as 'column_name'
	, perm.state_desc+' '+LOWER(STRING_AGG(perm.[permission_name], ', ')) COLLATE SQL_Latin1_General_CP1_CI_AS+' TO ['+princ.name+']' AS Command
	, CASE perm.class_desc
		WHEN 'DATABASE' THEN
			perm.state_desc+' '+LOWER(STRING_AGG(perm.[permission_name], ', ')) COLLATE SQL_Latin1_General_CP1_CI_AS+ ' TO ['+princ.name+']'
		WHEN 'OBJECT_OR_COLUMN' THEN
			perm.state_desc+' '+LOWER(STRING_AGG(perm.[permission_name], ', ')) COLLATE SQL_Latin1_General_CP1_CI_AS+' ON OBJECT::['+COALESCE(s.name, SCHEMA_NAME(obj.schema_id))+'].['+OBJECT_NAME(perm.major_id)+'] TO ['+princ.name+']'
		WHEN 'SCHEMA' THEN
			perm.state_desc+' '+LOWER(STRING_AGG(perm.[permission_name], ', ')) COLLATE SQL_Latin1_General_CP1_CI_AS+' ON SCHEMA::['+COALESCE(s.name, SCHEMA_NAME(obj.schema_id))+'] TO ['+princ.name+']'
	  END AS 'Command'
FROM sys.database_principals princ  
	LEFT JOIN sys.database_permissions perm ON perm.[grantee_principal_id] = princ.[principal_id]
	LEFT JOIN sys.schemas s					ON s.schema_id = perm.major_id
	LEFT JOIN sys.columns col				ON col.[object_id] = perm.major_id AND col.[column_id] = perm.[minor_id]
	LEFT JOIN sys.objects obj				ON perm.major_id = obj.object_id
	--// query below gets the roles the users are assigned to
	LEFT JOIN (		SELECT m.type_desc	as member_description
						 , m.name		AS member_principal_name
						 , STRING_AGG(r.name, ', ') AS role_principal_name
					FROM    sys.database_role_members rm
					RIGHT JOIN    sys.database_principals   AS r  ON rm.role_principal_id      = r.principal_id
					RIGHT JOIN    sys.database_principals   AS m  ON rm.member_principal_id    = m.principal_id
					WHERE m.principal_id > 4
					--AND m.type IN ('E','S','X')
					GROUP BY m.name, m.type_desc
				) A ON princ.name collate SQL_Latin1_General_CP1_CI_AS = A.member_principal_name
WHERE 1=1
--  AND princ.[type] IN ('E','S','X')
  AND princ.principal_id > 4
  AND perm.class_desc IN ('OBJECT_OR_COLUMN','DATABASE','SCHEMA')
group by  princ.type_desc
		, princ.name
		, a.role_principal_name
		, s.name
		, obj.schema_id
		, col.[name]
		, perm.major_id
		, perm.class_desc
		, perm.state_desc

/*
	Permissions on Database roles
*/



-- Query to retrieve database roles and their members
SELECT r.name AS 'RoleName',
       m.name AS 'MemberName'
FROM sys.database_role_members AS m
    INNER JOIN sys.database_principals AS r
        ON m.role_principal_id = r.principal_id
ORDER BY r.name,
         m.name;


SELECT * 
FROM sys.database_role_members rm
JOIN sys.database_principals dp
ON rm.role_principal_id = dp.principal_id
ORDER BY 2



-- Specify the target database
USE YourDatabaseName;

-- Query to retrieve database roles and their members  ON PREMISES SQL SERVER
SELECT 
	DISTINCT	 
	  r.name AS 'RoleName'
    , m.name AS 'MemberName'
    --p.type_desc AS 'MemberType',
    --p.default_schema_name AS 'DefaultSchema',
    --dp.permission_name AS 'PermissionName',
    --dp.state_desc AS 'PermissionState'
	, 'ALTER ROLE ['+r.name+'] ADD MEMBER ['+m.name+']'
FROM sys.database_role_members AS rm
INNER JOIN sys.database_principals AS r ON rm.role_principal_id = r.principal_id
INNER JOIN sys.database_principals AS m ON rm.member_principal_id = m.principal_id
LEFT JOIN sys.database_permissions AS dp ON dp.grantee_principal_id = m.principal_id
LEFT JOIN sys.database_principals AS p ON dp.grantor_principal_id = p.principal_id
ORDER BY r.name, m.name;


-- Query to retrieve database roles and their members  AZURE SYNAPSE
SELECT 
	DISTINCT	 
	  r.name AS 'RoleName'
    , m.name AS 'MemberName'
    --p.type_desc AS 'MemberType',
    --p.default_schema_name AS 'DefaultSchema',
    --dp.permission_name AS 'PermissionName',
    --dp.state_desc AS 'PermissionState'
	, ' EXEC sp_addrolemember '''+r.name+''','''+m.name+''
FROM sys.database_role_members AS rm
INNER JOIN sys.database_principals AS r ON rm.role_principal_id = r.principal_id
INNER JOIN sys.database_principals AS m ON rm.member_principal_id = m.principal_id
LEFT JOIN sys.database_permissions AS dp ON dp.grantee_principal_id = m.principal_id
LEFT JOIN sys.database_principals AS p ON dp.grantor_principal_id = p.principal_id
ORDER BY r.name, m.name;


ALTER ROLE [bi_dw_etl] ADD MEMBER [azu-fr-bi-1-app-adf-largec]

 EXEC sp_addrolemember 'bi_developer','azu-fr-bi-dev'












