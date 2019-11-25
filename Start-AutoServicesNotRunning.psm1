Get-CimInstance -ComputerName X -ClassName Win32_Service -Filter "StartMode='Auto' and State='Stopped' and Name='BITS'" |
    Invoke-CimMethod -MethodName StartService

<#
.SYNOPSIS
The template gives a good starting point for creating powershell functions and tools.
Start your design with writing out the examples as a functional spesification.
.DESCRIPTION
.PARAMETER
.EXAMPLE
#>

function Start-AutoServicesNotRunning {
    [CmdletBinding()]
    #^ Optional ..Binding(SupportShouldProcess=$True,ConfirmImpact='Low')
    param (
    [Parameter(ValueFromPipeline=$True,
        ValueFromPipelineByPropertyName=$True)]
    [Alias('CN','MachineName','HostName','Name')]
    [string[]]$ComputerName = "ridbfaif0001"
    )

    

BEGIN {
    # Intentionaly left empty.
} #Begin

PROCESS {
    $Reg_Exclued = "^(gupdate|MapsBroker|RemoteRegistry|sppsvc|WbioSrvc)"
    
    foreach($computer in $ComputerName){    
        
        $splat_ciminstance = @{'ComputerName'=$computer
                                'ClassName'='Win32_Service'
                                'Filter'="StartMode='Auto' and State='Stopped'"}

        $Services = Get-CimInstance @splat_ciminstance | Where-Object {$_.Name -notmatch $Reg_Exclued}
        
        #-ComputerName $computer -ClassName Win32_Service -Filter "StartMode='Auto' and State='Stopped'" | Where-Object {$_.Name -notmatch $Reg_Exclued}
        
        foreach($service in $Services){
            Write-Output "Trying to start $($service.DisplayName) on $computer."
            $Result = $service | Invoke-CimMethod -MethodName StartService
            $switch = $result.ReturnValue
            Switch($switch){
                0 {
                    Write-Output "Request to start $($service.DisplayName) on $computer was accepted."
                } #0
                default {
                    Write-Output "Request to start $($service.DisplayName) on $computer failed."
                }
            }
            
        } #Foreach
    } #Foreach
} #Process


END {
    # Intentionaly left empty.
} #End

} #Function