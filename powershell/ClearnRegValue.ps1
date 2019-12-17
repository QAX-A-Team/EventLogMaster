function ClearnRegValue {
    [CmdletBinding()]
    Param (
        [string]$RegPathName,
        [string]$RegPathValue
    )
    write-host $RegPathName
    write-host $RegPathValue
    # Remove-ItemProperty -Path "Registry::$RegPathName" -Name "$RegPathValue"
    Set-Itemproperty -Path "Registry::$RegPathName" -Name "$RegPathValue" -Value ""
}