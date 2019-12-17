function RegSecMaxSize {
    [CmdletBinding()]
    Param (
        [string]$EventLogType,
        [string]$MaxSize     
    )

    # Search
    if ($EventLogType -eq 'Security'){
        $EventLogRegPath = "Registry::HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\services\eventlog\Security"
    }
    if ($EventLogType -eq 'RemoteConnectionManager'){
        $EventLogRegPath = "Registry::HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\WINEVT\Channels\Microsoft-Windows-TerminalServices-RemoteConnectionManager/Operational"
    }
    if ($EventLogType -eq 'LocalSessionManager'){
        $EventLogRegPath = "Registry::HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\WINEVT\Channels\Microsoft-Windows-TerminalServices-LocalSessionManager/Operational"
    }

    if ($MaxSize -eq '20'){
        $MaxSize = 20971520
    }
    if ($MaxSize -eq '50'){
        $MaxSize = '52428800'
    }    
    if ($MaxSize -eq '100'){
        $MaxSize = '104857600'
    }
    if ($MaxSize -eq '200'){
        $MaxSize = '209715200'
    }
    if ($MaxSize -eq '1000'){
        $MaxSize = '1048576000'
    }

    Try {
        # Search
        $EventLogRegValue = (Get-ItemProperty -Path $EventLogRegPath -ErrorAction Stop).MaxSize
        write-host "Old Size: "($EventLogRegValue/1024/1024)M
        # Change
        Set-Itemproperty -path $EventLogRegPath -Name 'MaxSize' -value $MaxSize
        # Search
        $EventLogRegValueCheck = (Get-ItemProperty -Path $EventLogRegPath -ErrorAction Stop).MaxSize
        write-host "New Size: "($EventLogRegValueCheck/1024/1024)M
    }
    Catch { continue }
}