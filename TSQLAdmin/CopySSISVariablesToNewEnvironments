Copy SSIS Variables to New Environments
https://jonlabelle.com/snippets/view/sql/copy-ssis-variables-to-new-environments

/* =============================================================================
Copy SSIS Variables to New Environments
 
Following my investigations on SSIS 2012 and the issues mentioned in my previous
blog post, create environment variables from project parameters
(https://thefirstsql.com/2013/05/28/ssis-2012-create-environment-variables-from-project-parameters/),
I created a script that easily lets you copy all the existing environment
variables either to a new environment on the same server or to a new (or existing)
environment on a completely different server.
 
This script will take all environment variables in an existing environment and
make "insert" scripts out of them so you can easily deploy them to a new server
or a new environment on the same server.
 
PLEASE NOTE: This script will NOT make any changes to your environments by
itself! It merely generates a SQL script that has to be copy/pasted in to a SSMS
query window and executed manually.
 
by Henning Frettem, www.thefirstsql.com, 2013-05-28
https://thefirstsql.com/2013/05/28/ssis-2012-easily-copy-environment-variables-to-new-servers-or-new-environments/
===========================================================================-- */
 


set nocount on;
 
declare @folder_name nvarchar(200) = '_Environments',
        @environment_name_current nvarchar(200) = 'Production',
        @environment_name_new nvarchar(200) = 'Production',
        @name sysname,
        @sensitive bit,
        @description nvarchar(1024),
        @value sql_variant,
        @type nvarchar(128);
 
print 'DECLARE @folder_id bigint, @environment_id bigint';
print '';
 
--> Create folder if it doesn't exist and get folder_id
print 'IF NOT EXISTS (SELECT 1 FROM [SSISDB].[catalog].[folders] WHERE name = N'''+@folder_name+''')
    EXEC [SSISDB].[catalog].[create_folder] @folder_name=N'''+@folder_name+''', @folder_id=@folder_id OUTPUT
ELSE
    SET @folder_id = (SELECT folder_id FROM [SSISDB].[catalog].[folders] WHERE name = N'''+@folder_name+''')';
print '';
 
--> Create environment if it doesn't exist
print 'IF NOT EXISTS (SELECT 1 FROM [SSISDB].[catalog].[environments] WHERE folder_id = @folder_id AND name = N'''+@environment_name_new+''')
    EXEC [SSISDB].[catalog].[create_environment] @environment_name=N'''+@environment_name_new+''', @folder_name=N'''+@folder_name+'''';
print '';
 
--> Get the environment_id
print 'SET @environment_id = (SELECT environment_id FROM [SSISDB].[catalog].[environments] WHERE folder_id = @folder_id and name = N'''+@environment_name_new+''')';
print '';
 
--> Making cursor because mapping of sql_variant datatype is different than the normal datatypes
declare cur cursor
for select
        c.name,
        c.sensitive,
        c.description,
        c.value,
        c.type
    from SSISDB.catalog.folders as a
    inner join SSISDB.catalog.environments as b
        on a.folder_id = b.folder_id
    inner join SSISDB.catalog.environment_variables as c
        on b.environment_id = c.environment_id
    where a.name = @folder_name
          and b.name = @environment_name_current;
 
open cur;
fetch next from cur into @name, @sensitive, @description, @value, @type;
print 'DECLARE @var sql_variant';
print '';
while @@FETCH_STATUS = 0
    begin
        print 'SET @var = N'''+CONVERT(nvarchar(max), @value)+'''';
        print 'IF NOT EXISTS (SELECT 1 FROM [SSISDB].[catalog].[environment_variables] WHERE environment_id = @environment_id AND name = N'''+@name+''')
            EXEC [SSISDB].[catalog].[create_environment_variable] @variable_name=N'''+@name+''', @sensitive='+CONVERT(varchar(2), @sensitive)+', @description=N'''+@description+''', @environment_name=N'''+@environment_name_new+''', @folder_name=N'''+@folder_name+''', @value=@var, @data_type=N'''+@type+'''';
        print '';
        fetch next from cur into @name, @sensitive, @description, @value, @type;
    end;
close cur;
deallocate cur;
