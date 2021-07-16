
$computers = Get-Content -Path "C:\Users\adminpol\Desktop\PS1\Restart-server\servers.txt"
foreach ($computer in $computers) {
Invoke-Command -ComputerName $computer -ScriptBlock {
                                                        $Indexes= Get-NetAdapter | where status -eq "up"
                                                        foreach ($Index in $Indexes) {
                                                        Set-DnsClientServerAddress   -InterfaceIndex $Index.ifIndex -ServerAddresses ("192.168.85.19","192.168.85.20") }

                                                        }
                                                     }