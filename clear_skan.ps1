#####################################################
#name of file
[string]$data = Get-Date  -Format "yyyyMMdd"
[string]$pathraport = "C:\Logs\clearskan\" + "raport" + $data + ".txt"
[string]$raportname =  "raport" + $data + ".txt"

###############################################

##### Delete SKAN folder. 
          
$TargetFolder="\\mcc-eu-wsr01\Public\00. SKANY\" 
$Files= Get-Childitem  $TargetFolder  -File 

foreach ($File in $Files) 
{ 
    if ($File -ne $NULL) 
    { 
      
      $tmp =  "Deleting File $File "
      $tmp >> $pathraport
      Remove-Item $File.FullName 
       }

    else 
    { Write-Host "No more files to delete!" -foregroundcolor "Green" } 

}


Set-Location $TargetFolder
$Dirs=Get-Childitem $TargetFolder -Recurse -Exclude Fakt* -Directory
foreach ($Dir in $Dirs) 
{ 

           $PDFs = Get-ChildItem $Dir -Include *.* -Recurse  -File #Build list of PDF
           Set-Location  $Dir #Set location of start script C\test\(IT, HR, DT etc.)
           ForEach ($PDF in $PDFs) # Common, RO, Restricted
           {
                if ($Dir -ne $NULL) 
                { 
      
                  $tmp =  "Deleting File $PDF"
                    $tmp >> $pathraport
                  Remove-Item $PDF.FullName | out-null
                   }

                else 
                { Write-Host "No more files to delete!" -foregroundcolor "Green" } 
           
           }
           Set-Location $TargetFolder



    

}