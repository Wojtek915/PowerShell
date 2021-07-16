#####Golem Veryficaion#####

$computer = "olasrv08"
if (Get-Process -ComputerName $computer -Name "Golem*")
        {
            Write-host "Proces dziala"
        }
        else {
                Invoke-Command -ComputerName $computer -ScriptBlock {  Start-ScheduledTask -TaskName "Golem" } -Credential adminpol

        }