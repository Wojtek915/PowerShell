$OU="DC=eu,DC=mcc-hvac,DC=in"

$computers=Get-ADComputer -Filter *  -SearchBase $OU |sort -Descending | select -ExpandProperty Name 

foreach ($computer in $computers) {

$computer

Invoke-Command -ComputerName $computer  -ScriptBlock  {


Stop-Service -Name BITS, wuauserv -Force
Remove-ItemProperty -Name AccountDomainSid, PingID, SusClientId, SusClientIDValidation -Path HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\WindowsUpdate\ -ErrorAction SilentlyContinue
Remove-Item "$env:SystemRoot\SoftwareDistribution\" -Recurse -Force -ErrorAction SilentlyContinue
Start-Service -Name BITS, wuauserv
wuauclt /resetauthorization /detectnow
(New-Object -ComObject Microsoft.Update.AutoUpdate).DetectNow()


}

}