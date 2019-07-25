$srcpath = "C:\Program Files\Autodesk\"
Set-Location $srcpath

$Files=Get-ChildItem $srcpath -Recurse -File -Include LICPATH.LIC


ForEach ($File in $Files) 
{
   if ($File -ne $NULL) 
       {
           $lstr =  Get-Content $File
		   $str = $lstr.toUpper()
           write-host $str #$File
            if ($str -match "OLASRV02" )
                {
                
                $str.Replace("OLASRV02","SENTJSQL01") >  $File
                icacls $File /c /t /reset
                               
                }
            else
                {
                $str.Replace("SENTJSQL01", "OLASRV02") >  $File
                icacls $File /c /t /reset
               
                }
    
        }
    else
    {
    Write-Host "Nie ma takiego pliku"
    }
    
}

