function RegClientHostName {
    #"Registry::HKEY_CURRENT_USER\Volatile Environment\"
    $UserSID = dir "Registry::HKEY_USERS" -Name -ErrorAction Stop
    foreach($Name in $UserSID) {
        $RegPath = "Registry::HKEY_USERS\"+$Name+"\Volatile Environment\"
        Try {
            $Servers = dir $RegPath -Name -ErrorAction Stop
            foreach ($Server in $Servers) {
                $ClientHostName = (Get-ItemProperty -Path $RegPath$Server -ErrorAction Stop).CLIENTNAME
                if ($ClientHostName) {
                    Write-Host "[+] RegPath: "$RegPath$Server
                    Write-Host "[+] CLIENTNAME: "$ClientHostName
                }
            }
        }
        Catch {continue}
    }
    write-host "Search Done."
}