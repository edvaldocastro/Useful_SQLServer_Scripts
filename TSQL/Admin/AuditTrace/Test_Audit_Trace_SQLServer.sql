--RUN BELOW TESTS TO FEED THE TRACE FILES
 
--CREATE AN EMPTY DATABASE

use master
go
drop database if exists TestAuditing
go
create database TestAuditing
on primary
(name='TestAuditing',filename='E:\SQLUserDBData01\SQLUserDBData\TestAuditing.mdf')
log on
(name='TestAuditing_log',filename='E:\SQLUserDBLogs01\SQLUserDBLogs\TestAuditing.ldf')
go
 
--CREATE A LOGIN
if exists (select 1 from sys.server_principals where name ='abcdefgh')
	begin
		drop login abcdefgh
		create login abcdefgh with password = 'P@ssw0rd', check_policy = on
	end
else 
	begin
		create login abcdefgh with password = 'P@ssw0rd', check_policy = on
	end
go

--CREATE AN USER ON THE DATABASE
use TestAuditing
go
create user abcdefgh from login abcdefgh
go

--GRANT SYSADMIN PRIVILEGES TO THE LOGIN
alter server role securityadmin add member abcdefgh
 
-- CREATE A SERVER ROLE
create server role testserveraudit
go
 
--DROP A SERVER ROLE
drop server role testserveraudit
go
 

--MAKE THE USER DBOWNER
use TestAuditing
go
alter role db_owner add member abcdefgh
go
 
---CREATE A TABLE
use TestAuditing
go
create table tb1 (i int default 5)
go
 
--CREATE A STORED PROCEDURE
use TestAuditing
go
drop procedure if exists sp_audit
go
create procedure sp_audit
as
insert into tb1 default values
select * from tb1
go
 
use TestAuditing
go
exec sp_audit
 
--DROP STORED PROCEDURE
use TestAuditing
go
drop procedure if exists sp_audit
go
 
--DROP TABLE
use TestAuditing
go
drop table if exists tb1
go

 
--DROP USER
use TestAuditing
go
drop user if exists abcdefgh
go

 
--DROP LOGIN [abcdefgh]
if exists (select * from sys.server_principals where name = 'abcdefgh')
	drop login [abcdefgh]


--DROP DATABASE 
use master
go
drop database if exists TestAuditing

 
 
--END OF TESTS, 
 
--CHECK TRACE FILES NOW


