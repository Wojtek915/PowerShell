
################ ICACLS name /reset 
  ############## “Replace all child permission entries with inheritable permission from this object”

$DirectoryList = "\\olasrv02\Public\" # Build the list 
Set-Location $DirectoryList

$Folders = Get-ChildItem $DirectoryList -Directory  -Exclude 00*  #Build list of dir


    ForEach ($Folder in $Folders) #Department DIR (IT, HR, etc.)
     { 
           $Dirs = Get-ChildItem $Folder -Directory   #Build list of dir in ( Common, RO, Restricted)
           Set-Location ($Folder) #Set location of start script C\test\(IT, HR, DT etc.)
           ForEach ($Dir in $Dirs) # Common, RO, Restricted
             { 
               $InDirs = Get-ChildItem $Dir  #Build list of dir in ( Common, RO, Restricted)
               Set-Location ($Dir) #Set location of start script C\test\(IT, HR, DT etc.)\(Common, RO, Restricted)
               ForEach ($InDir in $InDirs) # Inside dirs and files
                 { 
                    icacls $InDir /c /t  /reset 
                    #write $InDir 
        
                 } 
              
               Set-Location ($Folder) #Set location of start script C\test\(IT, HR, DT etc.)
               

                
        
            }
            Set-Location $DirectoryList  #Set location of start script C\test\
            
          
    }
 