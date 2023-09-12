# Read the list of folders from the first file
$folders =  Get-Content "C:\Work\Git-Repo\teste\azure-sqlmi-frbinetline\schemalist.txt"

# Read the list of SQL filenames from the second file
$sqlFiles = Get-Content "C:\Work\Git-Repo\teste\azure-sqlmi-frbinetline\filelist.txt"


# Iterate through each folder in the list
foreach ($folder in $folders) {
    $tablesFolderPath = Join-Path -Path $folder -ChildPath "Tables\"

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
