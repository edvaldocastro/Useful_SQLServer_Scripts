--search for backups
declare @databaseName varchar(200) = 'msdb'
declare @type char(1) = 'D'
declare @startSearchingDate datetime = '2016-04-01 00:00:00.000'
declare @FinishSearchingDate datetime = '2016-05-10 23:59:59.665'

select bs.database_name, bs.type, bs.backup_finish_date,bs.backup_size, bmf.physical_device_name
  from msdb..backupset bs
  join msdb..backupmediafamily bmf
    on bs.media_set_id = bmf.media_set_id
where database_name = @databaseName
   and bs.type = @type
   and bs.backup_finish_date between @startSearchingDate and @FinishSearchingDate
