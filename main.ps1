## Modified version of Invoke-SNMPget from https://vwiki.co.uk/SNMP_and_PowerShell

## Load SharpSnmpLib 
1..2 | foreach {
    [System.Reflection.Assembly]::LoadFrom("C:\Users\admin\Documents\GitHub\posh-influx-snmp-cisco\SharpSnmpLib.Full.dll") | Out-Null
}

. "C:\Users\admin\Documents\GitHub\posh-influx-snmp-cisco\Send-ToInfluxDB.ps1"

function Invoke-SnmpGet () {

    # $OIDs can be a single OID string, or an array of OID strings
    # $TimeOut is in msec, 0 or -1 for infinite
    [CmdletBinding()]
    param
    (
        [Parameter(Mandatory = $True)]
        [string]$sIP,

        [Parameter(Mandatory = $True)]
        [string[]]$sOIDs = @(),

        [Parameter(Mandatory = $True)]
        [string]$Community,

        [Parameter(Mandatory = $False)]
        [int]$UDPport = 162,

        [Parameter(Mandatory = $False)]
        [int]$TimeOut = 3000
    )

    # Create OID variable list
    $vList = New-Object 'System.Collections.Generic.List[Lextm.SharpSnmpLib.Variable]'
    foreach ($sOID in $sOIDs)
    {
        $oid = New-Object Lextm.SharpSnmpLib.ObjectIdentifier ($sOID)
        $vList.Add($oid)
    }
    
    # Create endpoint for SNMP server
    $ip = [System.Net.IPAddress]::Parse($sIP)
    $svr = New-Object System.Net.IpEndPoint ($ip, 161)
    
    # Use SNMP v2
    $ver = [Lextm.SharpSnmpLib.VersionCode]::V2
    
    # Perform SNMP Get
    try
    {
        $msg = [Lextm.SharpSnmpLib.Messaging.Messenger]::Get($ver, $svr, $Community, $vList, $TimeOut)
    }
    catch
    {
        Write-Host "SNMP Get error: $_"
        Return $null
    }

    $res = @()
    foreach ($var in $msg)
    {
        switch ($var.Id)
        {
            ".1.3.6.1.4.1.9.9.48.1.1.1.5.1" { $Measurement = "mem.used"}
            ".1.3.6.1.4.1.9.9.48.1.1.1.6.1" { $Measurement = "mem.free"}
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

$Get = Invoke-SnmpGet `
    -sIP "192.168.0.1" `
    -sOIDs "1.3.6.1.4.1.9.9.48.1.1.1.5.1", "1.3.6.1.4.1.9.9.48.1.1.1.6.1" `
    -Community "ikt-fag.no" `
    -UDPport 162 `
    -TimeOut 5000

Send-ToInfluxDB -InfluxServer "192.168.0.30" -InfluxPort 8086 -InfluxDB "ciscotest" -InfluxUser "root" -InfluxPass "Passord1" -Data $Get
