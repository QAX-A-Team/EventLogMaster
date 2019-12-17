function FileDefaultRdp {
    $RdpDefault = [environment]::getfolderpath("mydocuments")+'./Default.rdp'
    # %userprofile%\documents\ => $env:userprofile"\documents\"
    Get-Content -path $RdpDefault | find "full address"
}