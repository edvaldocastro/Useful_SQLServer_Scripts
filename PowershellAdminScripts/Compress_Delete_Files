$blgdir = "X:\Perfmon\LIVE_BLG\"
$histblgdir = "X:\Perfmon\HIST_BLG\"
$DateToDeleteBLG = (Get-Date).AddDays(-7)
$DateToDeleteZIP = (Get-Date).AddDays(-90)

#Compress files with LastWriteTime older than 7 days
$blgfiles = Get-ChildItem -Recurse -Path $blgdir
foreach ($blgfile in $blgfiles)
{
    if ($blgfile.LastWriteTime -lt $DateToDeleteBLG) 
    {
        #Write-Host $blgfile "is older than 7 days"
        $zipfile = $histblgdir + $blgfile.BaseName + ".zip"
        Compress-Archive -Path $blgfile.FullName -DestinationPath $zipfile -Verbose
        Remove-Item -Path $blgfile.FullName -Verbose
    }
}

#Delete files with LastWriteTime older than 90 day
$histfiles = Get-ChildItem -Recurse -Path $histblgdir
foreach ($histfile in $histfiles) {
    if ($histfile.LastWriteTime -lt $DateToDeleteZIP) 
    {
       #Write-Host $histfile.FullName
       Remove-Item -Path $histfile.FullName -Verbose
    }    
}
