/*********************************************************************************************************

	Author .........: Edvaldo Castro   
	Date ...........: May 2018
	Version ........: Initial v1.0      
	Purpose ........: Setup SQL Server Trace Audit
	Comments .......: This script creates all the necessary objects to deploy the Trace Auditing Solution.
	Database .......: fil_dba_tools
	Description ....: 
						1 - create stored procedure audit.usp_create_Trace_Audit_SQLServer
						2 - create stored procedure audit.usp_Import_Trace_Audit_SQLServer
						3 - create sql agent job 'FILDBA - Auditing SQL Server'
							3.1 - Scheduled to run once an hour
						4 - create table audit.Trace_Audit_SQLServer
	
*********************************************************************************************************/
USE fil_dba_tools
GO
CREATE OR ALTER PROCEDURE audit.usp_create_Trace_Audit_SQLServer

AS
/****************************************************/
/* Created by: SQL Server 2017 Profiler          */
/* Date: 11/05/2018  06:51:40         */
/****************************************************/
/*********************************************************************************************************

	Author .........: Edvaldo Castro   
	Date ...........: May 2018
	Version ........: Initial v1.0      
	Purpose ........: Imports Trace Audit SQL Server  
	Comments .......: This SP imports the content from Trace File created for auditing into the table
					  audit.Trace_Audit_SQLServer	  .
	Modifications ..:     

*********************************************************************************************************/
-- Create a Queue
declare @rc int
declare @TraceID int
declare @maxfilesize bigint= 512

declare @dateandtime nvarchar(256) = (select CONCAT(DATEPART(DD,GETDATE()),'_',DATEPART(MM,GETDATE()),'_',DATEPART(YYYY,GETDATE()),'_',(Replace(convert(nvarchar(256), getdate(),108),':',''))))
declare @prefix_filename nvarchar(256) = N'Trace_Audit_SQLServer'
declare @sufix_filename nvarchar(256) =  concat(@dateandtime,'_',convert(nvarchar(256),SERVERPROPERTY('ComputerNamePhysicalNetBios')),'_',@@SERVICENAME)
declare @path NVARCHAR(256) = (select concat(substring(cast(value_data as nvarchar(256)),3,len(cast(value_data as nvarchar(256)))-11),@sufix_filename,'_',@prefix_filename) from sys.dm_server_registry where value_name = 'SQLArg1')
select @path


-- Please replace the text InsertFileNameHere, with an appropriate
-- filename prefixed by a path, e.g., c:\MyFolder\MyTrace. The .trc extension
-- will be appended to the filename automatically. If you are writing from
-- remote server to local drive, please use UNC path and make sure server has
-- write access to your network share

exec @rc = sp_trace_create @TraceID output, 0, @path, @maxfilesize, NULL 
if (@rc != 0) goto error

-- Client side File and Table cannot be scripted

-- Set the events
declare @on bit
set @on = 1

-- 109 | Audit Add DB User  | 
-- Event Occurs when a login is added or removed as a database user (Windows or SQL Server) to a database; 
-- for sp_grantdbaccess, sp_revokedbaccess, sp_adduser, and sp_dropuser. 
exec sp_trace_setevent @TraceID, 109, 3, @on
exec sp_trace_setevent @TraceID, 109, 11, @on
exec sp_trace_setevent @TraceID, 109, 12, @on
exec sp_trace_setevent @TraceID, 109, 6, @on
exec sp_trace_setevent @TraceID, 109, 8, @on
exec sp_trace_setevent @TraceID, 109, 10, @on
exec sp_trace_setevent @TraceID, 109, 14, @on
exec sp_trace_setevent @TraceID, 109, 21, @on
exec sp_trace_setevent @TraceID, 109, 26, @on
exec sp_trace_setevent @TraceID, 109, 28, @on
exec sp_trace_setevent @TraceID, 109, 35, @on
exec sp_trace_setevent @TraceID, 109, 37, @on
exec sp_trace_setevent @TraceID, 109, 38, @on
exec sp_trace_setevent @TraceID, 109, 41, @on
exec sp_trace_setevent @TraceID, 109, 42, @on
exec sp_trace_setevent @TraceID, 109, 43, @on
exec sp_trace_setevent @TraceID, 109, 64, @on

-- 108 | Audit Add Login to Server Role | 
-- Event Occurs when a login is added or removed from a fixed server role; for sp_addsrvrolemember, and sp_dropsrvrolemember. 
exec sp_trace_setevent @TraceID, 108, 1, @on
exec sp_trace_setevent @TraceID, 108, 3, @on
exec sp_trace_setevent @TraceID, 108, 11, @on
exec sp_trace_setevent @TraceID, 108, 6, @on
exec sp_trace_setevent @TraceID, 108, 8, @on
exec sp_trace_setevent @TraceID, 108, 10, @on
exec sp_trace_setevent @TraceID, 108, 12, @on
exec sp_trace_setevent @TraceID, 108, 14, @on
exec sp_trace_setevent @TraceID, 108, 21, @on
exec sp_trace_setevent @TraceID, 108, 26, @on
exec sp_trace_setevent @TraceID, 108, 28, @on
exec sp_trace_setevent @TraceID, 108, 34, @on
exec sp_trace_setevent @TraceID, 108, 35, @on
exec sp_trace_setevent @TraceID, 108, 37, @on
exec sp_trace_setevent @TraceID, 108, 38, @on
exec sp_trace_setevent @TraceID, 108, 41, @on
exec sp_trace_setevent @TraceID, 108, 42, @on
exec sp_trace_setevent @TraceID, 108, 43, @on
exec sp_trace_setevent @TraceID, 108, 64, @on

