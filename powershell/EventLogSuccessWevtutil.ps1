function EventLogSuccessWevtutil
{ 
    $evtx = $pwd.Path+"\Sec_.evtx"
    $evtx = (Get-Item $evtx).fullname
    write-host  $evtx

    [xml]$xmldoc = WEVTUtil qe $evtx /q:"*[System[(EventID=4624)] and EventData[Data[@Name='LogonType']=10]]" /e:root /f:Xml /lf

    $xmlEvent=$xmldoc.root.Event

    function OneEventToDict {
        Param (
            $event
        )
        $ret = @{
            "SystemTime" = $event.System.TimeCreated.SystemTime | Convert-DateTimeFormat -OutputFormat 'yyyy"/"MM"/"dd HH:mm:ss';
            "EventRecordID" = $event.System.EventRecordID
            "EventID" = $event.System.EventID
            "Computer" = $event.System.Computer
        }
        $data=$event.EventData.Data
        for ($i=0; $i -lt $data.Count; $i++){
            $ret.Add($data[$i].name, $data[$i].'#text')
        }
        return $ret
    }

    filter Convert-DateTimeFormat
    {
      Param($OutputFormat='yyyy-MM-dd HH:mm:ss fff')
      try {
        ([DateTime]$_).ToString($OutputFormat)
      } catch { continue }
    }

    [System.Collections.ArrayList]$results = New-Object System.Collections.ArrayList($null)
    
    # Fix One EventLog
    if ($xmlEvent.Count){
        for ($i=0; $i -lt $xmlEvent.Count; $i++){
            $event = $xmlEvent[$i]
            $datas = OneEventToDict $event
            $results.Add((New-Object PSObject -Property $datas))|out-null
        }
    }
    else{
        $event = $xmlEvent
        $datas = OneEventToDict $event
        $results.Add((New-Object PSObject -Property $datas))|out-null
    }

    $results | Select-Object SystemTime,EventRecordID,TargetUserName,IpAddress,IpPort

}