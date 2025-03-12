/*
	This script will show information about tables, indexes and statistics, and it will automatically run update statistics statements agains the whole database
	for tables with rowcount > 0.

	if the intention is only to list the information, run only the first part of the script.

	if the intention is to show the information and update statistics, run it all at once.


*/


SET NOCOUNT ON
SELECT distinct
	   o.object_id AS 'Object_id',
       s.name AS 'Schema',
       o.name AS 'Object_name',
       o.type_desc AS 'Object_type',
       i.index_id AS 'Index_id',
       i.name AS 'Index_name',
       p.rows,
       CAST(SUM(a.total_pages) * 8 AS NUMERIC(12, 2)) AS 'TotalSpaceKB',
       CAST(SUM(a.total_pages) * 8 / 1024. AS NUMERIC(12, 2)) AS 'TotalSpaceMB',
       STATS_DATE(o.object_id, st.stats_id) AS 'Stats date',
       STATS_DATE(i.object_id, i.index_id) AS 'Last updated',
       DATEDIFF(DAY, STATS_DATE(i.object_id, i.index_id), GETDATE()) AS 'Days since updated',
       -- 'UPDATE STATISTICS [' + s.name + '].[' + o.name + '] (' + st.name + ') WITH FULLSCAN;' AS 'Update Obj Stats'
	   'UPDATE STATISTICS ['+s.name+'].['+o.name+'] WITH FULLSCAN;' AS 'Update Obj Stats'
FROM sys.indexes i
    JOIN sys.objects o
        ON i.object_id = o.object_id
    JOIN sys.schemas s
        ON o.schema_id = s.schema_id
    JOIN sys.partitions p
        ON p.object_id = i.object_id
           AND i.index_id = p.index_id
    JOIN sys.allocation_units a
        ON a.container_id = p.partition_id
    JOIN sys.stats st
        ON st.object_id = o.object_id
           AND st.object_id = i.object_id
           AND st.object_id = p.object_id
GROUP BY o.object_id,
         s.name,
         o.name,
         o.type_desc,
         i.index_id,
         i.name,
         p.rows,
         i.object_id,
         o.type,
         st.stats_id,
         st.name
HAVING o.object_id > 255
       AND s.name <> 'sys'
       AND o.type IN ( 'S', 'U', 'V','IT' )
	   AND p.rows > 1000
ORDER BY rows, 
		STATS_DATE(i.object_id, i.index_id),
        STATS_DATE(o.object_id, st.stats_id);

/***************************************************************************************************************************************/
/***************************************************************************************************************************************/
/***************************************************************************************************************************************/
/***************************************************************************************************************************************/
/***************************************************************************************************************************************/
/***************************************************************************************************************************************/
/***************************************************************************************************************************************/


-- Create a temporary table to hold the commands
if object_id('tempdb..#tb_command') is not null
	drop table #tb_command
CREATE TABLE #tb_command (
    id INT IDENTITY(1,1),
    tsql_command NVARCHAR(MAX)
);

-- Insert sample commands into the temporary table
INSERT INTO #tb_command (tsql_command)
SELECT distinct 'UPDATE STATISTICS ['+s.name+'].['+o.name+'] WITH FULLSCAN;' AS 'Update Obj Stats'
FROM sys.indexes i JOIN sys.objects o ON i.object_id = o.object_id
    JOIN sys.schemas s ON o.schema_id = s.schema_id 
	JOIN sys.partitions p ON p.object_id = i.object_id AND i.index_id = p.index_id
    JOIN sys.allocation_units a ON a.container_id = p.partition_id
	JOIN sys.stats st ON st.object_id = o.object_id AND st.object_id = i.object_id AND st.object_id = p.object_id
GROUP BY o.object_id,s.name,o.name,o.type_desc,i.index_id,i.name,p.rows,i.object_id,o.type,st.stats_id,st.name
HAVING o.object_id > 255
       AND s.name <> 'sys'
       AND o.type IN ( 'S', 'U', 'V','IT' )
	   AND p.rows > 1000
--ORDER BY rows,STATS_DATE(i.object_id, i.index_id),STATS_DATE(o.object_id, st.stats_id);

-- Declare variables
DECLARE @command NVARCHAR(MAX);
DECLARE @id INT = 1;
DECLARE @rowCount INT = (SELECT COUNT(*) FROM #tb_command);

-- Loop through each row and execute the T-SQL command
WHILE @id <= @rowCount
BEGIN
    -- Retrieve the T-SQL command for the current row
    SET @command = (SELECT tsql_command FROM #tb_command WHERE id = @id);

    -- Execute the T-SQL command
	--print cast(cast(getdate() as smalldatetime) as varchar(20))+' - now executing: '+@command
    
	-- Display the current iteration message
    DECLARE @message VARCHAR(100);
    SET @message =convert(varchar(50),getdate(),113) + ' * now executing: ' + @command;
    RAISERROR('%s', 0, 1, @message) WITH NOWAIT;

	EXEC sp_executesql @command
	


    -- Move to the next row
    SET @id = @id + 1;
END;

-- Drop the temporary table
DROP TABLE #tb_command;
