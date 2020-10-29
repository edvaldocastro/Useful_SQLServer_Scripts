--https://docs.microsoft.com/en-us/azure/azure-sql/database/database-copy?tabs=azure-powershell

CREATE DATABASE database_destination  --name of the new database
AS COPY OF [frbinedevsqlpool01].[database_source] -- name and server from the previous database
(SERVICE_OBJECTIVE = ELASTIC_POOL( name = elastic_pool_in_destination ) ) ; -- name of the elastic pool in the new server / subscription.