-- 110 | Audit Add Member to DB Role | 
-- Event Occurs when a login is added or removed as a database user (fixed or user-defined) to a database; 
-- for sp_addrolemember, sp_droprolemember, and sp_changegroup. 
exec sp_trace_setevent @TraceID, 110, 1, @on
exec sp_trace_setevent @TraceID, 110, 3, @on
exec sp_trace_setevent @TraceID, 110, 11, @on
exec sp_trace_setevent @TraceID, 110, 6, @on
exec sp_trace_setevent @TraceID, 110, 8, @on
exec sp_trace_setevent @TraceID, 110, 10, @on
exec sp_trace_setevent @TraceID, 110, 12, @on
exec sp_trace_setevent @TraceID, 110, 14, @on
exec sp_trace_setevent @TraceID, 110, 21, @on
exec sp_trace_setevent @TraceID, 110, 26, @on
exec sp_trace_setevent @TraceID, 110, 28, @on
exec sp_trace_setevent @TraceID, 110, 34, @on
exec sp_trace_setevent @TraceID, 110, 35, @on
exec sp_trace_setevent @TraceID, 110, 37, @on
exec sp_trace_setevent @TraceID, 110, 38, @on
exec sp_trace_setevent @TraceID, 110, 41, @on
exec sp_trace_setevent @TraceID, 110, 42, @on
exec sp_trace_setevent @TraceID, 110, 43, @on
exec sp_trace_setevent @TraceID, 110, 64, @on

-- 111 | Audit Add Role | 
-- Event Occurs when a login is added or removed as a database user to a database; for sp_addrole and sp_droprole. 
exec sp_trace_setevent @TraceID, 111, 3, @on
exec sp_trace_setevent @TraceID, 111, 11, @on
exec sp_trace_setevent @TraceID, 111, 12, @on
exec sp_trace_setevent @TraceID, 111, 6, @on
exec sp_trace_setevent @TraceID, 111, 8, @on
exec sp_trace_setevent @TraceID, 111, 10, @on
exec sp_trace_setevent @TraceID, 111, 14, @on
exec sp_trace_setevent @TraceID, 111, 21, @on
exec sp_trace_setevent @TraceID, 111, 26, @on
exec sp_trace_setevent @TraceID, 111, 28, @on
exec sp_trace_setevent @TraceID, 111, 35, @on
exec sp_trace_setevent @TraceID, 111, 38, @on
exec sp_trace_setevent @TraceID, 111, 41, @on
exec sp_trace_setevent @TraceID, 111, 64, @on

-- 104 | Audit AddLogin | 
-- Event Occurs when a SQL Server login is added or removed; for sp_addlogin and sp_droplogin. 
exec sp_trace_setevent @TraceID, 104, 3, @on
exec sp_trace_setevent @TraceID, 104, 11, @on
exec sp_trace_setevent @TraceID, 104, 6, @on
exec sp_trace_setevent @TraceID, 104, 8, @on
exec sp_trace_setevent @TraceID, 104, 10, @on
exec sp_trace_setevent @TraceID, 104, 12, @on
exec sp_trace_setevent @TraceID, 104, 14, @on
exec sp_trace_setevent @TraceID, 104, 21, @on
exec sp_trace_setevent @TraceID, 104, 26, @on
exec sp_trace_setevent @TraceID, 104, 28, @on
exec sp_trace_setevent @TraceID, 104, 35, @on
exec sp_trace_setevent @TraceID, 104, 41, @on
exec sp_trace_setevent @TraceID, 104, 42, @on
exec sp_trace_setevent @TraceID, 104, 43, @on
exec sp_trace_setevent @TraceID, 104, 64, @on

-- 112 | Audit App Role Change Password |
-- Event Occurs when a password of an application role is changed. 
exec sp_trace_setevent @TraceID, 112, 1, @on
exec sp_trace_setevent @TraceID, 112, 3, @on
exec sp_trace_setevent @TraceID, 112, 11, @on
exec sp_trace_setevent @TraceID, 112, 6, @on
exec sp_trace_setevent @TraceID, 112, 8, @on
exec sp_trace_setevent @TraceID, 112, 10, @on
exec sp_trace_setevent @TraceID, 112, 12, @on
exec sp_trace_setevent @TraceID, 112, 14, @on
exec sp_trace_setevent @TraceID, 112, 26, @on
exec sp_trace_setevent @TraceID, 112, 28, @on
exec sp_trace_setevent @TraceID, 112, 34, @on
exec sp_trace_setevent @TraceID, 112, 35, @on
exec sp_trace_setevent @TraceID, 112, 37, @on
exec sp_trace_setevent @TraceID, 112, 38, @on
exec sp_trace_setevent @TraceID, 112, 41, @on
exec sp_trace_setevent @TraceID, 112, 64, @on

-- 117 Audit Change Audit 
-- Event Occurs when audit trace modifications are made. 
exec sp_trace_setevent @TraceID, 117, 1, @on
exec sp_trace_setevent @TraceID, 117, 3, @on
exec sp_trace_setevent @TraceID, 117, 11, @on
exec sp_trace_setevent @TraceID, 117, 6, @on
exec sp_trace_setevent @TraceID, 117, 8, @on
exec sp_trace_setevent @TraceID, 117, 10, @on
exec sp_trace_setevent @TraceID, 117, 12, @on
exec sp_trace_setevent @TraceID, 117, 14, @on
exec sp_trace_setevent @TraceID, 117, 21, @on
exec sp_trace_setevent @TraceID, 117, 26, @on
exec sp_trace_setevent @TraceID, 117, 35, @on
exec sp_trace_setevent @TraceID, 117, 37, @on
exec sp_trace_setevent @TraceID, 117, 41, @on
exec sp_trace_setevent @TraceID, 117, 64, @on

