Function Get-FileName($initialDirectory)
{   
             [System.Reflection.Assembly]::LoadWithPartialName("System.windows.forms") |
             Out-Null

             $OpenFileDialog = New-Object System.Windows.Forms.OpenFileDialog
             $OpenFileDialog.initialDirectory = $initialDirectory
             $OpenFileDialog.filter = "All files (*.txt)| *.txt"
             $OpenFileDialog.ShowDialog() | Out-Null
             $OpenFileDialog.filename
            } #end function Get-FileName

$List = Get-FileName -initialDirectory "c:fso"
$lines =  Get-Content $List

Function Get-DirName
{   
             [System.Reflection.Assembly]::LoadWithPartialName("System.windows.forms") |
             Out-Null

             $OpenFileDialog = New-Object System.Windows.Forms.FolderBrowserDialog
             $OpenFileDialog.ShowDialog() | Out-Null
             $OpenFileDialog.Description = "Select a directory"
             $OpenFileDialog.SelectedPath
             
            } 


$DirDest = Get-DirName "c:fso"
write-host $DirDest

$DirectoryList = "Z:\" # Build the list 
Set-Location $DirectoryList




foreach($line in $lines) {
   
        write-host 'I am looking for : '$line  
                               
           Copy-Item -Path $line".pdf" -Destination $DirDest                               
    }
