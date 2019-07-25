<# 
 
GeneratePrintJobAccountingReports.ps1 
ver. 2014-09-26-01 
 
This script reads event log ID 307 and ID 805 from the log "Applications and Services Logs > Microsoft > Windows > PrintService" 
from the specified server and for the specified time period and then calculates print job and total page count data from these  
event log entries. 
 
It then writes the output to two .CSV files, one showing by-print job data and the other showing by-user print job data. 
 
The script depends on specific event log data and text in event log ID 307 and 805 records and has been tested only on  
Windows Server 2008 R2 with SP1. 
 
Requirements: 
- Ensure the .NET Framework 3.5 or later is installed: 
  - Add ".NET Framework 3.5.1" under the ".NET Framework 3.5.1 Features" option using the "Add Features" option of Server Manager, or  
  - All Programs > Accessories > Windows PowerShell > right-click Windows PowerShell > Run as administrator... 
    Import-Module ServerManager 
    Add-WindowsFeature NET-Framework-Core 
- Enable and configure print job event logging on the desired print server: 
  - start Devices and Printers > (highlight any printer) > Print server properties > Advanced 
    - check "Show informational notifications for local printers" 
    - check "Show informational notifications for network printers" 
      - OK 
  - start Event Viewer > Applications and Services Logs > Microsoft > Windows > PrintService  
    - right-click Operational > Enable Log 
    - right-click Operational > Properties > Maximum log size (KB): 65536 (was 1028 KB by default) 
      - OK 