-- 152 | Audit Change Database Owner | 
-- Occurs when ALTER AUTHORIZATION is used to change the owner of a database and permissions are checked to do that. 
exec sp_trace_setevent @TraceID, 152, 1, @on
exec sp_trace_setevent @TraceID, 152, 3, @on
exec sp_trace_setevent @TraceID, 152, 11, @on
exec sp_trace_setevent @TraceID, 152, 6, @on
exec sp_trace_setevent @TraceID, 152, 8, @on
exec sp_trace_setevent @TraceID, 152, 10, @on
exec sp_trace_setevent @TraceID, 152, 12, @on
exec sp_trace_setevent @TraceID, 152, 14, @on
exec sp_trace_setevent @TraceID, 152, 26, @on
exec sp_trace_setevent @TraceID, 152, 28, @on
exec sp_trace_setevent @TraceID, 152, 34, @on
exec sp_trace_setevent @TraceID, 152, 35, @on
exec sp_trace_setevent @TraceID, 152, 37, @on
exec sp_trace_setevent @TraceID, 152, 41, @on
exec sp_trace_setevent @TraceID, 152, 42, @on
exec sp_trace_setevent @TraceID, 152, 43, @on
exec sp_trace_setevent @TraceID, 152, 64, @on

-- 128 | Audit Database Management | 
-- Event Occurs when a database is created, altered, or dropped. 
exec sp_trace_setevent @TraceID, 128, 1, @on
exec sp_trace_setevent @TraceID, 128, 3, @on
exec sp_trace_setevent @TraceID, 128, 11, @on
exec sp_trace_setevent @TraceID, 128, 12, @on
exec sp_trace_setevent @TraceID, 128, 6, @on
exec sp_trace_setevent @TraceID, 128, 8, @on
exec sp_trace_setevent @TraceID, 128, 10, @on
exec sp_trace_setevent @TraceID, 128, 14, @on
exec sp_trace_setevent @TraceID, 128, 21, @on
exec sp_trace_setevent @TraceID, 128, 26, @on
exec sp_trace_setevent @TraceID, 128, 28, @on
exec sp_trace_setevent @TraceID, 128, 34, @on
exec sp_trace_setevent @TraceID, 128, 35, @on
exec sp_trace_setevent @TraceID, 128, 37, @on
exec sp_trace_setevent @TraceID, 128, 41, @on
exec sp_trace_setevent @TraceID, 128, 64, @on

-- 172 Audit Database Object GDR Event Indicates that a grant, deny, or revoke event for database objects, 
-- such as assemblies and schemas, occurred. 
exec sp_trace_setevent @TraceID, 172, 1, @on
exec sp_trace_setevent @TraceID, 172, 10, @on
exec sp_trace_setevent @TraceID, 172, 3, @on
exec sp_trace_setevent @TraceID, 172, 6, @on
exec sp_trace_setevent @TraceID, 172, 8, @on
exec sp_trace_setevent @TraceID, 172, 11, @on
exec sp_trace_setevent @TraceID, 172, 12, @on
exec sp_trace_setevent @TraceID, 172, 14, @on
exec sp_trace_setevent @TraceID, 172, 19, @on
exec sp_trace_setevent @TraceID, 172, 21, @on
exec sp_trace_setevent @TraceID, 172, 26, @on
exec sp_trace_setevent @TraceID, 172, 28, @on
exec sp_trace_setevent @TraceID, 172, 34, @on
exec sp_trace_setevent @TraceID, 172, 35, @on
exec sp_trace_setevent @TraceID, 172, 37, @on
exec sp_trace_setevent @TraceID, 172, 41, @on
exec sp_trace_setevent @TraceID, 172, 42, @on
exec sp_trace_setevent @TraceID, 172, 43, @on
exec sp_trace_setevent @TraceID, 172, 64, @on

-- 135 | Audit Database Object Take Ownership | 
-- Event Occurs when a change of owner for objects within database scope occurs. 
exec sp_trace_setevent @TraceID, 135, 1, @on
exec sp_trace_setevent @TraceID, 135, 3, @on
exec sp_trace_setevent @TraceID, 135, 11, @on
exec sp_trace_setevent @TraceID, 135, 12, @on
exec sp_trace_setevent @TraceID, 135, 6, @on
exec sp_trace_setevent @TraceID, 135, 8, @on
exec sp_trace_setevent @TraceID, 135, 10, @on
exec sp_trace_setevent @TraceID, 135, 14, @on
exec sp_trace_setevent @TraceID, 135, 26, @on
exec sp_trace_setevent @TraceID, 135, 28, @on
exec sp_trace_setevent @TraceID, 135, 34, @on
exec sp_trace_setevent @TraceID, 135, 35, @on
exec sp_trace_setevent @TraceID, 135, 37, @on
exec sp_trace_setevent @TraceID, 135, 41, @on
exec sp_trace_setevent @TraceID, 135, 64, @on

