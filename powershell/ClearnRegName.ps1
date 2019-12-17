function ClearnRegName {
    [CmdletBinding()]
    Param (
        [string]$RegPathName
    )
    write-host $RegPathName
    Remove-Item -Path "Registry::$RegPathName"
}