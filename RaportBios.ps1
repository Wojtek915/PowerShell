   
function RaportBios
{

[CmdletBinding()]
Param(
    [Parameter(Mandatory=$True)]
	[string]$Path,
    [string]$ComputerF
	
)



$BiosUpdate = $Path

#*********************************************************

# RaportBios 

$BIOSVersion = $((Get-CimInstance -ComputerName $computerF -ClassName Win32_BIOS).SMBIOSBIOSVersion).Trim()
$VerBios = "*" + $BIOSVersion + "*"

if (Test-Connection $computerF -Count 2) {



	if ($BiosUpdate -like $VerBios) {
        $export = "Computer: $computerF; Bios ver.: $BIOSVersion; UpToData; $BiosUpdate"

		$export >> "C:\temp\raportbios.txt"

	    }

    else {
      $export = "Computer: $computer; Bios ver.: $BIOSVersion; ToUpdate; $BiosUpdate"
	  $export >> "C:\temp\raportbios.txt"
        }


	}


else
{$ping =  "$ComputerF Host offilne" 
$ping >> "C:\temp\raportbios.txt"}
	
	
#*********************************************************
};





$OU="OU=Computers,OU=Olawa,DC=eu,DC=mcc-hvac,DC=in"
$computers = Get-ADComputer -Filter *  -SearchBase $OU |sort -Descending | select -ExpandProperty Name 
#$computers = "OLAPC002"
foreach ($computer in $computers){

    #======================================================================================
	#System Information
	
	$Model = $((Get-WmiObject -ComputerName $computer -Class Win32_ComputerSystem).Model).Trim()
	


$modelscomputers = Import-Csv -Path raport.csv

foreach ($modelcomputer in $modelscomputers)
{
    if ($Model -like $modelcomputer.model ) {
                     write-host $modelcomputer.web
			         $SourceFile=$modelcomputer.web

                    RaportBios -Path $SourceFile  $computer
		                       
        }

}





}





