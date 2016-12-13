function Send-ToInfluxDB
{
    [CmdletBinding()]
    param
    (
        [Parameter(Mandatory = $true)]
        $InfluxServer,

        [Parameter(Mandatory = $true)]
        $InfluxPort,

        [Parameter(Mandatory = $true)]
        $InfluxDB,

        [Parameter(Mandatory = $true)]
        $InfluxUser,

        [Parameter(Mandatory = $true)]
        $InfluxPass,

        [Parameter(Mandatory = $true)]
        $Data
    )

    $URI = "http://$($InfluxServer):$InfluxPort/write?db=$InfluxDB"
    $Auth = "Basic " + ([Convert]::ToBase64String([System.Text.encoding]::ASCII.GetBytes("$($InfluxUser):$InfluxPass")))
    $InputData = New-Object System.Collections.ArrayList
    foreach ($Obj in $Data)
    {
        [int64]$timestamp = (([datetime]::UtcNow)-(Get-Date -Date "1/1/1970")).TotalMilliseconds * 1000000

        [void]$InputData.Add("$($Obj.measurement),device=$($Obj.device) value=$($Obj.value)i $timestamp")
        [void]$InputData.Add("`n")
    }

    Invoke-RestMethod -Headers @{Authorization=$Auth} -Uri $URI -Method POST -Body $InputData 
    $InputData
}
