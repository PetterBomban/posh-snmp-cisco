param ($ip, $community, $oid, $port = 162)

1..2 | ForEach-Object {
    [System.Reflection.Assembly]::LoadFrom("C:\Users\admin\Documents\GitHub\posh-influx-snmp-cisco\SharpSnmpLib.Full.dll") | Out-Null
}

function Invoke-SnmpWalk ([string]$sIP, $sOIDstart, [string]$Community = "public", [int]$UDPport = 161, [int]$TimeOut=3000) {
    # $sOIDstart
    # $TimeOut is in msec, 0 or -1 for infinite

    # Create OID object
    $oid = New-Object Lextm.SharpSnmpLib.ObjectIdentifier ($sOIDstart)
    
    # Create list for results
    #$results = New-GenericObject System.Collections.Generic.List Lextm.SharpSnmpLib.Variable                       # PowerShell v1 and v2
    $results = New-Object 'System.Collections.Generic.List[Lextm.SharpSnmpLib.Variable]'                         # PowerShell v3
    
    # Create endpoint for SNMP server
    $ip = [System.Net.IPAddress]::Parse($sIP)
    $svr = New-Object System.Net.IpEndPoint ($ip, 161)
    
    # Use SNMP v2 and walk mode WithinSubTree (as opposed to Default)
    $ver = [Lextm.SharpSnmpLib.VersionCode]::V2
    $walkMode = [Lextm.SharpSnmpLib.Messaging.WalkMode]::WithinSubtree
    
    # Perform SNMP Get
    try {
        [Lextm.SharpSnmpLib.Messaging.Messenger]::Walk($ver, $svr, $Community, $oid, $results, $TimeOut, $walkMode)
    } catch {
        Write-Host "SNMP Walk error: $_"
        Return $null
    }
    
    $res = @()
    foreach ($var in $results) {
        $line = "" | Select-Object OID, Data
        $line.OID = $var.Id.ToString()
        $line.Data = $var.Data.ToString()
        $res += $line
    }
    
    $res
}

Invoke-SnmpWalk -sIP $ip -sOIDstart $oid -Community $community -UDPport $port
