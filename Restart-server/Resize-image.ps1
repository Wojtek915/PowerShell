

 $files= Get-ChildItem 'P:\MAINTENANCE' -Include "*.jpg" -Recurse
 
 foreach ($file in $files) {
 $out='C:\temp\' + $file.Name
 $file.FullName
 Resize-Image -InputFile $file.FullName  -Width 1920 -Height 1080 -ProportionalResize $true -OutputFile $out  -Verbose
 sleep 70
 Copy-Item $out $file.DirectoryName -Force
 rm $out 
  }