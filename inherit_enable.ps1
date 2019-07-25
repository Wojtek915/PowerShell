Function FixInheritance([string] $Directory)
{
   $AllFiles = Get-ChildItem -Recurse -Force $Directory
   ForEach ($File in $AllFiles)
   {

      #Pobierz uprawnienia bieżącego pliku/folderu
      $acl = get-acl $File.FullName
      #Zmien ustawienia dziedziczenia
      $acl.SetAccessRuleProtection($false, $false);
      #Zapisz uprawnienia dla pliku
      set-acl -aclobject $acl $File.FullName
      #Kropka jako pasek postępu
      Write-Host "." -NoNewline
   }
   Write-Host
 }

 Clear
FixInheritance "C:\test"