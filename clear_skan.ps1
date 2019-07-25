##### Delete SKAN folder. 
            
$TargetFolder="C:\test\00. SKANY\" 
$Files= Get-Childitem  "C:\test\00. SKANY\"  -File 

foreach ($File in $Files) 
{ 
    if ($File -ne $NULL) 
    { 
      
      write-host "Deleting File $File " -ForegroundColor "DarkRed" 
      Remove-Item $File.FullName | out-null
       }

    else 
    { Write-Host "No more files to delete!" -foregroundcolor "Green" } 

}


Set-Location "C:\test\00. SKANY"
$Dirs=Get-Childitem $TargetFolder -Recurse -Exclude Fakt* -Directory
foreach ($Dir in $Dirs) 
{ 

           $PDFs = Get-ChildItem $Dir -Include *.* -Recurse  -File #Build list of PDF
           Set-Location  $Dir #Set location of start script C\test\(IT, HR, DT etc.)
           ForEach ($PDF in $PDFs) # Common, RO, Restricted
           {
                if ($Dir -ne $NULL) 
                { 
      
                  write-host "Deleting File $PDF " -ForegroundColor "DarkRed" 
                  Remove-Item $PDF.FullName | out-null
                   }

                else 
                { Write-Host "No more files to delete!" -foregroundcolor "Green" } 
           
           }
           Set-Location "C:\test\00. SKANY"



    

}