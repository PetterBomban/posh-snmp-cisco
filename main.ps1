function Start-GatheringData
{
    [CmdletBinding()]
    param
    (
        [Parameter(Mandatory = $True)]
        [hashtable]$Devices,

        [Parameter(Mandatory = $True)]
        [String]$CommunityString
    )
    ## For getting snmp data
    # . .\Invoke-SnmpGet.ps1
    ## For sending the data to InfluxDb
    # . .\Send-ToInfluxDB

    ## Load the required snmp dll.
    [System.Reflection.Assembly]::LoadFrom(".\SharpSnmpLib.Full.dll") | Out-Null

    ## Used for collecting objects. Number depends on $Devices.Count
    $Collection = @()
    foreach ($Device in $Devices)
    {
        Write-Verbose $Device.OID
        Write-Verbose "Getting SNMP data from $($Device.IpAddress)"

        $Get = Invoke-SnmpGet `
            -sIP $Device.IpAddress `
            -sOIDs $Device.OID `
            -Community $CommunityString `
            -UDPport 162 `
            -TimeOut 5000

        Write-Verbose $Get

        $Collection += $Get
    }

    Write-Verbose "Stating to send data to InfluxDb"

    ## TODO: How do we send $Collection to Influx?

    Send-ToInfluxDb `
        -InfluxServer $InfluxServer `
        -InfluxPort $InfluxPort `
        -InfluxDB $InfluxDB `
        -InfluxUser $InfluxUser `
        -InfluxPass $InfluxPass
    
    Write-Verbose "Data sent to InfluxDb!"
    Write-Output $Collection
}
## Example usage:

## ASA only for now
$AsaOid = @(
    "1.3.6.1.4.1.9.9.48.1.1.1.5.1", ## mem.used
    "1.3.6.1.4.1.9.9.48.1.1.1.6.1", ## mem.free
    "1.3.6.1.4.1.9.9.109.1.1.1.1.3.1" ## cpu.usage-percent
    ## interface.outside-in
    ## interface.outside-out
)
$IosOid = @()
$NxOs = @()

## Devices and their OIDs
$Devices = @{
    "ASA" = @{
        "IpAddress" = "192.168.0.1"
        "OID" = $AsaOid
    }
    "IOS" = $null
    "NX-OS" = $null
}

## TODO: Add support for Get-Credential
Start-GatheringData `
    -Devices $Devices `
    -CommunityString "ikt-fag.no" `
    -InfluxServer "192.168.0.30" `
    -InfluxPort 8086 `
    -InfluxDB "ciscotest" `
    -InfluxUser "root" `
    -InfluxPass "Passord1"
    -Verbose
