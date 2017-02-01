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
    "IOS" = 1
    "NX-OS" = 1
}

function Start-GatheringData
{
    param
    (
        [Parameter(Mandatory = $True)]
        [hashtable]$Devices
    )

    foreach ($Device in $Devices)
    {
        #Write-Output $Device.Key
        Write-Output $Device.OID
    }
}

Start-GatheringData -Devices $Devices
