https://www.mssqltips.com/sqlservertip/3574/change-sql-server-log-shipped-database-from-restoring-to-standby-readonly/

--information about the last copied and restored files along with the time since the last copied and restore file 
SELECT 
   secondary_server,
   secondary_database,
   primary_server,
   primary_database,
   last_copied_file,
   last_copied_date,
   last_restored_file,
   last_restored_date
FROM msdb.dbo.log_shipping_monitor_secondary




-- Check the Current SQL Server Log Shipping Mode
-- Run at the secondary database

SELECT 
   secondary_database,
   restore_mode,
   disconnect_users,
   last_restored_file
FROM msdb.dbo.log_shipping_secondary_databases



-- Change a SQL Server Log Shipping Database to Read-Only


Run the below command to change this configuration setting using T-SQL:

EXEC sp_change_log_shipping_secondary_database
  @secondary_database = 'Collection',
  @restore_mode = 1,
  @disconnect_users = 1
