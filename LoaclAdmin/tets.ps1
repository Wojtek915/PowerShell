
#####################################################
#name of file
[string]$data = Get-Date  -Format "yyyyMMdd"

[string]$pathraport = "I:\" + "raport" + $data + ".txt"
[string]$pathadmin = "I:\" + "admins" + $data + ".txt"
[string]$raportname =  "raport" + $data + ".txt"
[string]$adminname = "admins" + $data + ".txt"
###############################################

##########################################################
#credetiale
if (-not (test-path C:\Cred_PS1\cred.xml) ) 
    {
        $cred = Get-Credential
        $cred | Export-Clixml C:\Cred_PS1\cred.xml
        
    }

if (-not (test-path C:\Cred_PS1\pass.txt) ) 
    {
        Read-Host -AsSecureString| ConvertFrom-SecureString | Out-File "C:\Cred_PS1\pass.txt"
        
    }

$Password = Get-Content "C:\Cred_PS1\pass.txt" | ConvertTo-SecureString
$cred1 = Import-Clixml C:\Cred_PS1\cred.xml
###########################################################
# 
###########################################################
#get AD-computer from DOmain Controller 
$computers = Get-ADComputer -Filter 'Name -like "*olanb024*"'  -SearchBase "OU=Computers,OU=Olawa,DC=eu,DC=mcc-hvac,DC=in" |sort -Descending | select -ExpandProperty Name 

###########################################################
#loop
foreach ($computer in $computers)
    {
       
       Write-host $computer

       Invoke-Command -ComputerName $computer -ScriptBlock {
                        
                             ###############################################################################
                             ## Start of SCRIPBLOCK###################
                             ###########################################################
                            ###############################################################################
                            #sprawdzenie modulu
                            IF ( -not (Get-command -Module LocalAccount )) 
                                {
                           
                               
                                install-module -name LocalAccount -AllowClobber -Force
                                }
                            ###############################################################################  
                            #Export to server - Generate Raport -- check ver OS Pl/EN
                            New-PSDrive –Name “I” –PSProvider FileSystem –Root "\\MCC-EU-WSR01\ModulePS1" -Credential $Using:cred1
         
                            if ((Get-WmiObject -Class Win32_OperatingSystem -Property Oslanguage | select -ExpandProperty OSLanguage)  -eq 1045) 
                                {$env:computername >> $Using:pathraport   
                                  $admins = Get-LocalGroupMember -Name Administratorzy
                                  $group = "Administratorzy"
                                 Get-LocalGroupMember -Name Administratorzy  | Out-File -FilePath $Using:pathraport  -Append
                                 $space = '------------------'
                                 $space  >> $using:pathraport
                                }
                            else 
                                {
                                $env:computername >> $Using:pathraport    
                                $admins = Get-LocalGroupMember -Name Administrators
                                $group = "Administrators"
                                 Get-LocalGroupMember -Name Administrators | Out-File -FilePath $Using:pathraport -Append
                                 $space = '------------------'
                                }
                            ###############################################################################                      
                            #### sprawdzenie uzytkownika mcc
                            if ((Get-LocalGroupMember -Name Administratorzy) -like "mcc")
                            {
                                 
                                  Get-LocalUser -Name "mcc"| Set-LocalUser -Password $Using:Password  
                                  Write-host "Jest mcc" -BackgroundColor Green
                            }
                            else
                             {
                                New-LocalUser -Name "mcc" -Password $Using:Password
                                Add-LocalGroupMember -Group $group -Name "mcc"
                                Write-host "Jest new mcc" -BackgroundColor Green
                               
                            }
                           ###############################################################################
                           #sprawdzenie lokalnych adminow wraz z usunieciem dodatkowych
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
                                                                     
                                                                     $env:computername >> $Using:pathadmin  
                                                                     $space >> $Using:pathadmin     
                                                                     $text = "On computer is local admin: $admin"  
                                                                     $text >> $Using:pathadmin
                                                                    
                                                                     
                                                                     #delete user
                                                                     Remove-LocalUser -Name $admin -ErrorAction SilentlyContinue
                                                                     Remove-LocalGroupMember -Name $admin -GroupName $group 
                                                                     $text = "Local admin deleted: $admin" 
                                                                     $text >> $Using:pathadmin  
                                                                     $space >> $pathadmin  
                                                                }
                                                         }
                                                }
                                        }


                                 }
                         ###############################################################################
                         ## END of SCRIPBLOCK###################
                         ############################################################
                        
                        
       }  -Credential $cred1 
  
       
         
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
$pathadminlocal = "C:\ModulePS1\" + $adminname
$pathraporemial = "C:\ModulePS1\" + $raportname

$SourceFile = $pathadminlocal
$TargetFile = "C:\ModulePS1\" + $adminnamehtml
 
$File = Get-Content $SourceFile
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