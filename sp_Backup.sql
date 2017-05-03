/******************************************************************************************************************
SP_BACKUP

Criado por: Edvaldo Castro  -  http://edvaldocastro.com
Contatos:	edvaldo.castro@outlook.com
			

OBJETO: sp_backup
FUNÇÃO: Gerenciar a realização de rotinas de backup dos tipos (FULL, DIFFERENTIAL E LOG) possibilitando de 
		forma simples atender às necessidades de backup e recuperabilidade da maioria dos ambientes com 
		SQL Server.

DATA CRIAÇÃO: 07/05/2015

Ex. Chamada:
				Exec master.dbo.sp_backup 'AdventureWorks','Full',0,'C:\Temp'

	Parâmetros:

				@NomeBanco Varchar

				@TipoBackup Varchar. Aceita: ‘Log’, ‘FULL’,’FUL’,’DIF’,’DIFF’ – Se NULL, Default = ‘FULL’
				
				@IsCopyOnly bit. Aceita 0 , 1
				
				@Caminho Varchar. Formato ‘C:\Temp’,’C:\Temp\’ – Se NULL, Default = Defaulta da instância
				

	Exemplos de execução:

				exec sp_backup @NomeBanco = 'master',  @TipoBackup = 'Full', @IsCopyOnly = 1, @Caminho = 'C:\TEMP'
				exec sp_backup @NomeBanco = 'TESTE_1', @TipoBackup = 'LOG',  @IsCopyOnly = 3, @Caminho = 'C:\TEMP'
				exec sp_backup @NomeBanco = 'TESTE_1', @TipoBackup = 'DIF',  @IsCopyOnly = 3, @Caminho = 'C:\TEMP'
				exec sp_backup @NomeBanco = 'TESTE_1', @TipoBackup = 'DIFF', @IsCopyOnly = 0, @Caminho = 'C:\TEMP'
				exec sp_backup @NomeBanco = 'TESTE_1', @TipoBackup = 'FULL', @IsCopyOnly = 1, @Caminho = 'C:\TEMP'				


OBSERVAÇÃO: A procedures sp_backup está disponível gratuitamente para download para quaisquer tipos de uso, seja 
pessoal ou comercial, porém apenas solicito que a mesma não seja alterada, e que sejam mantidos os créditos sempre
que esta for ser utilizada.

OBS.: Qualquer sugestão de melhoria, ou correção de eventuais bugs, por favor envie para meu email:

edvaldo.castro@outlook.com

******************************************************************************************************************/



USE master
GO

IF OBJECT_ID('sp_backup') IS NOT NULL
	DROP PROCEDURE sp_backup
