/* Create a temporary table to store and manipulate data about database size */
drop TABLE IF EXISTS #spaceused
CREATE TABLE #spaceused
(
	database_name		NVARCHAR(128),
	database_size		NVARCHAR(128),
	unallocated_space	NVARCHAR(128),
	reserved_kb			NVARCHAR(128),
	data_kb				NVARCHAR(128),
	index_size			NVARCHAR(128),
	unused				NVARCHAR(128)
)

/* insert data into the table from sp_spaceused stored procedure */
EXEC sp_msforeachdb 'use [?]; INSERT INTO #spaceused EXEC sys.sp_spaceused @oneresultset = 1'

/* Remove mesure units from the numbers, making possible to use then for calculations */
UPDATE #spaceused SET database_size		= REPLACE(database_size,' MB','')
UPDATE #spaceused SET unallocated_space = REPLACE(unallocated_space,' MB','')
UPDATE #spaceused SET reserved_kb		= REPLACE(reserved_kb,' KB','')
UPDATE #spaceused SET data_kb			= REPLACE(data_kb,' KB','')
UPDATE #spaceused SET index_size		= REPLACE(index_size,' KB','')
UPDATE #spaceused SET unused			= REPLACE(unused,' KB','')

/* Select statement to show and format only the resultset only the columns needed */
SELECT	database_name,
		[database_size(GB)]	= CAST(CAST(database_size AS NUMERIC(18,2))/1024 AS NUMERIC(18,2)),
		[used_size(GB)]		= CAST((CAST(database_size AS NUMERIC(18,2)) - CAST(unallocated_space AS NUMERIC(18,2)))/1024 AS NUMERIC(18,2)),
		[free_space(GB)]	= CAST(CAST(unallocated_space AS NUMERIC(18,2))/1024 AS NUMERIC(18,2)) 
  FROM  #spaceused
 WHERE  database_name NOT IN ('master','model','tempdb','msdb')
 ORDER  BY [database_size(GB)]

 /* Drop temporary table*/
DROP TABLE IF EXISTS #spaceused
