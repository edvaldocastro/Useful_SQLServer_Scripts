/*
	Nome: Controle Automático de VLFs  // Automatic VLF Control
	Autor: Edvaldo Castro

	Data: 05/01/2014  // Date: 2014/01/05

	
	Função: Controlar Dinamicamente o tamanho dos VLFs das bases de dados. Este script especificamente realiza
			o ajuste inicial, adequando os arquivos de Transaction Log de todas as bases de dados da instância.

	Function:	Dynamically control the VLF size of all databases in a single SQL Server instance. This script do
				executes the initial adjustments, setting up the size and VLFs for Transaction Log files.
	
	07/01/2015	
	The code now verifies if the database is in a MULTI_USER mode and if it´s READ_ONLY.	


	Disclaimer:
			
		Os passos e scripts a seguir foram desenvolvidos para automatizar a configuração e controle dos Virtual Log Files,
		e podem causar algum tipo de bloqueio ou indisponibilidade temporária do SQL Server. 
		Antes de implantar ou utilizar partes ou todo o conteúdo aqui disponibilizado, sugiro a leitura e entendimento do que 
		cada passo realiza. Implante primeiro em um ambiente de testes controlado, e caso veja benefícios, se você for executá-los 
		em seu ambiente de produção, por sua conta e risco.

	Disclaimer

		The steps and scripts below, has been developed to provide the automatic configuration and control of Virtual Log Files and
		may cause some blocking or temporary availability issues to SQL Server databases.
		Before you execute or use any part of the full content, I recommend you read and understand each step. Deploy it firstly to
    	a controlled environment, and them if you find it useful, deploy to your production environment, BY YOUR OWN RISK !!!
	
*/


-- Cria a procedure sp_OnDemandCheck
USE master
IF OBJECT_ID('master..sp_OnDemandCheck') IS NOT NULL
	DROP PROCEDURE sp_OnDemandCheck
GO
CREATE PROCEDURE sp_OnDemandCheck
AS

			/* Variáveis  -  Variables*/
			DECLARE @DBNAME VARCHAR(100) -- Nome do banco que estará sendo verificado // Database Name that is currently been verified
			DECLARE @LOGNAME VARCHAR(100)-- Nome lógico do arquivo de log // Logical Name for the Transaction Log File
			DECLARE @MSG VARCHAR(100) = '' -- Retorno de conclusão com sucesso após cada base ser verificada // Sucessful message returned after each operation
			DECLARE @SQL VARCHAR(MAX) = '' -- Construção dinâmica do comando para adequação dos VLFs // Dynamic query for VLFs configuration
			DECLARE @CV_SIZE_MB INT = 0 -- Tamanho do arquivo de t-log na tabela ControlaVLF // Size of Transaction Log File in ControlaVLF table
			DECLARE @FILE_SIZE_MB INT = 0 -- Tamanho do arquivo de t-log no disco // Size of Transaction Log File in disk.
			DECLARE @COUNT SMALLINT = 1 -- Contador para o loop nas bases de dados // Counter for loop in databases
			DECLARE @HasFullBackup BIT
			DECLARE @SHRINKCOUNTER TINYINT

			WHILE (@COUNT <= (SELECT MAX(ID) FROM master..controlaVLF))
				BEGIN
					SELECT 	@DBNAME = cv.DatabaseName ,
							@LOGNAME = cv.LogFileName ,
							@FILE_SIZE_MB = mf.size / 128 ,
							@CV_SIZE_MB = ROUND(cv.TargetLogFileSize_MB, 0) ,
							--@HasFullBackup = CASE WHEN EXISTS (SELECT TOP 1 * FROM sys.databases s WHERE s.database_id = cv.DatabaseID) THEN 1
							--						ELSE 0
							--				 END,

							-- Verifica a existência de backup full para o banco de dados e atribui o valor à variável @HasFullBackup
							-- Checks if the database has full backup and set the @HasFullBackup variable
							@HasFullBackup = CASE WHEN EXISTS (SELECT TOP 1 * FROM msdb..backupset bs WHERE bs.database_name = cv.DatabaseName AND bs.type = 'D') THEN 1
													ELSE 0
											 END,
							-- Monta a query dinamica com base no modelo de recuperação do banco | Substitutua o texto abaixo entre comentários /* */ pela sua rotina de backup de log
							-- Creates the dynamic query based on recovery model of the database | Replace the comments /* */ by your T-Log procedure
							@SQL =	CASE WHEN RecoveryModelDesc = 'SIMPLE' AND @HasFullBackup = 1 THEN 'USE ' +@DBNAME+ '; DBCC SHRINKFILE(2,'+CAST(@CV_SIZE_MB AS VARCHAR(10))+'); USE ' +@DBNAME+ '; DBCC SHRINKFILE(2,'+CAST(@CV_SIZE_MB AS VARCHAR(10))+');'
										ELSE 'USE MASTER; /* BACKUP LOG ' +@DBNAME+' TO DISK = ''NUL''; REPLACE THIS COMMENT BY YOUR BACKUP PROCEDURE */ USE ' +@DBNAME+ '; DBCC SHRINKFILE(2,'+CAST(@CV_SIZE_MB AS VARCHAR(10))+'); USE master; /* BACKUP LOG ' +@DBNAME+' TO DISK = ''NUL''; REPLACE THIS COMMENT BY YOUR BACKUP PROCEDURE */ USE ' +@DBNAME+ '; DBCC SHRINKFILE(2,'+CAST(@CV_SIZE_MB AS VARCHAR(10))+'); '
									END ,
							@MSG = '',
							@SHRINKCOUNTER = cv.ShrinkCounter+1

					FROM    sys.master_files mf
							JOIN master..ControlaVLF cv ON mf.database_id = cv.DatabaseID
							JOIN sys.databases D ON D.name = CV.DatabaseName
							
					WHERE   file_id = 2
							AND mf.state = 0
							AND d.database_id > 4
							AND ID = @COUNT
							AND D.is_read_only = 0
							AND D.user_access = 0
		
					-- Caso o tamanho do arquivo em disco seja maior que o ideal, é realizado o shrink do arquivo, e atualizados os campos "LastShrinkDate" e "ShrinkCounter" na tabela Controla VLF
					-- If the file size in disc is bigger than the recommended, a SHRINKFILE is executed and the table ControlaVLF is updated ("LastShrinkDate" and "ShrinkCounter")
					IF (@FILE_SIZE_MB > (@CV_SIZE_MB + 256))
						BEGIN
				
							EXEC (@SQL)
							UPDATE c
							SET c.ShrinkCounter = c.ShrinkCounter + 1,
								c.LastShrinkDate = GETDATE()
							FROM master..ControlaVLF c
							WHERE ID = @COUNT

							SET @MSG = 'REALIZADO SHRINK NO BANCO: '+@DBNAME+'. ESTE PROCEDIMENTO FOI EXECUTADO PELA '+CAST(@SHRINKCOUNTER AS VARCHAR(10))+' ª VEZ !'
							RAISERROR (@MSG,0,1) WITH NOWAIT
				
				
						END

					SET @CV_SIZE_MB = 0
					SET @COUNT = @COUNT + 1

				END

