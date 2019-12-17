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

    # $HKEY_CURRENT_USER_PATH = "Registry::HKEY_CURRENT_USER\Software\Microsoft\Terminal Server Client\Default"

    # $HKEY_CURRENT_USER_SERVER_PATH = "Registry::HKEY_CURRENT_USER\Software\Microsoft\Terminal Server Client\Servers\"

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