- Ensure that the user account used to run the script has write permission to the destination directory that will hold the 
  output .CSV files ("D:\Scripts\" in the code below). Change the .CSV paths and filenames in the code below as desired. 
- If the print server is a remote server, ensure that the user account used to run the script has remote procedure call  
  network access to the specified hostname, and that firewall rules permit such network access. 
- If the print server is logging events using a language other than English, customize the ID 805 message search string below 
  to match the language-appropriate string used in the print server's event ID 805 event log message. 
 
Usage: 
- see the PrintCommandLineUsage function, below 
 
Exit codes: 
- errorlevel 0 indicates no error (records were found and generated, or no records were found) 
- errorlevel 1 indicates an error (unparsable command-line parameters or missing ID 805 event log records) 
 
Implementation notes: 
- Case of a HP LaserJet P2055dn printer using the HP Universal Printing PCL 5 (v5.2) driver 
    The printer reports 0 copies on all jobs. 
    If a print job reporting 0 copies is seen by the script, it will output a warning and then consider the affected  
      print job to be printed with 1 copy as a guess of what the actual number of copies was. 
    The fix for this particular case was to upgrade the print driver to the HP Universal Printing PCL 5 (v5.5.0) driver. 
- Case of a HP LaserJet Pro 400 color printer model M451dn (CE957A) using the HP Universal Printing driver PCL 6 (v5.0.3),  
  the HP Universal Printing PCL 5 (v5.2) driver and the HP Universal Printing PS driver (v.5.0.3): 
    In all cases, this printer reports 1 copy of all jobs in Event ID 805, even when the user prints more than 1 copy of the job.  
    There is no way for the script to detect this. It was discovered through observation. 
    The fix was to clear the printer properties setting "Sharing > Render print jobs on client computers" (which is _enabled_ by default).  
    With this change, the number of copies per job was reported accurately in the Windows event log. 
    SUGGESTION: Check the generated .CSV file the first month and look check for printers that only ever report 1 copy of all jobs. These 
      printers may need the work-around to render on the server-side. 
 
History: 
- 2010-02 Original script written by Sh_Con at http://social.technet.microsoft.com/Forums/en-US/ITCG/thread/007be664-1d8d-461c-9e0b-d8177106d4f8 
- 2011-05 Modified by BSOD2600 at http://social.technet.microsoft.com/Forums/en-US/ITCG/thread/007be664-1d8d-461c-9e0b-d8177106d4f8 
- 2011-10 Modified by Tim Miller Dyck at PeaceWorks Technology Solutions to include the number of copies in page accounting by correlating with  
    event ID 805, add target print server hostname and date parameters, add the by-user total pages report and switch encoding from 
    Unicode to ASCII for better Excel .CSV compatibility. 
    Thanks to Mennonite Central Committee Canada for sponsoring this additional development. 
- 2012-09 Modified by Tim Miller Dyck at PeaceWorks Technology Solutions to include a warning about print jobs reporting zero copies,  
    add a warning about some print jobs incorrectly reporting one copy when more than one copy was printed, add the print job ID number  
    to the .CSV output, and change commas in the print job name to underscores for more reliable .CSV parsing with some clients. 
- 2014-09 Modified by Tim Miller Dyck at PeaceWorks Technology Solutions to add additional warning logging and robustness for rare cases where 
    event ID 805 messages are logged either 0 or more than 1 time for the same print job; add invalid document name character handling and PreviousDay  
    improvements suggested by commentators at http://gallery.technet.microsoft.com/scriptcenter/Script-to-generate-print-84bdcf69/view/Discussions#content 
 
#> 
 
##### 
# run in strict mode version 2 to catch initialized variables and nonexistent properties/functions 
 
Set-StrictMode -version 2 
 
##### 
# define initial variables 
 
$PrintJobCounter = 1                      # console display output counter 
$PerUserTotalPagesRecords = @{}           # create empty hash table 
 
##### 
# declare helper functions 
 
# function to print out usage data to the console 
Function PrintCommandLineUsage { 
    Write-Host " 
 
Here are the script's parameters: 
  (hostname) PreviousMonth -- Retrieve print job data from (hostname) based on 
                              the entire previous month. 
    or 
  (hostname) PreviousDay -- Retrieve print job data from (hostname) based on 
                            the entire previous day. 
    or 
  (hostname) (startdate) (enddate) -- Retrieve print job data from (hostname) 
                                      based on the specified start and end 
                                      dates. The date must be specified in a  
                                      format that matches the current system  
                                      locale (e.g. MM/dd/yyyy for United States). 
 
Examples: 
  powershell.exe -command `".\GeneratePrintJobAccountingReports.ps1 localhost PreviousMonth`" 
  powershell.exe -command `".\GeneratePrintJobAccountingReports.ps1 printserver.domain.local 08/01/2014 08/02/2014`" 
 
" 
} 
 
##### 
# parse command-line parameters 
 
switch ($args.count) { 
    {($_ -eq 2) -or ($_ -eq 3)} { 
        # if there are two or three parameters, the first parameter is the print server hostname from which event logs will be retrieved 
        $PrintServerName = $args[0] 
        Write-Host "Print server hostname to query:" $PrintServerName 
    } 
    2 { 
        # if there are exactly two parameters, check that the second one is is "PreviousMonth" or "PreviousDay" (using the default case-insensitive comparison) 
        if ($args[1].CompareTo("PreviousMonth") -eq 0) { 
            # the start time is at the start (00:00:00) of the first day of the previous month 
            $StartDate = (Get-Date -Day 1 -Hour 0 -Minute 0 -Second 0).AddMonths(-1) 
            # the end time is at the end (23:59:59) of the last day of the previous month 
            $EndDate = (Get-Date -Day 1 -Hour 0 -Minute 0 -Second 0) - (New-Timespan -Second 1) 
        } 
        elseif ($args[1].CompareTo("PreviousDay") -eq 0) { 
            # the start time is at the start (00:00:00) of the previous day 
            $StartDate = (Get-Date -Hour 0 -Minute 0 -Second 0).AddDays(-1) 
            # the end time is at the end (23:59:59) of the previous day 
            $EndDate = (Get-Date -Hour 23 -Minute 59 -Second 59).AddDays(-1) 
        } 
        else { 
            # there was a unrecognized command-line parameter, so print usage data and exit with errorlevel 1 
            Write-Host "`nERROR: Two command-line parameters were detected but the second comand-line parameter was not `"PreviousMonth`" or `"PreviousDay`"." 
            PrintCommandLineUsage 
            Exit 1 
        } 
    } 
    3 { 
        # if there are exactly three parameters, check that the second and third ones are dates 
        # set error-handling to silently continue as errors are checked explicitly 
        $ErrorActionPreference = "SilentlyContinue" 
        # the start time is at the start of the indicated date (12:00:00 AM) 
        $StartDate = Get-Date -Date $args[1] 
        # check if the command-line parameter was recognized as a valid date 
        if (!$?) { 
            # there was a unrecognized command-line parameter, so print usage data and exit with errorlevel 1 
            Write-Host "`nERROR: Three command-line parameters were detected but the second comand-line parameter was not a valid date." 
            PrintCommandLineUsage 
            Exit 1 
        } 
        # the end time is at the end of the indicated date (11:59:59 PM) -- add a day and then subtract one second 
        $EndDate = (Get-Date -Date $args[2]) + (New-Timespan -Day 1) - (New-Timespan -Second 1) 
        # check if the command-line parameter was recognized as a valid date 
        if (!$?) { 
            # there was a unrecognized command-line parameter, so print usage data and exit with errorlevel 1 
            Write-Host "`nERROR: Three command-line parameters were detected but the third comand-line parameter was not a valid date." 
            PrintCommandLineUsage 
            Exit 1 
        } 
        # set error-handling back to default 
        $ErrorActionPreference = "Continue" 
    } 
    default { 
        # there are no command-line parameters present or too many, so print usage data and exit with errorlevel 1 
        Write-Host "`nERROR: No or too many command-line parameters were detected." 
        PrintCommandLineUsage 
        Exit 1 
    } 
} 
 
##### 
# define .CSV output filenames 
 
$OutputFilenameByPrintJob = "D:\Scripts\Print job accounting report by print job for print server host " + $PrintServerName + " - " + $StartDate.ToString("yyyy-MM-dd") + " to " + $EndDate.ToString("yyyy-MM-dd") + ".csv"    # enter the desired output filename 
$OutputFilenameByUser = "D:\Scripts\Print job accounting report by user for print server host " + $PrintServerName + " - " + $StartDate.ToString("yyyy-MM-dd") + " to " + $EndDate.ToString("yyyy-MM-dd") + ".csv"             # enter the desired output filename 
 
##### 
# get the ID 307 and ID 805 event log entries 
 
# display status message 
Write-Host "Collecting event logs found in the specified time range from $StartDate to $EndDate." 
 
# the main print job entries are event ID 307 (use "-ErrorAction SilentlyContinue" to handle the case where no event log messages are found) 
$PrintEntries = Get-WinEvent -ErrorAction SilentlyContinue -ComputerName $PrintServerName -FilterHashTable @{ProviderName="Microsoft-Windows-PrintService"; StartTime=$StartDate; EndTime=$EndDate; ID=307} 
# the by-job number of copies are in event ID 805 (use "-ErrorAction SilentlyContinue" to handle the case where no event log messages are found) 
$PrintEntriesNumberofCopies = Get-WinEvent -ErrorAction SilentlyContinue -ComputerName $PrintServerName -FilterHashTable @{ProviderName="Microsoft-Windows-PrintService"; StartTime=$StartDate; EndTime=$EndDate; ID=805} 
 
# check for found data; if no event log ID 307 records were found, exit the script without creating an output file (this is not an error condition) 
if (!$PrintEntries) { 
    Write-Host "There were no print job event ID 307 entries found in the specified time range from $StartDate to $EndDate. Exiting script." 
    Exit 
} 
 
# otherwise, display the number of found records and continue 
#   Measure-Object is needed to handle the case where exactly one event log entry is returned 
Write-Host "  Number of print job event ID 307 entries found:" ($PrintEntries | Measure-Object).Count 
Write-Host "  Number of print job event ID 805 entries found:" ($PrintEntriesNumberofCopies | Measure-Object).Count 
 
# display status message 
Write-Host "Parsing event log entries and writing data to the by-print job .CSV output file `"$OutputFilenameByPrintJob`"..." 
 
# write initial header to by-job output file 
Write-Output "Date,Print Job ID,User Name,Full Name,Client PC Name,Printer Name,Document Name,Print Job Size in Bytes,Page Count for One Copy,Number of Copies,Total Pages" | Out-File -FilePath $OutputFilenameByPrintJob -Encoding ASCII 
 
##### 
# loop to parse ID 307 event log entries 
 
ForEach ($PrintEntry in $PrintEntries) { 
 
    # get the date and time of the print job from the TimeCreated field 
    $StartDate_Time = $PrintEntry.TimeCreated 
 
    # convert the event log to an XML data structure 
    #   Note that a print job document name that contains unusual characters that cannot be converted to XML will cause the .ToXml()  
    #   method to fail so place a try/catch block around this code to address this condition. As an additional check, Windows Event Log Viewer  
    #   will also fail to display the same event; the Details tab for the event will report "This event is not displayed correctly because the underlying XML is not well formed". 
    #   Thanks to user Syncr0s for the report and fix posted at http://gallery.technet.microsoft.com/scriptcenter/Script-to-generate-print-84bdcf69/view/Discussions#content 
    try { 
        $entry = [xml]$PrintEntry.ToXml() 
    } 
    catch { 
        # if ToXml has raised an error, log a warning to the console and the output file 
        $Message = "WARNING: Event log ID 307 event at time $StartDate_Time has unparsable XML contents. This is usually caused by a print job document name that contains unusual characters that cannot be converted to XML. Please investigate further if possible. Skipping this print job entry entirely without counting its pages and continuing on..." 
        Write-Host $Message 
        Write-Output $Message | Out-File -FilePath $OutputFilenameByPrintJob -Encoding ASCII -Append 
        # and then immediately continue on with the next event ID 307 message, skipping the problem event log message 
        Continue 
    } 
 
    # retreive the remaining fields from the event log UserData structure 
    $PrintJobId = $entry.Event.UserData.DocumentPrinted.Param1 
    $DocumentName = $entry.Event.UserData.DocumentPrinted.Param2 
    $UserName = $entry.Event.UserData.DocumentPrinted.Param3 
    $ClientPCName = $entry.Event.UserData.DocumentPrinted.Param4 
    $PrinterName = $entry.Event.UserData.DocumentPrinted.Param5 
    $PrintSizeBytes = $entry.Event.UserData.DocumentPrinted.Param7 
    $PrintPagesOneCopy = $entry.Event.UserData.DocumentPrinted.Param8 
 
    # get the user's full name from Active Directory 
    if ($UserName -gt "") { 
        $DirectorySearcher = New-Object System.DirectoryServices.DirectorySearcher 
        $LdapFilter = "(&(objectClass=user)(samAccountName=${UserName}))" 
        $DirectorySearcher.Filter = $LdapFilter 
        $UserEntry = [adsi]"$($DirectorySearcher.FindOne().Path)" 
        $ADName = $UserEntry.displayName 
    } 
  
    # get the print job number of copies by correlating with event ID 805 records 
    #  the ID 805 record always is logged immediately before (that is, earlier in time) its related 307 record 
    #  the print job ID number wraps after reaching 255, so we need to check both for a matching job ID and a very close logging time (within the previous 5 seconds) to its related event ID 307 record 
    #  the print job ID match is based on a specific text string in the language of your Windows installation 
    #    English search string: "Rendering job $PrintJobId." 
    #    German search string: "Der Auftrag $PrintJobId wird gerendert." (thanks to user DJ83's post at http://gallery.technet.microsoft.com/scriptcenter/Script-to-generate-print-84bdcf69/view/Discussions#content) 
    $PrintEntryNumberofCopies = $PrintEntriesNumberofCopies | Where-Object {$_.Message -eq "Rendering job $PrintJobId." -and $_.TimeCreated -le $StartDate_Time -and $_.TimeCreated -ge ($StartDate_Time - (New-Timespan -second 5))} 
 
    # check for the expected case of exactly one matching event ID 805 event log record for the source event ID 307 record 
    #   if this is true then extract the number of print job copies for the matching print job 
    if (($PrintEntryNumberofCopies | Measure-Object).Count -eq 1) { 
        # retrieve the remaining fields from the event log contents 
        $entry = [xml]$PrintEntryNumberofCopies.ToXml() 
        $NumberOfCopies = $entry.Event.UserData.RenderJobDiag.Copies 
        # some flawed printer drivers always report 0 copies for every print job; output a warning so this can be investigated further and set copies to be 1 in this case as a guess of what the actual number of copies was 
        if ($NumberOfCopies -eq 0) { 
            $NumberOfCopies = 1 
            $Message = "WARNING: Printer $PrinterName recorded that print job ID $PrintJobId was printed with 0 copies. This is probably a bug in the print driver. Upgrading or otherwise changing the print driver may help. Guessing that 1 copy of the job was printed and continuing on..." 
            Write-Host $Message 
            Write-Output $Message | Out-File -FilePath $OutputFilenameByPrintJob -Encoding ASCII -Append 
        } 
    } 
    # otherwise, either no or more than 1 matching event log ID 805 record was found 
    #   both cases are unusual error conditions so report the error but continue on, assuming one copy was printed 
    else { 
        $NumberOfCopies = 1 
        $Message = "WARNING: Printer $PrinterName recorded that print job ID $PrintJobId had $(($PrintEntryNumberofCopies | Measure-Object).Count) matching event ID 805 entries in the search time range from $(($StartDate_Time - (New-Timespan -second 5))) to $StartDate_Time. Logging this as a warning as only a single matching event log ID 805 record should be present. Please investigate further if possible. Guessing that 1 copy of the job was printed and continuing on..." 
        Write-Host $Message 
        Write-Output $Message | Out-File -FilePath $OutputFilenameByPrintJob -Encoding ASCII -Append 
    } 
 
    # calculate the total number of pages for the whole print job 
    $TotalPages = [int]$PrintPagesOneCopy * [int]$NumberOfCopies 
 
    # write output to output file 
    #   put the print document name in double-quotes in case it contains a comma 
    #   additional document name comma-handling: some .CSV clients don't recognize the double-quotes, so replace commas with underscores for this field 
    $Output = $StartDate_Time.ToString() + "," + $PrintJobId + "," + $UserName + "," + $ADName + "," + $ClientPCName + "," + $PrinterName + ",`"" + ($DocumentName -replace ",", "_") + "`"," + $PrintSizeBytes + "," + $PrintPagesOneCopy + "," + $NumberOfCopies + "," + $TotalPages 
    Write-Output $Output | Out-File -FilePath $OutputFilenameByPrintJob -Encoding ASCII -Append 
     
    # update the user's job total page count 
    $UserNameKey = "`"$UserName ($ADName)`"" 
    # if the user is not in the hash table yet, add them and their initial total page count 
    if (!$PerUserTotalPagesRecords.ContainsKey($UserNameKey)) { 
        $PerUserTotalPagesRecords.Add($UserNameKey,$TotalPages) 
    } 
    # if the user is already in the hash table, update their total page count 
    else { 
        $PerUserTotalPagesRecords.Set_Item($UserNameKey,$PerUserTotalPagesRecords.Get_Item($UserNameKey) + $TotalPages) 
    } 
     
    # display status message 
    Write-Host "  Print job $PrintJobCounter (job ID $PrintJobId printed at $StartDate_Time) processed." 
    $PrintJobCounter++ 
 
} 
 
##### 
# do per user job accounting 
 
# display status message 
Write-Host "Writing data to the by-user .CSV output file `"$OutputFilenameByUser`"..." 
 
# write initial header to by-user output file 
Write-Output "User Name (Full Name),Total Pages" | Out-File -FilePath $OutputFilenameByUser -Encoding ASCII 
 
# write output to the by-user output file in an order that is sorted alphabetically by username 
ForEach ($PerUserTotalPagesRecordsKey in ($PerUserTotalPagesRecords.Keys | sort)) { 
  $Output = $PerUserTotalPagesRecordsKey + "," + $PerUserTotalPagesRecords.Get_Item($PerUserTotalPagesRecordsKey) 
  Write-Output $Output | Out-File -FilePath $OutputFilenameByUser -Encoding ASCII -Append 
} 
 
##### 
# quit 
 
Write-Host "Finished." 