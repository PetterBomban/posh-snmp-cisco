function Start-GatheringData
{
    param
    (
        [Parameter(Mandatory = $True)]
        $msg
    )

    ## Load Invoke-SnmpGet
    . .\main.ps1

    ## Array to keep all of the data
    $res = @()

    foreach ($var in $msg)
    {
        switch ($var.Id)
        {
            ".1.3.6.1.4.1.9.9.48.1.1.1.5.1" { $Measurement = "mem.used"}
            ".1.3.6.1.4.1.9.9.48.1.1.1.6.1" { $Measurement = "mem.free"}
            ".1.3.6.1.4.1.9.9.109.1.1.1.1.3.1" { $Measurement = "cpu.usage-percent"}
        }

        $data = [PSCustomObject]@{
            measurement = $Measurement
            value = $var.Data.ToString()
            device = $sIP
        }
        $res += $data
    }
    
    $res

}

## ASA only for now
$oids = @(
    "1.3.6.1.4.1.9.9.48.1.1.1.5.1", ## mem.used
    "1.3.6.1.4.1.9.9.48.1.1.1.6.1", ## mem.free
    "1.3.6.1.4.1.9.9.109.1.1.1.1.3.1" ## cpu.usage-percent
)

