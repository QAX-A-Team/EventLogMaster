function RemoteConnectionManager {
    Try {
        Get-WinEvent -ListLog Security|out-null
    }
    Catch { return 'PowerShell Get-WinEvent cmdlet Error.' }
    Try {
        $SuccessResults=Get-WinEvent -LogName 'Microsoft-Windows-TerminalServices-RemoteConnectionManager/operational' -FilterXPath "*[System[EventID=1149]]" -ErrorAction Stop
        $SuccessResults | Foreach {
            $entry = [xml]$_.ToXml()
            [array]$Output += New-Object PSObject -Property @{
                "TimeCreated" = $_.TimeCreated
                "EventID" = $entry.Event.System.EventID
                "EventRecordID" = $entry.Event.System.EventRecordID
                "TargetUserName" = $entry.Event.UserData.EventXML.Param1
                "SubjectDomainName" = $entry.Event.UserData.EventXML.Param2
                "IpAddress" = $entry.Event.UserData.EventXML.Param3
                }
        }
        $Output | Select-Object TimeCreated,EventID,EventRecordID,TargetUserName,SubjectDomainName,IpAddress
    }
    Catch { return 'Result: Null'}
}