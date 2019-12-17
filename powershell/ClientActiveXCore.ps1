function ClientActiveXCore {
    Try {
        Get-WinEvent -ListLog Security|out-null
    }
    Catch { return 'PowerShell Get-WinEvent cmdlet Error.' }
    Try {
        $SuccessResults=Get-WinEvent -LogName 'Microsoft-Windows-TerminalServices-RDPClient/Operational' -FilterXPath "*[System[EventID=1024]]" -ErrorAction Stop
        $SuccessResults | Foreach {
            $entry = [xml]$_.ToXml()
            [array]$Output += New-Object PSObject -Property @{
                "TimeCreated" = $_.TimeCreated
                "EventID" = $entry.Event.System.EventID
                "EventRecordID" = $entry.Event.System.EventRecordID
                "Name" = $entry.Event.EventData.Data[0].'#text'
                "IpAddress" = $entry.Event.EventData.Data[1].'#text'
                "Info" = $entry.Event.EventData.Data[2].'#text'
                }
            }
        $Output | Select-Object TimeCreated,EventRecordID,IpAddress
    }
    Catch { return 'Result: Null'}
}