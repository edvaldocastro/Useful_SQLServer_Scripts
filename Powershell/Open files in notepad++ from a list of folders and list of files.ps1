# Read the list of folders from the first file

$database = 'databasename'
$repository = 'repository'

#list os schemas to be opened
$schemas =  Get-Content "C:\Work\Git-Repo\DatabaseProjects\schemalist.txt"

# Read the list of SQL filenames from the second file
$sqlFiles = Get-Content "C:\Work\Git-Repo\DatabaseProjects\filelist.txt"

# Iterate through each folder in the list
foreach ($schema in $schemas) {
    #$tablesFolderPath = Join-Path -Path $schema -ChildPath "Tables\"
    $tablesFolderPath = Join-Path -Path "C:\Work\Git-Repo\DatabaseProjects\$repository\$database\$schema" -ChildPath "Tables\"
    $tablesFolderPath

    # Check if the Tables subfolder exists
    if (Test-Path -Path $tablesFolderPath -PathType Container) {
        # Iterate through SQL files in the Tables subfolder
        Get-ChildItem -Path $tablesFolderPath -Filter *.sql | ForEach-Object {
            $sqlFileName = $_.Name
      
            # Check if the SQL file is in the list
            if ($sqlFiles -contains $sqlFileName) {
                $sqlFilePath = $_.FullName

                # Open and process the SQL file here as needed
                Write-Host "Processing SQL file: $sqlFilePath"
                # You can add your logic to process the SQL file here
                Start-Process -FilePath $notepadPlusPlusPath -ArgumentList $sqlFilePath
            }
        }
    }
}
