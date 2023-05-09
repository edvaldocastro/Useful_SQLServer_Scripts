DECLARE @EmailRecipient NVARCHAR(255) = 'recipient@example.com';
DECLARE @EmailSubject NVARCHAR(255) = 'Partition Rebuild Script';
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

SELECT @EmailBody = 
    '<html>' +
    '<head>' +
    '<style>' +
    'table {border-collapse: collapse;}' +
    'th, td {border: 1px solid black; padding: 5px;}' +
    '</style>' +
    '</head>' +
    '<body>' +
    '<h2>Partition Rebuild Script</h2>' +
    '<table>' +
    '<tr>' +
    '<th>Instance Name</th>' +
    '<th>Database Name</th>' +
    '<th>Schema Name</th>' +
    '<th>Table Name</th>' +
    '<th>Compression Type</th>' +
    '<th>Number of Rows</th>' +
    '<th>Rebuild Script</th>' +
    '</tr>';

SELECT @EmailBody = @EmailBody +
    '<tr>' +
    '<td>' + instancename + '</td>' +
    '<td>' + dbname + '</td>' +
    '<td>' + schemaname + '</td>' +
    '<td>' + tablename + '</td>' +
    '<td>' + data_compression_desc + '</td>' +
    '<td>' + CAST(rows AS NVARCHAR(20)) + '</td>' +
    '<td>' + command + '</td>' +
    '</tr>'
FROM @temp
WHERE dbname NOT IN ('master', 'tempdb')
    AND rows > 0;

SET @EmailBody = @EmailBody +
    '</table>' +
    '</body>' +
    '</html>';

	SELECT @EmailBody

--EXEC msdb.dbo.sp_send_dbmail
--    @profile_name = 'YourProfileName',  -- Replace with the name of your Database Mail profile
--    @recipients = @EmailRecipient,
--    @subject = @EmailSubject,
--    @body = @EmailBody,
--    @body_format = 'HTML';



