 if ((Get-LocalGroupMember -Name Administratorzy) -like "mcc")
                             {
                                
                              
                                 Write-host "Jest mcc" -BackgroundColor Green
                            }
                             else
                             {
                            #   New-LocalUser -Name "mcc" -Password $Using:Password
                            #    Add-LocalGroupMember -Group $group -Name "mcc"
                              Write-host "Nie ma mcc" -BackgroundColor Green
                            #   
                             }
 
 #delete user
                                                                     #Remove-LocalUser -Name $admin -ErrorAction SilentlyContinue
                                                                     #Remove-LocalGroupMember -Name $admin -GroupName $group 
                                                                     #$text = "Local admin deleted: $admin" 
                                                                     #$text >> $Using:pathadmin  