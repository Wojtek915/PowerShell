#Funkcjia tworzenia schedulera z restartem servera

#Podanie paramentrow do funkcji
$time = (Get-Date -Hour 1 -Minute 0 -Second 0).AddDays(1)   # Nastepngo dnia o 1.00
$Trigger= New-ScheduledTaskTrigger –Once -At $time # Specify the trigger settings
$User= "NT AUTHORITY\SYSTEM" # Specify the account to run the script
$Action= New-ScheduledTaskAction -Execute "PowerShell.exe" -Argument "Restart-Computer  -Force " # Specify what program to run and with its parameters
$Servers = Get-Content 'C:\Users\adminpol\Desktop\PS1\Restart-server\servers.txt'



#Czy resrtartowac wszytskie serwery
[string]$choise = (Read-Host "Restart each server YES/NO")

if ($choise -eq 'YES')
{
    foreach ($server in $servers)
      {
           
            #nawiazanie sesji ze zdalnym computerem
            Invoke-Command -ComputerName $Server -ScriptBlock {
                Register-ScheduledTask -TaskName "Restart Server" -Trigger $using:Trigger -User $using:User -Action $using:Action -RunLevel Highest –Force # Specify the name of the task }
            }
        }
}



if ($choise -eq 'NO')
{
    [string]$Serwer_name = (Read-Host "Which one server do you want restart (name)?")

    #nawiazanie sesji ze zdalnym computerem
    Invoke-Command -ComputerName $Serwer_name -ScriptBlock {
        Register-ScheduledTask -TaskName "Restart Server" -Trigger $using:Trigger -User $using:User -Action $using:Action -RunLevel Highest –Force # Specify the name of the task }
    }

}
