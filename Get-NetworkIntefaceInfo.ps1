function Get-NetworkInterfaceInfo(){
    $Assemblies = @(
    'System.Net.NetworkInformation'
    )

    # Loads the assemblies without locking the DLL
    foreach($Assembly in $Assemblies){
        $ScriptBlock = {[System.Reflection.Assembly]::LoadWithPartialName($Assembly).Location}
        $bytes = [System.IO.File]::ReadAllBytes((Invoke-Command -ScriptBlock $ScriptBlock))
        $null = [System.Reflection.Assembly]::Load($bytes)
    }

    $NicInfo = @()
    $nics = [System.Net.NetworkInformation.NetworkInterface]::GetAllNetworkInterfaces()

    foreach ($nic in $nics)
    {
        $ipAddresses = $nic.GetIPProperties().UnicastAddresses.where({$_.Address.AddressFamily -eq 'InterNetwork'})
            
        foreach ($ipAddress in $ipAddresses)
        {
            $HT = @{Index = $NicInfo.count;ID = $nic.Id;Name = $nic.Name;IPAddress = $ipAddress.Address.IPAddressToString}
            $obj = New-Object -TypeName psobject -Property $HT
            $NicInfo += $obj
        }
    }
    return $NicInfo
}
