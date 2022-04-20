<#
.DESCRIPTION
This script configures the Windows feature Client-KeyboardFilter to prevent specific shortcuts to be used
on a kiosk device.

.NOTES
    Version:          1.1
    Author:           Samantha Howlett, Dominik Stegemann/baseVISION
    Creation Date:    15.10.2020
    Modification Date:
    Purpose/Change:   15.10.2020 - Initial script development
                      26.03.2021 - Added custom keys for Edge
    Functions:        Write-ScriptLog
                      Enable-Custom-Key

#>   

function Write-ScriptLog {
    <#
    .SYNOPSIS
        Writes logs for this script

    .DESCRIPTION
        Writes logs with date and time into a text file to a specified location.

    .PARAMETER LogPath
        Path where to store the log files

    .EXAMPLE
        Write-Log -LogPath 'c:\logs'

    .NOTES
        Version:          1.0
        Author:           Jeremias Emch/baseVISION
        Creation Date:    <Date>
        Purpose/Change:   Initial script development
    #>

    [CmdletBinding()]
    Param
    (
        # Path for logs
        [Parameter(Mandatory)]
        [ValidateNotNullOrEmpty()]
        [String]$LogPath,

        # Log message
        [Parameter(Mandatory)]
        [ValidateNotNullOrEmpty()]
        [String]$LogMessage
    )

    Process {
        # Check log path
        if (Test-Path -Path (Split-Path -Path $LogPath)) {
            # Write logs to txt file
            $dt = Get-Date -UFormat %Y"/%m/%d/%T"
            $errorText = $dt + " - " + $LogMessage -replace "`n", " " -replace "´n", " " 
            Out-File -FilePath $LogPath -Append -InputObject $errorText 
        }
        else {
            Write-Host "No access to specified log path ($LogPath)."
            Write-Host "The Script wont be able to load LOGS and it will be terminated." -ForegroundColor Red
            Exit
        }
    }
}


function Enable-Custom-Key {
    <#
    .SYNOPSIS
        Add or enable a key combination for Keyboard Filter to block

    .DESCRIPTION
        Add or enable a key combination for Keyboard Filter to block

    .PARAMETER KeyId
        Key combination to block

    .EXAMPLE
        Enable-Custom-Key "Ctrl+d"

    .NOTES
        Version:          1.0
        Author:           https://docs.microsoft.com/en-us/windows-hardware/customize/enterprise/wekf-customkeyadd
        Creation Date:    <Date>
        Purpose/Change:   Initial script development
    #>

    [CmdletBinding()]
    Param
    (
        # Key combination
        [Parameter(Mandatory)]
        [ValidateNotNullOrEmpty()]
        [String]$KeyId
    )

    Process {
    # Check to see if the custom key object already exists
        $objCustomKey = Get-WMIObject -namespace $NAMESPACE -class WEKF_CustomKey |
                where {$_.Id -eq "$KeyId"}

        if ($objCustomKey) {

    # The custom key already exists, so just enable it
            $objCustomKey.Enabled = 1
            $objCustomKey.Put() | Out-Null
            
            $Enablemessage = "Value already found! Enabled ${KeyId}"
            Write-ScriptLog -LogPath $LogPath -LogMessage "$Enablemessage "

        } else {

    # Create a new custom key object by calling the static Add method
            $retval = $classCustomKey.Add($KeyId)

    # Check the return value to verify that the Add is successful
            if ($retval.ReturnValue -eq 0) {
                $Addmessage = "Added ${KeyID}."
                Write-ScriptLog -LogPath $LogPath -LogMessage "$Addmessage"
            } else {
                $Errormessage = "Unknown Error: " + "{0:x0}" -f $retval.ReturnValue
                Write-ScriptLog -LogPath $LogPath -LogMessage "$Errormessage"
            }
        }
    }
}

#########################################################################
$LogPath = 'C:\Windows\Logs\CustomKeyboardFilter_Config.log'

$COMPUTER = "localhost"
$NAMESPACE = "root\standardcimv2\embedded"
# Create a handle to the class instance so we can call the static methods
$classCustomKey = [wmiclass]"\\$COMPUTER\${NAMESPACE}:WEKF_CustomKey"

$RegPath = "HKLM:\SOFTWARE\Microsoft\Windows Embedded\KeyboardFilter"

