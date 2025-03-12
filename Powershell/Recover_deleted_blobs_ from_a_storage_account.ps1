<# 

Recover deleted blobs from a storage account that has soft-delete enabled. 
The Script recovers blobs in soft-delete state. 
The script requires the Az.Storage module version 5.5.0 or higher 


$storageAccountName = "storageAccountName"
$containerName = "containerName"
$dirName = "dirName"


# -------

# Define

# -------#obtain token to auth on the storage account
$ctx = (New-AzStorageContext -StorageAccountName $storageAccountName).Context

#obtain list of the deleted blobs
$deletedItems = Get-AzDataLakeGen2DeletedItem -Context $ctx -FileSystem $containerName -Path $dirName

#display the number of blobs that will be recovered.
$deletedItems | Measure-Object
#-------

# Start

# -------

#start removal as parallel jobs
$deletedItems | Restore-AzDataLakeGen2DeletedItem -asjob

# -------# Monitor
# -------

#get state of the jobs

get-job -state NotStarted