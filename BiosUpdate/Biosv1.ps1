#$OU="OU=..."
#$computers = Get-ADComputer -Filter *  -SearchBase $OU |sort -Descending | select -ExpandProperty Name 

foreach ($computer in $computers) {


if (Test-Path "\\$computer\C$\temp\BiosUpdate" ) {
                Copy-Item "C:\Users\adminpol\Desktop\PS1\BiosUpdate\models.csv" "\\$computer\C$\temp\BiosUpdate"}

            else {New-Item -Path "\\$computer\C$\temp\BiosUpdate" -ItemType Directory
                  Copy-Item "C:\Users\adminpol\Desktop\PS1\BiosUpdate\models.csv" "\\$computer\C$\temp\BiosUpdate"}

Invoke-Command -ComputerName $computer  -ScriptBlock  {
   
function UpdateBios
{

[CmdletBinding()]
Param(
    [Parameter(Mandatory=$True)]
	[string]$Path,
	[switch]$Restart,
	[switch]$Silent
)

Write-Host "UpdatelBios" -ForegroundColor RED
Start-Transcript -path (Join-Path "$env:temp" BiosUpdate.log)

#**********************************************************
#Ładowanie pliku z aktualizcja

$BiosUpdate = $Path

	if ($BiosUpdate.Count -eq '1') {
		Write-Host "Local Bios Update" -ForegroundColor Green
		$BiosUpdate
	} else {
		Write-Host "Could not locate a downloaded BIOS Update ... Exiting" -ForegroundColor Green
		Sleep  -s 5
		Stop-Transcript
		#Exit 0
	}
#*********************************************************
#*********************************************************

# Update Bios

$BIOSVersion = $((Get-CimInstance -ClassName Win32_BIOS).SMBIOSBIOSVersion).Trim()
$VerBios = "*" + $BIOSVersion + "*"
	

	if ($BiosUpdate -like $VerBios) {
		Write-Host "You are running the current BIOS Version ... Exiting" -ForegroundColor Cyan
		Sleep -s 10
		Stop-Transcript
		Exit 0
	}


	Write-Host "Starting Dell Bios Update ..." -ForegroundColor Green
	
	#Registry Restart Computer Key
	$registryPath = "HKLM:\Software\BiosUpdate"
	$registryName = "RebootPending"
	$registryValue = "0"

	if (!(Test-Path $registryPath)) {
		New-Item -Path $registryPath -Force | Out-Null
		New-ItemProperty -Path $registryPath -Name $registryName -Value $registryValue -PropertyType String -Force | Out-Null
	}

	

	if ($RunningOS -Like "*Windows 10*") {
		Write-Host "Checking Bitlocker ..." -ForegroundColor Green
		#http://www.dptechjournal.net/2017/01/powershell-script-to-deploy-dell.html
		#https://github.com/dptechjournal/Dell-Firmware-Updates/blob/master/Install_Dell_Bios_upgrade.ps1
		$drive = Get-BitLockerVolume | where { $_.ProtectionStatus -eq "On" -and $_.VolumeType -eq "OperatingSystem" }
		if ($drive) {
			Write-Host "Suspending Bitlocker ..." -ForegroundColor Green
			Suspend-BitLocker -Mountpoint $drive -RebootCount 1
			if (Get-BitLockerVolume -MountPoint $drive | where ProtectionStatus -eq "On") {
				Write-Host "Suspending Bitlocker Failed ... Exiting" -ForegroundColor Green
				Stop-Transcript
				Exit 0
			}
		}
	}
		
	if ($Silent) {
		Write-Host "Executing (Silent): $BiosUpdate" -ForegroundColor Green
		Start-Process $BiosUpdate -ArgumentList "/s" -Wait
		New-ItemProperty -Path $registryPath -Name $registryName -Value "1" -PropertyType String -Force | Out-Null
		Stop-Transcript
		[System.Environment]::Exit(0)
	} elseif ($Restart) {
		Write-Host "System will restart automatically" -ForegroundColor Green
		Write-Host "Executing (Restart): $BiosUpdate" -ForegroundColor Green
		Stop-Transcript
		Start-Process $BiosUpdate -ArgumentList "/s","/r" -Wait
		[System.Environment]::Exit(0)
	} else {
		Write-Host "System will restart automatically" -ForegroundColor Green
		Write-Host "Executing: $BiosUpdate" -ForegroundColor Green
		Start-Process $BiosUpdate -Wait
		Stop-Transcript
		[System.Environment]::Exit(0)
	}

#*********************************************************
};

if (Test-Path "C:\temp\BiosUpdate" ) {
            Set-Location "C:\temp\BiosUpdate" }
            else {New-Item -Path '"C:\temp\BiosUpdate' -ItemType Directory
            Set-Location "C:\temp\BiosUpdate"}

    #======================================================================================
	#System Information
	$global:Manufacturer = $((Get-WmiObject -Class Win32_ComputerSystem).Manufacturer).Trim()
	$Model = $((Get-WmiObject -Class Win32_ComputerSystem).Model).Trim()
	$SystemSKU = "Unknown"
	$SerialNumber = $((Get-WmiObject -Class Win32_BIOS).SerialNumber).Trim()
	$BIOSVersion = $((Get-WmiObject -Class Win32_BIOS).SMBIOSBIOSVersion).Trim()
	$RunningOS = $((Get-WmiObject -Class Win32_OperatingSystem).Caption).Trim()
	$OSArchitecture = $((Get-WmiObject -Class Win32_OperatingSystem).OSArchitecture).Trim()
	
	Write-Host "Manufacturer: $Manufacturer" -ForegroundColor Cyan
	Write-Host "Model: $Model" -ForegroundColor Cyan
	Write-Host "SystemSKU: $SystemSKU" -ForegroundColor Cyan
	Write-Host "SerialNumber: $SerialNumber" -ForegroundColor Cyan
	Write-Host "BIOS Version: $BIOSVersion" -ForegroundColor Cyan
	Write-Host "Running OS: $RunningOS" -ForegroundColor Cyan
	Write-Host "OS Architecture: $OSArchitecture" -ForegroundColor Cyan
	Write-Host ""
	#======================================================================================


$modelscomputers = Import-Csv -Path models.csv
$DownloadDir = '.\'

foreach ($modelcomputer in $modelscomputers)
{
    if ($Model -like $modelcomputer.model ) {
                     write-host $modelcomputer.web
			         $SourceFile=$modelcomputer.web
		            
                    
        }
}

if (Test-Path $DownloadDir) {
			            Import-Module BitsTransfer
			            Write-Host "Starting Bits Transfer . . ."
			            Start-BitsTransfer -Source $SourceFile -Destination $DownloadDir
			            Write-Host "Success!"
		            } 

$PathFile=(Get-ChildItem ".\" -Filter "*.exe") |Select-Object $_.FullName

UpdateBios -Path $PathFile.FullName  -Silent 

 }

 }
