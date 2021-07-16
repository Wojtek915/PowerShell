
##############################################################
################# Name of files ##############################
[string]$data = Get-Date  -Format "yyyyMMdd"            #Get date - today
[string]$pathraport = "C:\Cred_PS1\" + "raport" + $data + ".txt" #Path for remote devices - raport with local admins
[string]$pathadmin = "C:\Cred_PS1\" + "admins" + $data + ".txt"  #Path for remote devices - raport with local admins deleted
[string]$raportname =  "raport" + $data + ".txt"        #File name  - raport with local admins
[string]$adminname = "admins" + $data + ".txt"          #File name  -  raport with local admins deleted
[string]$space = '------------------'
###############################################################
###############################################################

 
###########################################################
#############Get AD-computer from Domain Controller #######

$computers = Get-ADComputer -Filter 'Name -like "*olanb028*"'  -SearchBase "OU=Computers,OU=Olawa,DC=eu,DC=mcc-hvac,DC=in" |sort -Descending | select -ExpandProperty Name 

###########################################################
#loop


foreach ($computer in $computers)
    {
       
       Write-host $computer

       if ((Get-WmiObject -Class Win32_OperatingSystem -Property Oslanguage -ComputerName $computer | select -ExpandProperty OSLanguage)  -eq 1045) 
                                {$computer >> $pathraport   
                                  $group=get-wmiobject win32_group -filter "name='Administratorzy'"
                                  $admins = $group.GetRelated("win32_useraccount").Name
                                  $admins >> $pathraport
                                  $space  >> $pathraport
                                }
                            else 
                                {
                                $computer >> $pathraport 
                                $group=get-wmiobject win32_group -filter "name='Administrators'"
                                $admins = $group.GetRelated("win32_useraccount").Name   
                                $admins >> $pathraport
                                $space  >> $pathraport
                                }


       

        foreach ($admin in $admins)
                                {
                                    if (-not ($admin -eq 'mcc'))
                                        {
                                            if (-not ($admin -eq 'Administrator'))                                    
                                                {
                                                   if (-not ($admin -eq 'Domain Admins'))
                                                        {
                                                           if (-not ($admin -eq 'OLA-LocalAdmin'))
                                                                {
                                                                     
                                                                     $space >> $pathadmin 
                                                                     $computer >> $pathadmin  
                                                                     $text = "On computer is local admin: $admin"  
                                                                     $text >> $pathadmin                                
                                                                     $space >> $pathadmin  
                                                                }
                                                         }
                                                }
                                        }


                                 }

         
         
    }

    #send e-mail 

    ####################################################################################################
    ####################################################################################################
    ######################################################################################################
    ##################################################################################################

    
$smtpServer="mcchvac-com0i.mail.protection.outlook.com" 
$from = "Administrator IT <mcc-eu-wsr01@mcc-hvac.com>"  
$emailaddress = "wojciech.konikiewicz@mcc-hvac.com" 

# 
################################################################################################################### 
###COnvert to HTML################
[string]$adminnamehtml = "admins" + $data + ".htm"
$pathadminlocal = "C:\Cred_PS1\" + $adminname
$pathraporemial = "C:\Cred_PS1\" + $raportname

$SourceFile = $pathadminlocal
$TargetFile = "C:\Cred_PS1\" + $adminnamehtml
 
$File = Get-Content $SourceFile -ErrorAction SilentlyContinue
$FileLine = @()
Foreach ($Line in $File) {
 $MyObject = New-Object -TypeName PSObject
 Add-Member -InputObject $MyObject -Type NoteProperty -Name HealthCheck -Value $Line
 $FileLine += $MyObject
}
$FileLine | ConvertTo-Html    -body "<H2>Admin Local Raport</h2>" | Out-File $TargetFile

###################################################
########################################### 



# System Settings 
$textEncoding = [System.Text.Encoding]::UTF8 
 
 # Email Subject Set Here 
 $subject="Raport Local Admin" 
   
 # Email Body Set Here, Note You can use HTML, including Images.
 
 if (-not (test-path $pathadminlocal) ) 
    {
        $body_fill = "No local admins"
        
    }
    else {$body_fill = Get-Content -Path $TargetFile }
 
 if  (test-path $pathraporemial)  
    {
        $attachment = $pathraporemial
      }  


 $body = "$body_fill"
    
 
 # Send Email Message 
Send-Mailmessage -smtpServer $smtpServer -from $from -to $emailaddress  -subject $subject -body $body -BodyAsHtml -priority High -Attachments $attachment -Encoding $textEncoding    
 
  
 
# End