
################ ICACLS name /reset 
  ############## “Replace all child permission entries with inheritable permission from this object”

$DirectoryList = "\\uwesrv6\Arkiv\" # Build the list 
Set-Location $DirectoryList

$Files = Get-ChildItem $DirectoryList -File -Include 23-8011.pdf   #Build list of file


    ForEach ($File in $Files) 
     { 
                
                 
                    #icacls $File /c /t  /reset 
                    write $File 
                  
      }
            
            
          
   
 