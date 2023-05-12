DECLARE @EmailRecipient NVARCHAR(255) = N'recipient@example.com';
DECLARE @EmailSubject NVARCHAR(255) = N'Partition Rebuild Script';
DECLARE @EmailBody NVARCHAR(MAX);

DECLARE @temp AS TABLE
(
    instancename VARCHAR(300),
    dbname sysname,
    schemaname VARCHAR(200),
    tablename VARCHAR(200),
    data_compression_desc VARCHAR(80),
    rows BIGINT,
    command VARCHAR(1000)
);

INSERT INTO @temp
EXEC sp_MSforeachdb '
    use [?];
    SELECT DISTINCT LEFT(@@servername, 16), DB_NAME(), s.name, o.name, p.data_compression_desc, p.rows,
        N''ALTER TABLE [''+s.name+ N''].[''+o.name+N''] REBUILD PARTITION = ALL WITH (DATA_COMPRESSION = PAGE);''
    FROM sys.partitions p
    JOIN sys.objects o ON p.object_id = o.object_id
    JOIN sys.schemas s ON s.schema_id = o.schema_id
    WHERE o.is_ms_shipped = 0
        AND o.type = ''U''
        AND p.data_compression_desc = ''NONE''
    ORDER BY p.rows';

SELECT @EmailBody
		= N'<html>' 
			+ N'<head>' 
				+ N'<style>' 
					+ N'table {border-collapse: collapse;}'
					+ N'th, td {border: 1px solid black; padding: 5px;}' 
				+ N'</style>' 
			+ N'</head>' 
			+ N'<body>'
				+ N'<h2>Partition Rebuild Script</h2>' 
				+ N'<table>' 
					+ N'<tr>' 
						+ N'<th>Instance Name</th>'
						+ N'<th>Database Name</th>' 
						+ N'<th>Schema Name</th>' 
						+ N'<th>Table Name</th>' 
						+ N'<th>Compression Type</th>'
						+ N'<th>Number of Rows</th>' 
						+ N'<th>Rebuild Script</th>' 
					+ N'</tr>';

SELECT @EmailBody
		= @EmailBody 
				+ N'<tr>' 
					+ N'<td>' + instancename + N'</td>' 
					+ N'<td>' + dbname + N'</td>' 
					+ N'<td>' + schemaname + N'</td>' 
					+ N'<td>' + tablename + N'</td>' 
					+ N'<td>' + data_compression_desc + N'</td>' 
					+ N'<td>' + CAST(rows AS NVARCHAR(20)) + N'</td>' 
					+ N'<td>' + command + N'</td>' + N'</tr>'
FROM @temp
WHERE dbname NOT IN ( 'master', 'tempdb' )
      AND rows > 0;

SET @EmailBody = @EmailBody + N'</table>' + N'</body>' + N'</html>';

SELECT @EmailBody;

--EXEC msdb.dbo.sp_send_dbmail
--    @profile_name = 'YourProfileName',  -- Replace with the name of your Database Mail profile
--    @recipients = @EmailRecipient,
--    @subject = @EmailSubject,
--    @body = @EmailBody,
--    @body_format = 'HTML';



