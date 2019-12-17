function ClearnDefaultRdp {
    $RdpDefault = [environment]::getfolderpath("mydocuments")+'./Default.rdp'
    # %userprofile%\documents\ => $env:userprofile"\documents\"
    write-host $RdpDefault
    $RdpDefaultDelIp = (Get-Content $RdpDefault)|Foreach-Object {$_ -replace [Regex]('\d+.\d+.\d+.\d+'), ''}
    # Remove-Item $RdpDefault -Recurse -Force 2>&1 | Out-Null
    Set-Content $RdpDefault -value $RdpDefaultDelIp
}