GO
CREATE PROCEDURE sp_Backup (@NomeBanco VARCHAR(100),@TipoBackup VARCHAR(20) = 'FULL',@IsCopyOnly tinyint = 0, @Caminho VARCHAR(200) = '')
AS
SET NOCOUNT ON
-- @TipoBackup = Full | Diff | Log
DECLARE @DataHora VARCHAR(200) = REPLACE(CONVERT(VARCHAR(100),GETDATE(),105),'-','_')+'_'+REPLACE(CONVERT(VARCHAR(100),GETDATE(),108),':','_')
DECLARE @BackupDevice VARCHAR(300) = UPPER(ISNULL(@Caminho+'\','') +@NomeBanco+'_'+@TipoBackup+'_'+@DataHora)
DECLARE @SQL NVARCHAR(MAX)
DECLARE @MSG VARCHAR(500)

		
IF DB_ID(@NomeBanco) IS NOT NULL
BEGIN		
	IF EXISTS (SELECT TOP 1 1 FROM msdb..backupset WHERE database_name = @NomeBanco AND type = 'D')
		BEGIN
			IF (@TipoBackup = 'LOG')
				BEGIN
					IF (@IsCopyOnly = 0)
						BEGIN
							SET @SQL = 	'BACKUP LOG ['+@NomeBanco+'] TO  DISK = N'''+@BackupDevice+'.trn'' WITH NAME = N'''+@NomeBanco+'- Transaction Log Backup'', COMPRESSION,  STATS = 1'
							SET @MSG = 'O BACKUP ['+@TipoBackup+'] DO BANCO '+@NomeBanco+' FOI REALIZADO COM SUCESSO.'
						END
					ELSE	IF (@IsCopyOnly = 1)
								BEGIN
									SET @SQL = 'BACKUP LOG ['+@NomeBanco+'] TO  DISK = N'''+@BackupDevice+'.trn'' WITH NAME = N'''+@NomeBanco+'- Copy_Only Transaction Log Backup'', COPY_ONLY, COMPRESSION,  STATS = 1'
									SET @MSG = 'O BACKUP ['+@TipoBackup+' COPY_ONLY] DO BANCO '+@NomeBanco+' FOI REALIZADO COM SUCESSO.'
								END
							ELSE	IF (@IsCopyOnly NOT IN (0,1))
										BEGIN
											SET @MSG = 'OPÇÃO IsCopyOnly INVÁLIDA. OPÇÕES: | 0 | 1 |'
										END
				
				END
			ELSE	IF (@TipoBackup = 'DIFF' OR @TipoBackup = 'DIF')
						BEGIN
							IF (@IsCopyOnly = 0)
								BEGIN
									SET @SQL = 'BACKUP DATABASE ['+@NomeBanco+'] TO  DISK = N'''+@BackupDevice+'.bak'' WITH NAME = N'''+@NomeBanco+'- Differential Database Backup'', DIFFERENTIAL, COMPRESSION,  STATS = 1'
									SET @MSG = 'O BACKUP ['+@TipoBackup+'] DO BANCO '+@NomeBanco+' FOI REALIZADO COM SUCESSO.'
								END
							ELSE	IF (@IsCopyOnly = 1)
										BEGIN
											SET @SQL = 'BACKUP DATABASE ['+@NomeBanco+'] TO  DISK = N'''+@BackupDevice+'.bak'' WITH NAME = N'''+@NomeBanco+'- Differential Database Backup'', DIFFERENTIAL, COMPRESSION, COPY_ONLY, STATS = 1'
											SET @MSG = 'O BACKUP ['+@TipoBackup+' COPY_ONLY] DO BANCO '+@NomeBanco+' FOI REALIZADO COM SUCESSO.'
										END
									ELSE	IF (@IsCopyOnly NOT IN (0,1))
												BEGIN
													SET @MSG = 'OPÇÃO IsCopyOnly INVÁLIDA. OPÇÕES: | 0 | 1 |'
												END
						END
		END
	ELSE	IF (NOT EXISTS (SELECT TOP 1 1 FROM msdb..backupset WHERE database_name = @NomeBanco AND type = 'D') AND (@TipoBackup IN ('LOG','DIF','DIFF')))
				BEGIN
					SET @MSG = 'IMPOSSÍVEL REALIZAR O BACKUP ['+@TipoBackup+'] DO BANCO '+@NomeBanco+'. EXECUTE UM BACKUP FULL E TENTE NOVAMENTE.'
				END

	IF (@TipoBackup = 'FULL' OR @TipoBackup = 'FUL')
		BEGIN
			IF (@IsCopyOnly = 0)
				BEGIN
					SET @SQL = 'BACKUP DATABASE ['+@NomeBanco+'] TO  DISK = N'''+@BackupDevice+'.bak'' WITH INIT, NAME = N'''+@NomeBanco+'- Full Database Backup'', COMPRESSION,  STATS = 1'
					SET @MSG = 'O BACKUP ['+@TipoBackup+'] DO BANCO '+@NomeBanco+' FOI REALIZADO COM SUCESSO.'
				END
			ELSE	IF (@IsCopyOnly = 1)
						BEGIN
							SET @SQL = 'BACKUP DATABASE ['+@NomeBanco+'] TO  DISK = N'''+@BackupDevice+'.bak'' WITH INIT, NAME = N'''+@NomeBanco+'- Copy_Only Full Database Backup'', COPY_ONLY, COMPRESSION,  STATS = 1'		
							SET @MSG = 'O BACKUP ['+@TipoBackup+' COPY_ONLY] DO BANCO '+@NomeBanco+' FOI REALIZADO COM SUCESSO.'
						END
					ELSE	IF (@IsCopyOnly NOT IN (0,1))
								BEGIN
									SET @MSG = 'OPÇÃO IsCopyOnly INVÁLIDA. OPÇÕES: | 0 | 1 |'
								END
		
		END
END
ELSE
	SET @MSG = ' O BANCO DE DADOS '+@NomeBanco+' NÃO EXISTE NA INSTÂNCIA.'


EXEC SP_EXECUTESQL @SQL
SELECT ISNULL(@MSG,'')
GO





--exec master..sp_backup @NomeBanco = 'source',  @TipoBackup = 'log', @IsCopyOnly = 5, @Caminho = 'C:\TEMP'