-- 133 | Audit Database Principal Impersonation | 
-- Event Occurs when an impersonation occurs within the database scope, such as EXECUTE AS USER or SETUSER. 
exec sp_trace_setevent @TraceID, 133, 1, @on
exec sp_trace_setevent @TraceID, 133, 10, @on
exec sp_trace_setevent @TraceID, 133, 3, @on
exec sp_trace_setevent @TraceID, 133, 11, @on
exec sp_trace_setevent @TraceID, 133, 6, @on
exec sp_trace_setevent @TraceID, 133, 8, @on
exec sp_trace_setevent @TraceID, 133, 12, @on
exec sp_trace_setevent @TraceID, 133, 14, @on
exec sp_trace_setevent @TraceID, 133, 19, @on
exec sp_trace_setevent @TraceID, 133, 21, @on
exec sp_trace_setevent @TraceID, 133, 26, @on
exec sp_trace_setevent @TraceID, 133, 28, @on
exec sp_trace_setevent @TraceID, 133, 34, @on
exec sp_trace_setevent @TraceID, 133, 35, @on
exec sp_trace_setevent @TraceID, 133, 37, @on
exec sp_trace_setevent @TraceID, 133, 38, @on
exec sp_trace_setevent @TraceID, 133, 41, @on
exec sp_trace_setevent @TraceID, 133, 64, @on

-- 130 | Audit Database Principal Management |
-- Event Occurs when principals, such as users, are created, altered, or dropped from a database. 
exec sp_trace_setevent @TraceID, 130, 1, @on
exec sp_trace_setevent @TraceID, 130, 3, @on
exec sp_trace_setevent @TraceID, 130, 11, @on
exec sp_trace_setevent @TraceID, 130, 12, @on
exec sp_trace_setevent @TraceID, 130, 6, @on
exec sp_trace_setevent @TraceID, 130, 8, @on
exec sp_trace_setevent @TraceID, 130, 10, @on
exec sp_trace_setevent @TraceID, 130, 14, @on
exec sp_trace_setevent @TraceID, 130, 21, @on
exec sp_trace_setevent @TraceID, 130, 26, @on
exec sp_trace_setevent @TraceID, 130, 28, @on
exec sp_trace_setevent @TraceID, 130, 34, @on
exec sp_trace_setevent @TraceID, 130, 35, @on
exec sp_trace_setevent @TraceID, 130, 37, @on
exec sp_trace_setevent @TraceID, 130, 41, @on
exec sp_trace_setevent @TraceID, 130, 42, @on
exec sp_trace_setevent @TraceID, 130, 43, @on
exec sp_trace_setevent @TraceID, 130, 64, @on

-- 102 | Audit Database Scope GDR |
-- Occurs every time a GRANT, DENY, REVOKE for a statement permission is issued by any user in SQL Server 
-- for database-only actions such as granting permissions on a database. 
exec sp_trace_setevent @TraceID, 102, 1, @on
exec sp_trace_setevent @TraceID, 102, 3, @on
exec sp_trace_setevent @TraceID, 102, 6, @on
exec sp_trace_setevent @TraceID, 102, 8, @on
exec sp_trace_setevent @TraceID, 102, 10, @on
exec sp_trace_setevent @TraceID, 102, 11, @on
exec sp_trace_setevent @TraceID, 102, 12, @on
exec sp_trace_setevent @TraceID, 102, 14, @on
exec sp_trace_setevent @TraceID, 102, 19, @on
exec sp_trace_setevent @TraceID, 102, 21, @on
exec sp_trace_setevent @TraceID, 102, 26, @on
exec sp_trace_setevent @TraceID, 102, 28, @on
exec sp_trace_setevent @TraceID, 102, 34, @on
exec sp_trace_setevent @TraceID, 102, 35, @on
exec sp_trace_setevent @TraceID, 102, 37, @on
exec sp_trace_setevent @TraceID, 102, 41, @on
exec sp_trace_setevent @TraceID, 102, 42, @on
exec sp_trace_setevent @TraceID, 102, 43, @on
exec sp_trace_setevent @TraceID, 102, 64, @on

-- 14 | Audit Login |
-- Occurs when a user successfully logs in to SQL Server. 
exec sp_trace_setevent @TraceID, 14, 1, @on
exec sp_trace_setevent @TraceID, 14, 10, @on
exec sp_trace_setevent @TraceID, 14, 3, @on
exec sp_trace_setevent @TraceID, 14, 11, @on
exec sp_trace_setevent @TraceID, 14, 6, @on
exec sp_trace_setevent @TraceID, 14, 8, @on
exec sp_trace_setevent @TraceID, 14, 12, @on
exec sp_trace_setevent @TraceID, 14, 14, @on
exec sp_trace_setevent @TraceID, 14, 21, @on
exec sp_trace_setevent @TraceID, 14, 26, @on
exec sp_trace_setevent @TraceID, 14, 35, @on
exec sp_trace_setevent @TraceID, 14, 41, @on
exec sp_trace_setevent @TraceID, 14, 64, @on

-- 20 | Audit Login Failed |
-- Indicates that a login attempt to SQL Server from a client failed. 
exec sp_trace_setevent @TraceID, 20, 1, @on
exec sp_trace_setevent @TraceID, 20, 3, @on
exec sp_trace_setevent @TraceID, 20, 11, @on
exec sp_trace_setevent @TraceID, 20, 6, @on
exec sp_trace_setevent @TraceID, 20, 8, @on
exec sp_trace_setevent @TraceID, 20, 10, @on
exec sp_trace_setevent @TraceID, 20, 12, @on
exec sp_trace_setevent @TraceID, 20, 14, @on
exec sp_trace_setevent @TraceID, 20, 21, @on
exec sp_trace_setevent @TraceID, 20, 26, @on
exec sp_trace_setevent @TraceID, 20, 35, @on
exec sp_trace_setevent @TraceID, 20, 64, @on

