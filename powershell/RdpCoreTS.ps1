function RdpCoreTS {
    Try {
        Get-WinEvent -ListLog Security|out-null
    }
    Catch { return 'PowerShell Get-WinEvent cmdlet Error.' }
    Try {
        $SuccessResults=Get-WinEvent -LogName 'Microsoft-Windows-RemoteDesktopServices-RdpCoreTS/Operational' -FilterXPath "*[System[(EventID=131) or (EventID=140)]]" -ErrorAction Stop
        $SuccessResults | Foreach {
            $entry = [xml]$_.ToXml()
            [array]$Output += New-Object PSObject -Property @{
                "TimeCreated" = $_.TimeCreated
                "EventID" = $entry.Event.System.EventID
                "EventRecordID" = $entry.Event.System.EventRecordID
                "IpAddress" = $entry.Event.EventData.Data.'#text'
                }
        }
        $Output | Select-Object TimeCreated,EventRecordID,IpAddress
    }
    Catch { return 'Result: Null'}
}