use fil_dba_tools
go
create or alter procedure audit.usp_Import_Trace_Audit_SQLServer
as
/*********************************************************************************************************
	Author ......... Edvaldo Castro   
	Date ........... May 2018
	Version ........ Initial v1.0      
	Purpose ........ Creates Trace Audit SQL Server  
	Comments ....... This SP creates trace file for auditing purpose.
						  
	Modifications ..     
*********************************************************************************************************/

--create a new trace file before deleting the old one, so no information is missed
declare @id_old int, @id_new int, @path_old varchar(300), @path_new varchar(300)
declare @c tinyint = (select count() from sys.traces where path like '%Trace_Audit_SQLServer_%')

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
else if(@c = 1)
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
					select  from fn_trace_gettable(@path_old,default)
			end
			else
				begin
					select  into fil_dba_tools.audit.Trace_Audit_SQLServer_Staging
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

				print 'the table was already there'
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
				print 'the table has been created'
				
				exec sp_trace_setstatus @id_old,2

			end

--    select  from sys.traces
--    exec audit.usp_Import_Trace_Audit_SQLServer
--    select  from sys.traces

--    select count() from fil_dba_tools.audit.Trace_Audit_SQLServer
--    select  from fil_dba_tools.audit.Trace_Audit_SQLServer
--    select count() from fil_dba_tools.audit.Trace_Audit_SQLServer_Staging

	end
	