-- 105 | Audit Login GDR Event |
-- Occurs when a Windows login right is added or removed; for sp_grantlogin, sp_revokelogin, and sp_denylogin. 
exec sp_trace_setevent @TraceID, 105, 3, @on
exec sp_trace_setevent @TraceID, 105, 11, @on
exec sp_trace_setevent @TraceID, 105, 12, @on
exec sp_trace_setevent @TraceID, 105, 6, @on
exec sp_trace_setevent @TraceID, 105, 8, @on
exec sp_trace_setevent @TraceID, 105, 10, @on
exec sp_trace_setevent @TraceID, 105, 14, @on
exec sp_trace_setevent @TraceID, 105, 21, @on
exec sp_trace_setevent @TraceID, 105, 26, @on
exec sp_trace_setevent @TraceID, 105, 28, @on
exec sp_trace_setevent @TraceID, 105, 35, @on
exec sp_trace_setevent @TraceID, 105, 41, @on
exec sp_trace_setevent @TraceID, 105, 42, @on
exec sp_trace_setevent @TraceID, 105, 43, @on
exec sp_trace_setevent @TraceID, 105, 64, @on

-- 15 | udit Logout | 
-- Occurs when a user logs out of SQL Server. 
exec sp_trace_setevent @TraceID, 15, 3, @on
exec sp_trace_setevent @TraceID, 15, 11, @on
exec sp_trace_setevent @TraceID, 15, 6, @on
exec sp_trace_setevent @TraceID, 15, 8, @on
exec sp_trace_setevent @TraceID, 15, 10, @on
exec sp_trace_setevent @TraceID, 15, 12, @on
exec sp_trace_setevent @TraceID, 15, 14, @on
exec sp_trace_setevent @TraceID, 15, 21, @on
exec sp_trace_setevent @TraceID, 15, 26, @on
exec sp_trace_setevent @TraceID, 15, 35, @on
exec sp_trace_setevent @TraceID, 15, 41, @on
exec sp_trace_setevent @TraceID, 15, 64, @on

-- 103 | Audit Object GDR Event |
-- Occurs every time a GRANT, DENY, REVOKE for an object permission is issued by any user in SQL Server. 
exec sp_trace_setevent @TraceID, 103, 1, @on
exec sp_trace_setevent @TraceID, 103, 3, @on
exec sp_trace_setevent @TraceID, 103, 6, @on
exec sp_trace_setevent @TraceID, 103, 8, @on
exec sp_trace_setevent @TraceID, 103, 10, @on
exec sp_trace_setevent @TraceID, 103, 11, @on
exec sp_trace_setevent @TraceID, 103, 12, @on
exec sp_trace_setevent @TraceID, 103, 14, @on
exec sp_trace_setevent @TraceID, 103, 19, @on
exec sp_trace_setevent @TraceID, 103, 21, @on
exec sp_trace_setevent @TraceID, 103, 26, @on
exec sp_trace_setevent @TraceID, 103, 28, @on
exec sp_trace_setevent @TraceID, 103, 34, @on
exec sp_trace_setevent @TraceID, 103, 35, @on
exec sp_trace_setevent @TraceID, 103, 37, @on
exec sp_trace_setevent @TraceID, 103, 41, @on
exec sp_trace_setevent @TraceID, 103, 42, @on
exec sp_trace_setevent @TraceID, 103, 43, @on
exec sp_trace_setevent @TraceID, 103, 64, @on

-- 131 | Audit Schema Object Management | 
-- Event Occurs when server objects are created, altered, or dropped. 
exec sp_trace_setevent @TraceID, 131, 1, @on
exec sp_trace_setevent @TraceID, 131, 3, @on
exec sp_trace_setevent @TraceID, 131, 11, @on
exec sp_trace_setevent @TraceID, 131, 12, @on
exec sp_trace_setevent @TraceID, 131, 6, @on
exec sp_trace_setevent @TraceID, 131, 8, @on
exec sp_trace_setevent @TraceID, 131, 10, @on
exec sp_trace_setevent @TraceID, 131, 14, @on
exec sp_trace_setevent @TraceID, 131, 21, @on
exec sp_trace_setevent @TraceID, 131, 26, @on
exec sp_trace_setevent @TraceID, 131, 28, @on
exec sp_trace_setevent @TraceID, 131, 34, @on
exec sp_trace_setevent @TraceID, 131, 35, @on
exec sp_trace_setevent @TraceID, 131, 37, @on
exec sp_trace_setevent @TraceID, 131, 41, @on
exec sp_trace_setevent @TraceID, 131, 64, @on

-- 153 | Audit Schema Object Take Ownership | 
-- Event Occurs when ALTER AUTHORIZATION is used to assign an owner 
--to an object and permissions are checked to do that. 
exec sp_trace_setevent @TraceID, 153, 1, @on
exec sp_trace_setevent @TraceID, 153, 3, @on
exec sp_trace_setevent @TraceID, 153, 11, @on
exec sp_trace_setevent @TraceID, 153, 12, @on
exec sp_trace_setevent @TraceID, 153, 6, @on
exec sp_trace_setevent @TraceID, 153, 8, @on
exec sp_trace_setevent @TraceID, 153, 10, @on
exec sp_trace_setevent @TraceID, 153, 14, @on
exec sp_trace_setevent @TraceID, 153, 26, @on
exec sp_trace_setevent @TraceID, 153, 28, @on
exec sp_trace_setevent @TraceID, 153, 34, @on
exec sp_trace_setevent @TraceID, 153, 35, @on
exec sp_trace_setevent @TraceID, 153, 37, @on
exec sp_trace_setevent @TraceID, 153, 41, @on
exec sp_trace_setevent @TraceID, 153, 42, @on
exec sp_trace_setevent @TraceID, 153, 43, @on
exec sp_trace_setevent @TraceID, 153, 64, @on

