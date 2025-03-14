$wordforfilename = 'wordforfilename'
$numberOfFiles = 10
$localPath = 'I:\shared\'
$awsS3URI = 's3://accountname/bucketname/folderName//'
$outputDir = 'C:\Temp\path\output\'
$operation = 'download'       #Possible values: 'download', 'upload'

if ($operation -eq 'upload') 
{
    foreach ($i in 1..$numberOfFiles) 
    {
        if ($i -lt 10) 
        {
            $i = '0' + $i
            $filecontent = "aws s3 cp ""$localPath$wordforfilename"+"_"+$i+".bak"" ""$awsS3URI$wordforfilename"+"_"+$i+".bak"""
            $filename = $outputDir + $wordforfilename +'_'+$i + '.bat'
            Set-Content -Path $filename -value $filecontent
        }
        else 
            {
                $filecontent = "aws s3 cp ""$localPath$wordforfilename"+"_"+$i+".bak"" ""$awsS3URI$wordforfilename"+"_"+$i+".bak"""
                $filename = $outputDir + $wordforfilename +'_'+$i + '.bat'
                Set-Content -Path $filename -value $filecontent
            }
        
    } 
}
elseif ($operation -eq 'download')  
{
    foreach ($i in 1..$numberOfFiles) 
    {
        if ($i -lt 10) 
        {
            $i = '0' + $i
            $filecontent = "aws s3 cp ""$awsS3URI$wordforfilename"+"_"+$i+".bak"" ""$localPath$wordforfilename"+"_"+$i+".bak"""
            $filename = $outputDir + $wordforfilename +'_'+$i + '.bat'
            Set-Content -Path $filename -value $filecontent
        }
        else 
            {
                $filecontent = "aws s3 cp ""$awsS3URI$wordforfilename"+"_"+$i+".bak"" ""$localPath$wordforfilename"+"_"+$i+".bak"""
                $filename = $outputDir + $wordforfilename +'_'+$i + '.bat'
                Set-Content -Path $filename -value $filecontent
            }
        
    } 
}


