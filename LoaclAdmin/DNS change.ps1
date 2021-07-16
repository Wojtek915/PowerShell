
$computers = Get-Content -Path ""
foreach ($computer in $computers) {
Invoke-Command -ComputerName $computer -ScriptBlock {
                                                        $Indexes= Get-NetAdapter | where status -eq "up"
                                                        foreach ($Index in $Indexes) {
                                                        Set-DnsClientServerAddress   -InterfaceIndex $Index.ifIndex -ServerAddresses ("") }

                                                        }
                                                     }
