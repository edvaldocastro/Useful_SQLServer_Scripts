--search for backups
declare @startSearchingDate datetime = getdate() - 30
declare @FinishSearchingDate datetime = getdate() 
select bs.database_name, bs.type, bs.backup_finish_date,bmf.physical_device_name,bs.backup_size,* 
  from msdb..backupset bs
  join msdb..backupmediafamily bmf
    on bs.media_set_id = bmf.media_set_id
 where 1=1 
   --and database_name = 'master'
   and bs.type in ('D','I','L')
   and bs.backup_finish_date between @startSearchingDate and @FinishSearchingDate
 order by bs.backup_finish_date desc