-- 171 | Audit Server Object GDR | 
-- Event Indicates that a grant, deny, or revoke event for a schema object, such as a table or function, occurred. 
exec sp_trace_setevent @TraceID, 171, 1, @on
exec sp_trace_setevent @TraceID, 171, 10, @on
exec sp_trace_setevent @TraceID, 171, 3, @on
exec sp_trace_setevent @TraceID, 171, 6, @on
exec sp_trace_setevent @TraceID, 171, 8, @on
exec sp_trace_setevent @TraceID, 171, 11, @on
exec sp_trace_setevent @TraceID, 171, 12, @on
exec sp_trace_setevent @TraceID, 171, 14, @on
exec sp_trace_setevent @TraceID, 171, 19, @on
exec sp_trace_setevent @TraceID, 171, 21, @on
exec sp_trace_setevent @TraceID, 171, 26, @on
exec sp_trace_setevent @TraceID, 171, 28, @on
exec sp_trace_setevent @TraceID, 171, 34, @on
exec sp_trace_setevent @TraceID, 171, 35, @on
exec sp_trace_setevent @TraceID, 171, 37, @on
exec sp_trace_setevent @TraceID, 171, 41, @on
exec sp_trace_setevent @TraceID, 171, 42, @on
exec sp_trace_setevent @TraceID, 171, 43, @on
exec sp_trace_setevent @TraceID, 171, 64, @on

-- 176 | Audit Server Object Management | 
-- Event Occurs when server objects are created, altered, or dropped. 
exec sp_trace_setevent @TraceID, 176, 1, @on
exec sp_trace_setevent @TraceID, 176, 3, @on
exec sp_trace_setevent @TraceID, 176, 11, @on
exec sp_trace_setevent @TraceID, 176, 6, @on
exec sp_trace_setevent @TraceID, 176, 8, @on
exec sp_trace_setevent @TraceID, 176, 10, @on
exec sp_trace_setevent @TraceID, 176, 12, @on
exec sp_trace_setevent @TraceID, 176, 14, @on
exec sp_trace_setevent @TraceID, 176, 21, @on
exec sp_trace_setevent @TraceID, 176, 26, @on
exec sp_trace_setevent @TraceID, 176, 28, @on
exec sp_trace_setevent @TraceID, 176, 34, @on
exec sp_trace_setevent @TraceID, 176, 35, @on
exec sp_trace_setevent @TraceID, 176, 37, @on
exec sp_trace_setevent @TraceID, 176, 41, @on
exec sp_trace_setevent @TraceID, 176, 64, @on

-- 134 | Audit Server Object Take Ownership | 
-- Event Occurs when the owner is changed for objects in server scope. 
exec sp_trace_setevent @TraceID, 134, 1, @on
exec sp_trace_setevent @TraceID, 134, 3, @on
exec sp_trace_setevent @TraceID, 134, 11, @on
exec sp_trace_setevent @TraceID, 134, 12, @on
exec sp_trace_setevent @TraceID, 134, 6, @on
exec sp_trace_setevent @TraceID, 134, 8, @on
exec sp_trace_setevent @TraceID, 134, 10, @on
exec sp_trace_setevent @TraceID, 134, 14, @on
exec sp_trace_setevent @TraceID, 134, 26, @on
exec sp_trace_setevent @TraceID, 134, 28, @on
exec sp_trace_setevent @TraceID, 134, 34, @on
exec sp_trace_setevent @TraceID, 134, 35, @on
exec sp_trace_setevent @TraceID, 134, 37, @on
exec sp_trace_setevent @TraceID, 134, 41, @on
exec sp_trace_setevent @TraceID, 134, 42, @on
exec sp_trace_setevent @TraceID, 134, 43, @on
exec sp_trace_setevent @TraceID, 134, 64, @on

-- 132 Audit Server Principal Impersonation | 
-- Event Occurs when there is an impersonation within server scope, such as EXECUTE AS LOGIN. 
exec sp_trace_setevent @TraceID, 132, 1, @on
exec sp_trace_setevent @TraceID, 132, 10, @on
exec sp_trace_setevent @TraceID, 132, 3, @on
exec sp_trace_setevent @TraceID, 132, 11, @on
exec sp_trace_setevent @TraceID, 132, 6, @on
exec sp_trace_setevent @TraceID, 132, 8, @on
exec sp_trace_setevent @TraceID, 132, 12, @on
exec sp_trace_setevent @TraceID, 132, 14, @on
exec sp_trace_setevent @TraceID, 132, 19, @on
exec sp_trace_setevent @TraceID, 132, 21, @on
exec sp_trace_setevent @TraceID, 132, 26, @on
exec sp_trace_setevent @TraceID, 132, 28, @on
exec sp_trace_setevent @TraceID, 132, 34, @on
exec sp_trace_setevent @TraceID, 132, 35, @on
exec sp_trace_setevent @TraceID, 132, 37, @on
exec sp_trace_setevent @TraceID, 132, 41, @on
exec sp_trace_setevent @TraceID, 132, 64, @on

-- 177 Audit Server Principal Management |
-- Event Occurs when server principals are created, altered, or dropped. 
exec sp_trace_setevent @TraceID, 177, 1, @on
exec sp_trace_setevent @TraceID, 177, 3, @on
exec sp_trace_setevent @TraceID, 177, 6, @on
exec sp_trace_setevent @TraceID, 177, 8, @on
exec sp_trace_setevent @TraceID, 177, 10, @on
exec sp_trace_setevent @TraceID, 177, 11, @on
exec sp_trace_setevent @TraceID, 177, 12, @on
exec sp_trace_setevent @TraceID, 177, 14, @on
exec sp_trace_setevent @TraceID, 177, 21, @on
exec sp_trace_setevent @TraceID, 177, 26, @on
exec sp_trace_setevent @TraceID, 177, 28, @on
exec sp_trace_setevent @TraceID, 177, 34, @on
exec sp_trace_setevent @TraceID, 177, 35, @on
exec sp_trace_setevent @TraceID, 177, 37, @on
exec sp_trace_setevent @TraceID, 177, 41, @on
exec sp_trace_setevent @TraceID, 177, 42, @on
exec sp_trace_setevent @TraceID, 177, 43, @on
exec sp_trace_setevent @TraceID, 177, 64, @on

