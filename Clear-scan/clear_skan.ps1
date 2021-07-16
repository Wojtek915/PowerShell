#####################################################
#name of file
[string]$data = Get-Date  -Format "yyyyMMdd"
[string]$pathraport = "C:\Logs\clearskan\" + "raport" + $data + ".txt"
[string]$raportname =  "raport" + $data + ".txt"

###############################################

##### Delete SKAN folder. 
          
$TargetFolder="\\olasrv02\Public\00. SKANY\" 
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



    
$smtpServer="mcchvac-com0i.mail.protection.outlook.com" 
$from = "Administrator IT <mcc-eu-wsr01@mcc-hvac.com>"  
$emailaddress = "wojciech.konikiewicz@mcc-hvac.com" 
# 
################################################################################################################### 
###COnvert to HTML################
[string]$adminnamehtml = "raport" + $data + ".htm"

$SourceFile = $pathraport
$TargetFile = "C:\Logs\clearskan\" + $adminnamehtml
 
$File = Get-Content $SourceFile -ErrorAction SilentlyContinue

$FileLine = @()
Foreach ($Line in $File) {
 $MyObject = New-Object -TypeName PSObject
 Add-Member -InputObject $MyObject -Type NoteProperty -Name HealthCheck -Value $Line
 $FileLine += $MyObject
}
$FileLine | ConvertTo-Html    -body "<H2>Raport clear scan</h2>" | Out-File $TargetFile

###################################################
########################################### 



# System Settings 
$textEncoding = [System.Text.Encoding]::UTF8 
 
 # Email Subject Set Here 
 $subject="Raport Clear-Scan folder" 
   
 # Email Body Set Here, Note You can use HTML, including Images.
 
 if (-not (test-path $pathraport) ) 
    {
        $body_fill = "No more file"
        
    }
    else {$body_fill = Get-Content -Path $TargetFile }
 

 $body = "$body_fill"
    
 
 # Send Email Message 
Send-Mailmessage -smtpServer $smtpServer -from $from -to $emailaddress  -subject $subject -body $body -BodyAsHtml -priority High  -Encoding $textEncoding    
 
  