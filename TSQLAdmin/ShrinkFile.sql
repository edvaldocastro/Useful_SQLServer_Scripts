
--https://www.sqlshack.com/shrinking-your-database-using-dbcc-shrinkfile/
 
DECLARE @FileName sysname = N'MSDBData';
DECLARE @TargetSize INT = (SELECT 1 + size*8./1024 FROM sys.database_files WHERE name = @FileName);
--DECLARE @Factor FLOAT = .999;
DECLARE @Factor FLOAT = .019;   -- 1/dbsize will give you a load factor that shrinks around 1GB per loop
 
WHILE @TargetSize > 0
BEGIN
    SET @TargetSize *= @Factor;
    DBCC SHRINKFILE(@FileName, @TargetSize);
    DECLARE @msg VARCHAR(200) = CONCAT('Shrink file completed. Target Size: ', 
         @TargetSize, ' MB. Timestamp: ', CURRENT_TIMESTAMP);
    RAISERROR(@msg, 1, 1) WITH NOWAIT;
    WAITFOR DELAY '00:00:01';
END;