-- 170 Audit Server Scope GDR |
--  Event Indicates that a grant, deny, or revoke event for permissions in server scope occurred, such as creating a login. 
exec sp_trace_setevent @TraceID, 170, 1, @on
exec sp_trace_setevent @TraceID, 170, 10, @on
exec sp_trace_setevent @TraceID, 170, 3, @on
exec sp_trace_setevent @TraceID, 170, 6, @on
exec sp_trace_setevent @TraceID, 170, 8, @on
exec sp_trace_setevent @TraceID, 170, 11, @on
exec sp_trace_setevent @TraceID, 170, 12, @on
exec sp_trace_setevent @TraceID, 170, 14, @on
exec sp_trace_setevent @TraceID, 170, 19, @on
exec sp_trace_setevent @TraceID, 170, 21, @on
exec sp_trace_setevent @TraceID, 170, 26, @on
exec sp_trace_setevent @TraceID, 170, 28, @on
exec sp_trace_setevent @TraceID, 170, 34, @on
exec sp_trace_setevent @TraceID, 170, 35, @on
exec sp_trace_setevent @TraceID, 170, 37, @on
exec sp_trace_setevent @TraceID, 170, 41, @on
exec sp_trace_setevent @TraceID, 170, 42, @on
exec sp_trace_setevent @TraceID, 170, 43, @on
exec sp_trace_setevent @TraceID, 170, 64, @on


-- Set the Filters
declare @intfilter int
declare @bigintfilter bigint

exec sp_trace_setfilter @TraceID, 10, 0, 7, N'SQLServerCEIP'
exec sp_trace_setfilter @TraceID, 10, 0, 7, N'SQL Server Profiler - e0642431-5945-4b99-88d6-446cd9e4e33f'
exec sp_trace_setfilter @TraceID, 11, 0, 6, N'intl\A%'
-- Set the trace status to start
exec sp_trace_setstatus @TraceID, 1

-- display trace id for future references
select TraceID=@TraceID
goto finish

error: 
select ErrorCode=@rc

finish: 
go




------------------------------------------------------------------------------------------------------------------

use fil_dba_tools
go
create or alter procedure audit.usp_Import_Trace_Audit_SQLServer
as
/*
	Author .........: Edvaldo Castro   
	Date ...........: May 2018
	Version ........: Initial v1.0      
	Purpose ........: Creates Trace Audit SQL Server  
	Comments .......: This SP creates trace file for auditing purpose.
						  
	Modifications ..:     

*/
--create a new trace file before deleting the old one, so no information is missed
declare @id_old int, @id_new int, @path_old varchar(300), @path_new varchar(300)
declare @c tinyint = (select count(*) from sys.traces where path like '%Trace_Audit_SQLServer_%')

if (@c = 0)
begin
	exec fil_dba_tools.audit.usp_create_Trace_Audit_SQLServer;
	;with cte_new
	as
	(
		select row_number() over(order by start_time desc) as RowNumber, ID, start_time, path from sys.traces where path like '%Trace_Audit_SQLServer_%' 	
	)
	select	 @id_new = id
			,@path_new = path
	FROM cte_new
	WHERE RowNumber = 1	
end
else if(@c >= 1)
	begin
		exec fil_dba_tools.audit.usp_create_Trace_Audit_SQLServer;
		;with cte_new
		as
		(
			select row_number() over(order by start_time desc) as RowNumber, ID, start_time, path from sys.traces where path like '%Trace_Audit_SQLServer_%' 	
		)
		select	 @id_new = id
				,@path_new = path
		FROM cte_new
		WHERE RowNumber = 1	

		;with cte_new
		as
		(
			select row_number() over(order by start_time desc) as RowNumber, ID, start_time, path from sys.traces where path like '%Trace_Audit_SQLServer_%' 	
		)
		select	 @id_old = id
				,@path_old = path
		FROM cte_new
		WHERE RowNumber = 2
	
		exec sp_trace_setstatus @id_old,0

		if object_id('fil_dba_tools.audit.Trace_Audit_SQLServer_Staging') is not null
			begin
					truncate table fil_dba_tools.audit.Trace_Audit_SQLServer_Staging
					insert into fil_dba_tools.audit.Trace_Audit_SQLServer_Staging
					select * from fn_trace_gettable(@path_old,default)
			end
			else
				begin
					select * into fil_dba_tools.audit.Trace_Audit_SQLServer_Staging
					from fn_trace_gettable(@path_old,default)

				end


		if object_id('fil_dba_tools.audit.Trace_Audit_SQLServer') is not null
			begin
				insert into fil_dba_tools.audit.Trace_Audit_SQLServer
				select   EventClass
						,ApplicationName
						,DatabaseID
						,DatabaseName
						,EventSubClass
						,Hostname
						,LoginName
						,LoginSID
						,NTUserName
						,ObjectType
						,OwnerName
						,RoleName
						,SPID
						,ServerName
						,SessionLoginName
						,StartTime
						,TargetLoginName
						,TargetLoginSID
						,ObjectName
						,TextData
						,Permissions
				from audit.Trace_Audit_SQLServer_Staging
				exec sp_trace_setstatus @id_old,2
			end
			else
			begin
				select   EventClass
						,ApplicationName
						,DatabaseID
						,DatabaseName
						,EventSubClass
						,Hostname
						,LoginName
						,LoginSID
						,NTUserName
						,ObjectType
						,OwnerName
						,RoleName
						,SPID
						,ServerName
						,SessionLoginName
						,StartTime
						,TargetLoginName
						,TargetLoginSID
						,ObjectName
						,TextData
						,Permissions
				into fil_dba_tools.audit.Trace_Audit_SQLServer
				from audit.Trace_Audit_SQLServer_Staging

				alter table fil_dba_tools.audit.Trace_Audit_SQLServer rebuild with (data_compression = page)
				
				exec sp_trace_setstatus @id_old,2

			end

