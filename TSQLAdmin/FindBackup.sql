--search for backups

declare @startSearchingDate datetime = getdate() - 30
declare @FinishSearchingDate datetime = getdate() 
 select bs.database_name, 
		bs.type, 
		datediff(minute,bs.backup_finish_date,bs.backup_start_date) as 'duration', 
		bs.backup_finish_date,
		bmf.physical_device_name,
		bs.backup_size,
		bs.expiration_date,
		bs.compatibility_level,
		bs.is_copy_only,
		bs.is_readonly,
		bs.recovery_model,
		bs.server_name,
		bs.user_name
   from msdb..backupset bs
   join msdb..backupmediafamily bmf
     on bs.media_set_id = bmf.media_set_id
  where 1=1 
    and database_name not in('master','model','msdb')
    and bs.type in ('D','I')
    and bs.backup_finish_date between @startSearchingDate and @FinishSearchingDate
  order by bs.backup_finish_date desc
