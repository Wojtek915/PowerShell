#Wejdz w folder
#przesun wszytsko co jest w folderze
#Sprawdz czy folder jest pusty

# P:\SALES\ReadOnly\SKANY WZ-TEK CUSTOMER SERVICE
# P:\00. SKANY\Sales

$items = Get-ChildItem -Path 'P:\Public\00. SKANY\WZ'

foreach ($item in $items){
$item

Move-Item -Path $item.FullName  -Destination "P:\Public\SALES\ReadOnly\SKANY WZ-TEK CUSTOMER SERVICE" }