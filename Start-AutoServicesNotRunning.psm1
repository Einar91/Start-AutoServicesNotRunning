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
    [string[]]$ComputerName
    )

    

BEGIN {
    # Intentionaly left empty.
} #Begin

PROCESS {
    $Reg_Exclued = "^(gupdate|MapsBroker|RemoteRegistry|sppsvc|WbioSrvc)"
    
    foreach($computer in $ComputerName){    
        Try{
            #Create our object
            $ComputerObj = New-Object psobject -Property @{'ComputerName'=$computer}        

            $splat_ciminstance = @{'ComputerName'=$computer
                                    'ClassName'='Win32_Service'
                                    'Filter'="StartMode='Auto' and State='Stopped'"
                                    'ErrorAction'='Stop'
                                    'ErrorVariable'='ErrorInstance'}

            $Services = Get-CimInstance @splat_ciminstance | Where-Object {$_.Name -notmatch $Reg_Exclued}
            
            
            
            foreach($service in $Services){
                Write-Output "$computer : Trying to start $($service.DisplayName)."
                $Result = $service | Invoke-CimMethod -MethodName StartService
                $switch = $result.ReturnValue
                Switch($switch){
                    0 {
                        Write-Verbose "$computer : Request to start $($service.DisplayName) was accepted."
                        Add-Member -InputObject $ComputerObj -MemberType NoteProperty -Name 'RequestToStart' -Value 'Succesfull'
                    } #0
                    default {
                        Write-Verbose "$computer : Request to start $($service.DisplayName) failed."
                        Add-Member -InputObject $ComputerObj -MemberType NoteProperty -Name 'RequestToStart' -Value 'Failed'
                    }
                } #Switch
            } #Foreach

            #Output our object to the pipeline
            $ComputerObj

        } #Try
        Catch{
            # Catch error connection to computer
            if($ErrorInstance){
                Write-Verbose "$computer : Failed to connect.."
                Add-Member -InputObject $ComputerObj -MemberType NoteProperty -Name 'RequestToStart' -Value 'Failed to connect...'
                
                # Output object to pipeline
                $ComputerObj
            }
        }
    } #Foreach
    
} #Process


END {
    # Intentionaly left empty.
} #End

} #Function