try{
    if(Test-Path -Path $RegPath){
        
        #Change RegPath to the CustomerFilters, after check for Windows Keyboard Filter Service
        $RegPath = "HKLM:\SOFTWARE\Microsoft\Windows Embedded\KeyboardFilter\CustomFilters"

        Enable-Custom-Key "Ctrl+d"
        Enable-Custom-Key "Ctrl+h"
        Enable-Custom-Key "Ctrl+j"
        Enable-Custom-Key "Ctrl+o"
        Enable-Custom-Key "Ctrl+s"
        Enable-Custom-Key "Ctrl+Shift+u"
        Enable-Custom-Key "F1"
        Enable-Custom-Key "F7"

        #Check
        $KeyboardFilterRegistry = Get-ItemProperty -Path $RegPath
        if($KeyboardFilterRegistry."Ctrl+d" -eq "Blocked"){
            Write-ScriptLog -LogPath $LogPath -LogMessage "Enabled keyboard filter for Ctrl+d"
        } else {
            Write-ScriptLog -LogPath $LogPath -LogMessage "Keyboard filter for Ctrl+d still disabled"
        }
       if($KeyboardFilterRegistry."Ctrl+h" -eq "Blocked"){
            Write-ScriptLog -LogPath $LogPath -LogMessage "Enabled keyboard filter for Ctrl+h"
        } else {
            Write-ScriptLog -LogPath $LogPath -LogMessage "Keyboard filter for Ctrl+h still disabled"
        }
       if($KeyboardFilterRegistry."Ctrl+j" -eq "Blocked"){
            Write-ScriptLog -LogPath $LogPath -LogMessage "Enabled keyboard filter for Ctrl+j"
        } else {
            Write-ScriptLog -LogPath $LogPath -LogMessage "Keyboard filter for Ctrl+j still disabled"
        }
       if($KeyboardFilterRegistry."Ctrl+o" -eq "Blocked"){
            Write-ScriptLog -LogPath $LogPath -LogMessage "Enabled keyboard filter for Ctrl+o"
        } else {
            Write-ScriptLog -LogPath $LogPath -LogMessage "Keyboard filter for Ctrl+o still disabled"
        }
       if($KeyboardFilterRegistry."Ctrl+s" -eq "Blocked"){
            Write-ScriptLog -LogPath $LogPath -LogMessage "Enabled keyboard filter for Ctrl+s"
        } else {
            Write-ScriptLog -LogPath $LogPath -LogMessage "Keyboard filter for Ctrl+s still disabled"
        }
       if($KeyboardFilterRegistry."Ctrl+Shift+u" -eq "Blocked"){
            Write-ScriptLog -LogPath $LogPath -LogMessage "Enabled keyboard filter for Ctrl+Shift+u"
        } else {
            Write-ScriptLog -LogPath $LogPath -LogMessage "Keyboard filter for Ctrl+Shift+u still disabled"
        }
       if($KeyboardFilterRegistry."F1" -eq "Blocked"){
            Write-ScriptLog -LogPath $LogPath -LogMessage "Enabled keyboard filter for F1"
        } else {
            Write-ScriptLog -LogPath $LogPath -LogMessage "Keyboard filter for F1 still disabled"
        }
       if($KeyboardFilterRegistry."F7" -eq "Blocked"){
            Write-ScriptLog -LogPath $LogPath -LogMessage "Enabled keyboard filter for F7"
        } else {
            Write-ScriptLog -LogPath $LogPath -LogMessage "Keyboard filter for F7 still disabled"
        }

        #Enable Keyboard Filter service
        $serviceStatus = Get-Service -Name "Microsoft Keyboard Filter" | Select-Object -Property StartType
        if(($serviceStatus.StartType -eq "Disabled")){
            Write-ScriptLog -LogPath $LogPath -LogMessage "Keyboard Filter service is currently disabled"
            Set-Service -Name "MsKeyboardFilter" -StartupType "Automatic"
            $serviceStatus = Get-Service -Name "Microsoft Keyboard Filter" | Select-Object -Property StartType
            if(($serviceStatus.StartType -eq "Automatic")){
                Write-ScriptLog -LogPath $LogPath -LogMessage "Keyboard Filter service StartType is now set to: Automatic"
            } else {
                Write-ScriptLog -LogPath $LogPath -LogMessage "Keyboard Filter service is still disabled."
            } 
        }
        
        #Require restart
        exit 3010
    } else {
        Write-ScriptLog -LogPath $LogPath -LogMessage "Keyboard Filter not present in Registry"
    }
}catch{
    Write-ScriptLog -LogPath $LogPath -LogMessage "$_.Exception.Message"
}