$computers = Get-ADComputer -Filter *  -Properties name,OperatingSystem | where -Property OperatingSystem -like "*pro*"  |sort -Descending | select name 

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


foreach ($computer in $computers)
    {
       
       Write-host $computer

       Invoke-Command -ComputerName $computer.name -Credential $cred1 -ScriptBlock  {
                        
                             ###############################################################################
                             ## Start of SCRIPBLOCK###################
                             ###########################################################
                            ###############################################################################
                            
                            
                            slmgr.vbs /ipk JFVND-J8842-CRRTR-8JPJB-2PQF4
                            

                            }


                }