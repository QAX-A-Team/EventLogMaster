function SearchAllEventLog {
    function RegRdpPort {
        $RegPath = "Registry::HKEY_LOCAL_MACHINE\System\CurrentControlSet\Control\Terminal Server\WinStations\RDP-Tcp\"
        $RDPportValue = (Get-ItemProperty -Path $RegPath -ErrorAction Stop).PortNumber
        write-host "RDP-Tcp PortNumber: "$RDPportValue
    }

    function EventLogSuccess {
        Try {
            $Events = Get-WinEvent -LogName "Security" -FilterXPath "*[EventData[(Data[@Name='LogonType']='10')] and System[EventID=4624]]" -ErrorAction Stop
            ForEach ($Event in $Events) {
                $eventXML = [xml]$Event.ToXml()
                Add-Member -InputObject $Event -MemberType NoteProperty -Force -Name "TimeCreate" -Value $Event.TimeCreated
                FOREACH ($j in $eventXML.Event.System.ChildNodes) {
                    Add-Member -InputObject $Event -MemberType NoteProperty -Force -Name $j.ToString() -Value $eventXML.Event.System.($j.ToString())
                }
                For ($i=0; $i -lt $eventXML.Event.EventData.Data.Count; $i++) {
                    Add-Member -InputObject $Event -MemberType NoteProperty -Force -Name $eventXML.Event.EventData.Data[$i].name -Value $eventXML.Event.EventData.Data[$i].'#text'
                }
            }
            $Events |select TimeCreate,EventRecordID,IpAddress,IpPort
        }
        Catch { return 'Result: Null'}
    }

    function EventLogCredentials {
        Try {
            $Events = Get-WinEvent -LogName "Security" -FilterXPath "*[System[EventID=4648]]" -ErrorAction Stop
            ForEach ($Event in $Events) {
                $eventXML = [xml]$Event.ToXml()
                Add-Member -InputObject $Event -MemberType NoteProperty -Force -Name "TimeCreate" -Value $Event.TimeCreated
                FOREACH ($j in $eventXML.Event.System.ChildNodes) {
                    Add-Member -InputObject $Event -MemberType NoteProperty -Force -Name $j.ToString() -Value $eventXML.Event.System.($j.ToString())
                }
                For ($i=0; $i -lt $eventXML.Event.EventData.Data.Count; $i++) {
                    Add-Member -InputObject $Event -MemberType NoteProperty -Force -Name $eventXML.Event.EventData.Data[$i].name -Value $eventXML.Event.EventData.Data[$i].'#text'         
                }
            }
            $Events |select TimeCreate,EventRecordID,IpAddress,IpPort
        }
        Catch { return 'Result: Null'}
    }

    function RemoteConnectionManager {
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

    function LocalSessionManager {
        Try {
            $SuccessResults=Get-WinEvent -LogName 'Microsoft-Windows-TerminalServices-LocalSessionManager/operational' -FilterXPath "*[System[(EventID=21) or (EventID=22) or (EventID=24) or (EventID=25)]]" -ErrorAction Stop
            $SuccessResults | Foreach {
                $entry = [xml]$_.ToXml()
                [array]$Output += New-Object PSObject -Property @{
                    "TimeCreated" = $_.TimeCreated
                    "EventID" = $entry.Event.System.EventID
                    "EventRecordID" = $entry.Event.System.EventRecordID
                    "User" = $entry.Event.UserData.EventXML.User
                    "IpAddress" = $entry.Event.UserData.EventXML.Address
                }
            }
            $Output | Select-Object TimeCreated,EventID,EventRecordID,IpAddress
        }
        Catch { return 'Result: Null'}
    }

    function ClientActiveXCore {
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

    function RdpCoreTS {
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

    function RegClientHostName {
        $UserSID = dir "Registry::HKEY_USERS" -Name -ErrorAction Stop
        foreach($Name in $UserSID) {
            $RegPath = "Registry::HKEY_USERS\"+$Name+"\Volatile Environment\"
            Try {
                $Servers = dir $RegPath -Name -ErrorAction Stop
                foreach ($Server in $Servers) {
                    $ClientHostName = (Get-ItemProperty -Path $RegPath$Server -ErrorAction Stop).CLIENTNAME
                    Write-Host "[+] RegPath: "$RegPath$Server
                    Write-Host "[+] ClientHostName: "$ClientHostName
                }
            }
            Catch {continue}
        }
    }

    function RegRdcServer {
        function GetServers {
            Param (
                $ServerRegPath
            )
            Try {
                $ServerNames = dir $ServerRegPath -Name -ErrorAction Stop
                write-host $ServerRegPath
                foreach ($ServerName in $ServerNames) {
                    $UsernameHint = (Get-ItemProperty -Path $ServerRegPath$ServerName).UsernameHint
                    Write-Host "[+] Server: "$ServerName"   UsernameHint: "$UsernameHint
                    $CertHash = (Get-ItemProperty -Path $ServerRegPath$ServerName -ErrorAction Stop).CertHash
                    if($CertHash) {
                        Write-Host "[+] Server: "$ServerName"    UsernameHint: "$UsernameHint"    CertHash: "$CertHash
                    }
                }
            }
            Catch { continue }
        }
        function GetDefaultServers {
            Param (
                $DefaultServerRegPath
            )
            Try {
                $ServerNames = Get-Item -Path $DefaultServerRegPath -ErrorAction Stop
                write-host $DefaultServerRegPath
                foreach ($ServerName in $ServerNames.Property) {
                    write-host "[+] Server:port > "$ServerNames.GetValue($ServerName)
                }
            }
            Catch { continue }
        }
        write-host "Search RDS from HKEY_USERS. Result: Regpath - Value"
        $UserSID = dir "Registry::HKEY_USERS" -Name -ErrorAction Stop
        foreach($Name in $UserSID) {
            $SIDRegPath = "Registry::HKEY_USERS\"+$Name+"\Software\Microsoft\Terminal Server Client\Servers\"
            $SIDefaultRegPath = "Registry::HKEY_USERS\"+$Name+"\Software\Microsoft\Terminal Server Client\Default\"
            Try {
                GetDefaultServers $SIDefaultRegPath
            }
            Catch { continue }
            Try {
                GetServers $SIDRegPath
            }
            Catch { continue }
        }
    }

    Try {
        # Check Get-WinEvent cmdlet
        Get-WinEvent -ListLog Security | out-null

        write-host "SearchAll - RdpPort"
        RegRdpPort

        write-host "SearchAll - EventLogSuccess"
        EventLogSuccess

        write-host "SearchAll - EventLogCredentials"
        EventLogCredentials

        write-host "SearchAll - RemoteConnectionManager"
        RemoteConnectionManager

        write-host "SearchAll - LocalSessionManager"
        LocalSessionManager

        write-host "SearchAll - ClientActiveXCore"
        ClientActiveXCore

        write-host "SearchAll - RdpCoreTS"
        RdpCoreTS

        write-host "SearchAll - RegClientHostName"
        RegClientHostName

        write-host "SearchAll - RegRdcServer"
        RegRdcServer

    }
    Catch { return 'PowerShell Get-WinEvent cmdlet Error.' }

}