Write-host "Map network Drive"
Write-host ""
Write-host "Jochen                      -select 1"
Write-host "Erik, Israel, Pablo, Rafael- select 2"
Write-host "Rest of useres             - select 3"
Write-host "Select the number:"
$select= Read-Host ;

#ALL
if ($select = 3){
NET USE P: /delete /y
NET USE P: \\MCC-EU-WSR01.EU.MCC-HVAC.IN\PUBLIC /persistent:yes

NET USE K: /delete /y
NET USE K: \\RENSRV01.EU.MCC-HVAC.IN\PUBLIC-DE /persistent:yes

NET USE S: /delete /y
NET USE S: \\RENSRV01\00. scans

NET USE R: /delete /y
NET USE R: \\NTJSRV10\ritningar

NET USE G: /delete /y
NET USE G: \\NTJSRV10\gemensam

NET USE L: /delete /y
NET USE L: \\NTJSRV10\pdf_library
}

##Erik, Israel, Pablo, Rafael and myself
if ($select = 2){
NET USE Y: /delete /y
NET USE Y: \\10.85.40.81\yrkdrawings_test

NET USE Z: /delete /y
NET USE Z: \\10.85.40.72\pdf_library

NET USE T: /delete /y
NET USE T: \\10.85.40.72\Drawings

NET USE P: /delete /y
NET USE P: \\MCC-EU-WSR01.EU.MCC-HVAC.IN\PUBLIC /persistent:yes

NET USE K: /delete /y
NET USE K: \\RENSRV01.EU.MCC-HVAC.IN\PUBLIC-DE /persistent:yes

NET USE S: /delete /y
NET USE S: \\RENSRV01\00. scans

NET USE R: /delete /y
NET USE R: \\NTJSRV10\ritningar

NET USE G: /delete /y
NET USE G: \\NTJSRV10\gemensam

NET USE L: /delete /y
NET USE L: \\NTJSRV10\pdf_library

}

#Jochen
if ($select = 1){
NET USE V: /delete /y
NET USE V: \\10.85.40.81\Common
NET USE Y: /delete /y
NET USE Y: \\10.85.40.81\yrkdrawings_test

NET USE Z: /delete /y
NET USE Z: \\10.85.40.72\pdf_library

NET USE T: /delete /y
NET USE T: \\10.85.40.72\Drawings

NET USE P: /delete /y
NET USE P: \\MCC-EU-WSR01.EU.MCC-HVAC.IN\PUBLIC /persistent:yes

NET USE K: /delete /y
NET USE K: \\RENSRV01.EU.MCC-HVAC.IN\PUBLIC-DE /persistent:yes

NET USE S: /delete /y
NET USE S: \\RENSRV01\00. scans

NET USE R: /delete /y
NET USE R: \\NTJSRV10\ritningar

NET USE G: /delete /y
NET USE G: \\NTJSRV10\gemensam

NET USE L: /delete /y
NET USE L: \\NTJSRV10\pdf_library
}