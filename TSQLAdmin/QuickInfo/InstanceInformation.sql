declare @advancedoptions bit 
select @advancedoptions = cast(value_in_use as bit) from sys.configurations where name = 'show advanced options'

declare @xpcmdshell bit 
select @xpcmdshell = cast(value_in_use as bit) from sys.configurations where name = 'xp_cmdshell'



exec sp_configure 'show advanced options',1; reconfigure with override
exec sp_configure 'xp_cmdshell',1; reconfigure with override


-- Set the output file path and name
DECLARE @OutputFilePath NVARCHAR(500) = 'C:\Temp\MigrationDocumentation.txt';

-- Create or overwrite the output file
DECLARE @title NVARCHAR(500) = CONCAT('echo Migration Documentation > "', @OutputFilePath, '"');
EXEC xp_cmdshell @title


-- Add information about SQL Server version and edition
DECLARE @echo NVARCHAR(500) = CONCAT('echo. >> "', @OutputFilePath, '"');
EXEC xp_cmdshell @echo

DECLARE @sqleditionandversion2 NVARCHAR(500) = CONCAT('echo SQL Server Version and Edition: >> "', @OutputFilePath, '"');
EXEC xp_cmdshell @sqleditionandversion2

DECLARE @sqleditionandversion3 NVARCHAR(500) = CONCAT('echo ----------------------------- >> "' , @OutputFilePath, '"');
EXEC xp_cmdshell @sqleditionandversion3

DECLARE @sqleditionandversion5 NVARCHAR(500) = CONCAT('sqlcmd -S localhost -Q "SELECT SERVERPROPERTY(''ProductVersion'') AS ProductVersion, SERVERPROPERTY(''ProductLevel'') AS ProductLevel, SERVERPROPERTY(''Edition'') AS Edition" -h-1 -s"," -W >> "' , @OutputFilePath, '"');
EXEC xp_cmdshell @sqleditionandversion5




-- Add information about databases

DECLARE @dateabases1 NVARCHAR(500) = CONCAT('echo. >> "' , @OutputFilePath, '"');
EXEC xp_cmdshell @dateabases1

DECLARE @dateabases2 NVARCHAR(500) = CONCAT('echo Databases: >> "' , @OutputFilePath, '"');
EXEC xp_cmdshell @dateabases2

DECLARE @dateabases3 NVARCHAR(500) = CONCAT('echo ----------------------------- >> "' , @OutputFilePath, '"');
EXEC xp_cmdshell @dateabases3

DECLARE @dateabases4 NVARCHAR(500) = CONCAT('sqlcmd -S localhost -Q "SELECT name AS DatabaseName, compatibility_level AS CompatibilityLevel, collation_name AS Collation FROM sys.databases WHERE database_id > 4" -h-1 -s"," -W >> "' , @OutputFilePath, '"');
EXEC xp_cmdshell @dateabases4


-- Add information about server settings
DECLARE @server1 NVARCHAR(500) = CONCAT('echo. >> "' , @OutputFilePath, '"');
EXEC xp_cmdshell @server1

DECLARE @server2 NVARCHAR(500) = CONCAT('echo Server Settings: >> "' , @OutputFilePath, '"');
EXEC xp_cmdshell @server2

DECLARE @server3 NVARCHAR(500) = CONCAT('echo ----------------------------- >> "' , @OutputFilePath, '"');
EXEC xp_cmdshell @server3

DECLARE @server4 NVARCHAR(500) = CONCAT('sqlcmd -S localhost -Q "sp_configure ''show advanced options'', 1; RECONFIGURE; sp_configure" -h-1 -s"," -W >> "' , @OutputFilePath, '"');
EXEC xp_cmdshell @server4

-- Add information about SQL Agent jobs
DECLARE @jobs1 NVARCHAR(500) = CONCAT('echo. >> "' , @OutputFilePath, '"');
EXEC xp_cmdshell @jobs1

DECLARE @jobs2 NVARCHAR(500) = CONCAT('echo SQL Agent Jobs: >> "' , @OutputFilePath, '"');
EXEC xp_cmdshell @jobs2

DECLARE @jobs3 NVARCHAR(500) = CONCAT('echo ----------------------------- >> "' , @OutputFilePath, '"');
EXEC xp_cmdshell @jobs3

DECLARE @jobs4 NVARCHAR(500) = CONCAT('sqlcmd -S localhost -Q "SELECT name AS JobName, description AS JobDescription FROM msdb.dbo.sysjobs" -h-1 -s"," -W >> "' , @OutputFilePath, '"');
EXEC xp_cmdshell @jobs4


-- Add information about logins
DECLARE @logins1 NVARCHAR(500) = CONCAT('echo. >> "' , @OutputFilePath, '"');
EXEC xp_cmdshell @logins1

DECLARE @logins2 NVARCHAR(500) = CONCAT('echo Logins: >> "' , @OutputFilePath, '"');
EXEC xp_cmdshell @logins2

DECLARE @logins3 NVARCHAR(500) = CONCAT('echo ----------------------------- >> "' , @OutputFilePath, '"');
EXEC xp_cmdshell @logins3

DECLARE @logins4 NVARCHAR(500) = CONCAT('sqlcmd -S localhost -Q "SELECT name AS LoginName, type_desc AS LoginType FROM sys.server_principals WHERE type IN (''S'', ''U'', ''G'')" -h-1 -s"," -W >> "' , @OutputFilePath, '"');
EXEC xp_cmdshell @logins4


-- Display completion message
DECLARE @completion NVARCHAR(500) = CONCAT('echo Migration documentation has been generated. Check the file: ''C:\Temp\MigrationDocumentation.txt'' >> ', @OutputFilePath, '"');
EXEC xp_cmdshell @completion

-- Reseting Advanced Options and xp_cmdshell to previous state
exec sp_configure 'show advanced options',@advancedoptions; reconfigure with override
exec sp_configure 'xp_cmdshell',@xpcmdshell; reconfigure with override

