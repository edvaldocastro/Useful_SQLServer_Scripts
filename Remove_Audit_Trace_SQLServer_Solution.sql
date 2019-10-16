use master
go
if exists (select * from msdb..sysjobs where name = N'FILDBA - Auditing SQL Server')
	EXEC msdb.dbo.sp_delete_job @job_name=N'FILDBA - Auditing SQL Server', @delete_unused_schedule=1
go

use master
go
declare @id int = ( select id from sys.traces where path like '%Trace_Audit_SQLServer%')
if @id > 1
	begin
		exec  sp_trace_setstatus @id,0
		exec  sp_trace_setstatus @id,2
	end
go

use fil_dba_tools
go
drop procedure if exists [audit].[usp_create_Trace_Audit_SQLServer] 
drop procedure  if exists [audit].[usp_Import_Trace_Audit_SQLServer ]
go

use fil_dba_tools
go
drop table if exists audit.Trace_Audit_SQLServer_Staging
drop table if exists [audit].[Trace_Audit_SQLServer]