--audit.usp_Import_Trace_Audit_SQLServer
--select count(*) from fil_dba_tools.audit.Trace_Audit_SQLServer

	end
go
------------------------------------------------------------------------------------------------------------------

--COPYING THE SELECTED COLUMNS FROM THE STAGING TABLE TO THE PRODUCTION ONE.
DROP TABLE IF EXISTS fil_dba_tools.audit.Trace_Audit_SQLServer
CREATE TABLE fil_dba_tools.audit.Trace_Audit_SQLServer
(
	EventClass int
	,ApplicationName nvarchar(512)
	,DatabaseID int
	,DatabaseName nvarchar(512)
	,EventSubClass int
	,Hostname nvarchar(512)
	,LoginName nvarchar(512)
	,LoginSID image
	,NTUserName nvarchar(512)
	,ObjectType int
	,OwnerName nvarchar(512)
	,RoleName nvarchar(512)
	,SPID int
	,ServerName nvarchar(512)
	,SessionLoginName nvarchar(512)
	,StartTime datetime
	,TargetLoginName nvarchar(512)
	,TargetLoginSID image
	,ObjectName nvarchar(512)
	,TextData Text
	,Permissions Bigint
) with (data_compression = page)
GO

------------------------------------------------------------------------------------------------------------------
USE [msdb]
GO

if (select 1 from msdb..sysjobs where name = 'FILDBA - Auditing SQL Server') is not null
	EXEC msdb.dbo.sp_delete_job @job_name=N'FILDBA - Auditing SQL Server', @delete_unused_schedule=1
GO



USE [msdb]
GO

/****** Object:  Job [FILDBA - Auditing SQL Server]    Script Date: 25/05/2018 13:42:09 ******/
BEGIN TRANSACTION
DECLARE @ReturnCode INT
SELECT @ReturnCode = 0
/****** Object:  JobCategory [Database Maintenance]    Script Date: 25/05/2018 13:42:10 ******/
IF NOT EXISTS (SELECT name FROM msdb.dbo.syscategories WHERE name=N'Database Maintenance' AND category_class=1)
BEGIN
EXEC @ReturnCode = msdb.dbo.sp_add_category @class=N'JOB', @type=N'LOCAL', @name=N'Database Maintenance'
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback

END

DECLARE @jobId BINARY(16)
declare @owner_name varchar(25)
select @owner_name = name from sys.server_principals where sid = 0x01
EXEC @ReturnCode =  msdb.dbo.sp_add_job @job_name=N'FILDBA - Auditing SQL Server', 
		@enabled=1, 
		@notify_level_eventlog=0, 
		@notify_level_email=0, 
		@notify_level_netsend=0, 
		@notify_level_page=0, 
		@delete_level=0, 
		@description=N'Job created as part of Auditing.', 
		@category_name=N'Database Maintenance',
		--@owner_login_name=N'audited_0x01_audited', 
		@owner_login_name = @owner_name,
		@job_id = @jobId OUTPUT

IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
/****** Object:  Step [FILDBA - Step 1 - Import Data from Trace File]    Script Date: 25/05/2018 13:42:10 ******/
EXEC @ReturnCode = msdb.dbo.sp_add_jobstep @job_id=@jobId, @step_name=N'FILDBA - Step 1 - Import Data from Trace File', 
		@step_id=1, 
		@cmdexec_success_code=0, 
		@on_success_action=1, 
		@on_success_step_id=0, 
		@on_fail_action=2, 
		@on_fail_step_id=0, 
		@retry_attempts=0, 
		@retry_interval=0, 
		@os_run_priority=0, @subsystem=N'TSQL', 
		@command=N'Exec audit.usp_Import_Trace_Audit_SQLServer', 
		@database_name=N'fil_dba_tools', 
		@flags=0
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_update_job @job_id = @jobId, @start_step_id = 1
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback

declare @startdate int = (select cast(replace(CONVERT(varchar(30),getdate(),102),'.','') as int))

EXEC @ReturnCode = msdb.dbo.sp_add_jobschedule @job_id=@jobId, @name=N'FILDBA - Schedule 1 - Hourly', 
		@enabled=1, 
		@freq_type=4, 
		@freq_interval=1, 
		@freq_subday_type=8, 
		@freq_subday_interval=1, 
		@freq_relative_interval=0, 
		@freq_recurrence_factor=0, 
		@active_start_date=@startdate, 
		@active_end_date=99991231, 
		@active_start_time=0, 
		@active_end_time=235959, 
		@schedule_uid=N'660c558e-6444-4a33-9caf-cd355f086465'
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_add_jobserver @job_id = @jobId, @server_name = N'(local)'
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
COMMIT TRANSACTION
GOTO EndSave
QuitWithRollback:
    IF (@@TRANCOUNT > 0) ROLLBACK TRANSACTION
EndSave:
GO


